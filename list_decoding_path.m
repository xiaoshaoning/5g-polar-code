classdef list_decoding_path
  properties
    path_likelihood;    %The likelihood that this path is correct
    likelihoods;        %The intermediate likelihoods table
    xors;               %The intermediate xors table
    results;            %The predictions of this path
    alive = false;      %The state of the path, alive or dead
  end
end