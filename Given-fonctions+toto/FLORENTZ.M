function f = florentz (x,y,p)
%----------------------------------------------------------
% FLORENTZ.M
% calculates a Lorentzian with parameter par
%
% usage:  f = florentz (x, [y,] p)
%
% input:  x     - calculate at these positions
%         y     - (in 2-D case)
%         p     -         1-D              2-D
%               p(1)  - position       X-position
%               p(2)  - width (FWHM)   Y-position
%               p(3)  - maximum        width (FWHM)
%               p(4)  - offset         maximum
%               p(5)  -                offset
%
% date: 4.1.1996
% author: ts
% version: <01.00> from <960104.0000>
%-----------------------------------------------------------
if nargin<2, help florentz, return, end

if nargin>2
  xpos = p(1);
  ypos = p(2);
  w    = p(3);
  h    = p(4);
  o    = p(5);
else
  xpos = y(1);
  ypos = 0;
  w    = y(2);
  h    = y(3);
  o    = y(4);
  y    = 0;
end

%calculate the distance-matrix
x1 = reshape(x,1,length(x));
y  = reshape(y,length(y),1);
r = (ones(length(y),1)*(x1-xpos)).^2 + ...
    ((y-ypos)*ones(1,length(x))).^2;

%calculate the Lorentzian in one call
b = w^2 / 4;
f = o + h ./ (r + b) ;

if nargin<3
  f = reshape (f,size(x,1),size(x,2));
end
