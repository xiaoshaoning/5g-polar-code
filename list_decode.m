%decodes the received message using list decoding
%received: (Nx1) matrix, represents the received message
%frozen_indices: ((N-K)x1) matrix, specifies the indices of the frozen bits
%frozen_bits: ((N-K)x1) matrix, specifies the values of the frozen bits
%list_size: the number of paths to maintain
%channel_type: specifies the type of the channel on which the bits were
%sent. Could be 'bsc' for Binary Symmetric Channel, 'bec' for
%Binary Erasure Channel, and 'awgn' for Additive White Gaussian Noise
%Channel
%param: in 'bsc', param specifies the probability of the bit getting
%flipped, in 'bec', it represents the probability of erasure, and in 'awgn'
%it represents the standard deviation of the distribution
function result = list_decode(received, frozen_indices, frozen_bits, channel_type, param, list_size)
  length = size(received, 1);
  
  %We create 2*L path containers. However, whenever the number actually
  %reaches 2*L, we trim half of them and keep only L
  paths(list_size*2) = list_decoding_path();
  
  %We start by initializing storage elements for the first path to hold our intermediate
  %results. One of them will hold intermediate likelihoods of elements in
  %the middle to be a 0. The other holds the value of intermediate xor
  %operations that have already been calculated
  paths(1).likelihoods = cell(log2(length) + 1);
  paths(1).xors = cell(log2(length));
  for i = 1:(log2(length)+1)
    paths(1).likelihoods{i} = NaN(length/(2^(i-1)), 2^(i-1));
  end
  
  for i = 1:log2(length)
    paths(1).xors{i} = NaN(length/(2^(i-1)), 2^(i-1));
  end
  
  %We bit reverse the frozen indices. This is because frozen_indices
  %specifies which actual indices are frozen, but here we are working in a
  %bit reversed order, so we reverse frozen_indices to correspond to what
  %we are working with
  for i = 1:size(frozen_indices, 1)
    frozen_indices(i) = reverse_index(frozen_indices(i), log2(length));
  end
  
  paths(1).results = NaN(size(received, 1), 1);
  paths(1).alive = true;
  paths(1).path_likelihood = 1;
  %For each path that we have, we go and calculate the likelihoods.
  %Then, if the bit is frozen, we set it and move on
  %If it is not frozen, we create 2 paths from each path with the two
  %possibilities, and then check, if we have surpassed the list size, we
  %trim.
  %Then, for each path that we have, we propagate the xors
  for i = 1:size(received, 1)
    l = zeros(list_size*2, 1);
    for j = 1:list_size*2
      if (paths(j).alive == true)
        [l(j), paths(j).likelihoods] = calculate_likelihood(received, (paths(j).likelihoods), (paths(j).xors), 1, i, 1, log2(length) + 1, channel_type, param);
      end
    end
    frozen = find(frozen_indices == i);
    if (~isempty(frozen))
      for j = 1:list_size*2
        if (paths(j).alive == true)
          paths(j).results(i) = frozen_bits(frozen(1));
        end
      end
    else
      newly_created_paths = [];
      for j = 1:list_size*2
        if (paths(j).alive == true)
          if (l(j) > 1)
            paths(j).results(i) = 0;
            new_path_likelihood = 1/l(j);
          else
            paths(j).results(i) = 1;
            new_path_likelihood = l(j);
          end
          %We create another path
          %Look for a dead path
          for k = 1:list_size*2
            if (paths(k).alive == false && ~any(newly_created_paths(:) == k))
              paths(k).path_likelihood = new_path_likelihood;
              paths(j).path_likelihood = 1 / new_path_likelihood;
              paths(k).likelihoods = paths(j).likelihoods;
              paths(k).xors = paths(j).xors;
              paths(k).results = paths(j).results;
              paths(k).results(i) = ~paths(j).results(i);
              newly_created_paths = [newly_created_paths k];
              break;
            end
          end
        end
      end
      
      for j = newly_created_paths
        paths(j).alive = true;
      end
      
      %if we have more than list_size alive paths, we will have to prune
      count = 0;
      for j = 1:list_size*2;
        if (paths(j).alive == true)
          count = count + 1;
        end
      end
      if (count > list_size)
        % we remove half of the paths
        % note: here, this algorithm is wrong if list_size is not a power
        % of two.
        for j = 1:list_size
          min = 1;
          for k = 1:list_size*2
            if (paths(k).alive == true)
              if (paths(k).path_likelihood < paths(min).path_likelihood)
                min = k;    
              end
            end
          end
          paths(min).alive = false;
        end
      end
    end
    for j = 1:list_size*2
      if (paths(j).alive == true)
        paths(j).xors = propagate_value(paths(j).results(i), paths(j).xors, 1, i, 1, log2(length) + 1);
      end
    end
  end
  
  %We now choose the path that has the highest likelihood
  max = 1;
  for k = 1:list_size*2
    if (paths(k).alive == true)
      
      if (paths(k).path_likelihood > paths(max).path_likelihood)
        max = k;    
      end
    end
  end     
  %When we are done, we have been doing everything in bit-reversed order,
  %so we reverse again to restore the original order
  result = bitrevorder(paths(max).results);
