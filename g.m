% function result = g(p, q, u)
% result = (p^(1-2*u)) * q;
% end

function result = g(x, y, u)
if u == 0
  result = x + y;
elseif u == 1
  result = y - x;
else
  error('wrong u value.');
end
end