% f.m
%
% This function accepts a real number as input (call it x), and outputs
% x^2-1 if x is not a positive integer
% or a square matrix with x rows if x is a positive integer.

function output = f(x)
% The "function" keyword defines this f.m file to be function.
% The "output" is the name of the output variable, which will be returned to the user.
% The "x" is the name of the input variable.
% We are assuming here that x is a real scalar (i.e., a real number) as opposed to a
%   string, a matrix, or something else.


if (x>0 && mod(x,1)==0)
    m = 1:(x^2);
    output = reshape(m, x, x)';
else
   output = x^2-1;
end

return; % This ends the function and the contents of the output variable is returned to the user.