end

%calculates the likelihood of the bit at a specific level to be a zero, and
%updates the likelihood table accordingly
function [likelihood, storage] = calculate_likelihood(received, likelihoods, xors, layer, idx1, idx2, max_depth, channel_type, param)
  %if a value has already been calculated, return
  if (~isnan(likelihoods{layer}(idx1, idx2)))
    likelihood = likelihoods{layer}(idx1, idx2);
    storage = likelihoods;
    return;
  end
  
  %If we have reached the channel level, get the likelihood from the
  %channel and return
  if (layer == max_depth)
    l = get_channel_likelihood(received(reverse_index(idx2, log2(size(received, 1)))), channel_type, param);
    likelihood = l;
    likelihoods{layer}(idx1, idx2) = l;
    storage = likelihoods;
    return;
  end
  
  [l1, likelihoods] = calculate_likelihood(received, likelihoods, xors, layer+1, (floor((idx1 - 1)/2)) + 1, (2*(idx2 - 1)) + 1, max_depth, channel_type, param);
  [l2, likelihoods] = calculate_likelihood(received, likelihoods, xors, layer+1, (floor((idx1 - 1)/2)) + 1, (2*(idx2 - 1) + 1) + 1, max_depth, channel_type, param);
  %BEC requires special treatment because it haas zeroes and infinities
  if (mod(idx1 - 1, 2) == 0)
    if (strcmp(channel_type, 'bec'))
      if ((isinf(l1) && isinf(l2)) || (l1 == 0 && l2 == 0))
        likelihood = Inf;
      elseif ((isinf(l1) && l2 == 0) || (l1 == 0 && isinf(l2)))
        likelihood = 0;
      else
        likelihood = 1;
      end
    else
      likelihood = (l1*l2 + 1)/(l1 + l2);
    end
  else
    if (strcmp(channel_type, 'bec'))
      if (l2 ~= 1)
        likelihood = l2;
      elseif (l1 ~= 1)
        likelihood = xor(l1, xors{layer}(idx1 - 1, idx2)); 
      else
        likelihood = 1;
      end
    else
      if (xors{layer}(idx1 - 1, idx2) == 0)
        likelihood = l1*l2;    
      else
        likelihood = l2/l1;
      end
    end
  end
  likelihoods{layer}(idx1, idx2) = likelihood;
  storage = likelihoods;
end

function likelihood = get_channel_likelihood(value, channel_type, param)
  if (strcmp(channel_type, 'bsc'))
    likelihood = get_bsc_likelihood(value, param);
  elseif (strcmp(channel_type, 'bec'))
    likelihood = get_bec_likelihood(value);
  elseif (strcmp(channel_type, 'awgn'))
    likelihood = get_awgn_likelihood(value, param);
  end
end

function likelihood = get_bsc_likelihood(value, flip_probability)
  if (value == 0)
    likelihood = (1-flip_probability)/flip_probability; 
  else
    likelihood = flip_probability/(1-flip_probability);
  end
end

function likelihood = get_bec_likelihood(value)
  if (value == 0)
    likelihood = Inf;
  elseif (value == 1)
    likelihood = 0;
  else
    likelihood = 1;
  end
end

function likelihood = get_awgn_likelihood(value, sigma)
  likelihood = exp((-(value+1)^2/(2*sigma^2)))/exp((-(value-1)^2/(2*sigma^2)));
end

function reversed_index = reverse_index(idx, n)
  reversed_index = bin2dec(fliplr(dec2bin(idx - 1,n))) + 1;
end

%propagates the xor values and updates the xor table accordingly
function new_values = propagate_value(value, xors, layer, idx1, idx2, max_depth)
  xors{layer}(idx1, idx2) = value;
  
  if (layer == max_depth)
    new_values = xors;
    return;
  end
  
  if (mod(idx1 - 1, 2) == 0)
    new_values = xors;
    return;
  end
  
  xors = propagate_value(xor(value, xors{layer}(idx1-1, idx2)), xors, layer+1, (floor((idx1 - 1)/2)) + 1, 2*(idx2 - 1) + 1, max_depth);
  xors = propagate_value(value, xors, layer+1, (floor((idx1 - 1)/2)) + 1, (2*(idx2 - 1) + 1) + 1, max_depth);
  
  new_values = xors;
end