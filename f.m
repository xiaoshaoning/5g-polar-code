% function result = f(p, q)
% result = (p * q + 1)/(p + q);
% end

function result = f(x, y)
% result = log((exp(x+y) + 1)/(exp(x) + exp(y)));
% result = 2*atanh(tanh(x/2) * tanh(y/2));
result = sign(x) * sign(y) * min(abs(x), abs(y));
end
