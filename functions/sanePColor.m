function p = sanePColor(varargin)
%SANEPCOLOR  simple wrapper for pcolor
%
% Unlike the built-in pcolor command, this function does not "cut off" the
% last row and column of the input matrix.  In this way, sanePColor is
% intended to be as easy to use as imagesc, but allows the user to specify
% the x and y coordinates of each cell if desired.  This function is also
% useful as an alternative means of generating images to print to PDF that
% are compatible with OS X's "Preview" PDF viewer (imagesc images appear
% "blurred" when printing to a PDF as a vector graphic and viewed using
% Preview).
%
% Usage: p = sanePColor(x,y,z)
%
%INPUTS:
%
%    x: an array of sorted x values.  can also specify a min and max x value.
%       these values correspond to columns of z. [IF THIS ARGUMENT IS USED,
%       MUST ALSO SPECIFY Y VALUES.]
% 
%    y: an array of sorted y values.  can also specify a min and max y value.
%       these values correspond to rows of z.  [IF THIS ARGUMENT IS USED,
%       MUST ALSO SPECIFY X VALUES.]
% 
%    z: a 2d matrix of values.  this matrix determines the color at each
%       point.
% 
%OUTPUTS:
%
%    p: a handle to the resulting pcolor image.
%
% EXAMPLE:
%
%   m = membrane;
%   p = sanePColor(m);
%
% SEE ALSO: PCOLOR, IMAGE, IMAGESC, SEMILOGX, SEMILOGY, LOGLOG, PADARRAY
%
%   AUTHOR: JEREMY R. MANNING
%  CONTACT: manning3@princeton.edu


%CHANGELOG
%3-16-10    JRM      Wrote it.
%3-12-12    JRM      Support a more diverse range of input configurations.
%9-21-12    JRM      Use linear and logistic interpolation to estimate data
%                    coordinates more accurately.
%06-12-14   Daniele Bianchi - removed logarithm options
%                             changed axis polinomial interpolation to difference scheme

%parse arguments
if length(varargin) == 1 %just z
    z = varargin{1};
    x = 1:size(z,2);
    y = 1:size(z,1);
elseif (length(varargin) >= 3) %x, y, z, logx, and possibly logy
    x = varargin{1};    
    y = varargin{2};    
    z = varargin{3};    
else %length(varargin) == 2
    if isempty(varargin)
        fprintf('\nUsage: p = sanePColor([x,y],z,[logx],[logy]);\n');
        fprintf('Type ''help %s'' for more info.\n\n',mfilename);
        p = [];
        return;
    end
end

assert(length(x) == size(z,2),'length(x) must equal size(z,2)');
assert(length(y) == size(z,1),'length(y) must equal size(z,1)');

z1 = padarray(z,[1 1],'replicate','post');

% Estimates the new x and y with simple differencing
xvar = x(:);
nx = length(xvar);
dx = diff(xvar);
xvect = xvar(1:end-1) + dx/2;
xvect = [xvar(1)-dx(1)/2;xvect];
xvect = [xvect;xvar(end)+dx(end)/2];

yvar = y(:);
ny = length(yvar);
dy = diff(yvar);
yvect = yvar(1:end-1) + dy/2;
yvect = [yvar(1)-dy(1)/2;yvect];
yvect = [yvect;yvar(end)+dy(end)/2];

p = pcolor(xvect,yvect,z1);
