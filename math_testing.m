% % let's assume Cm = sin(x)
% % dy/dt = (sin(t)-2)(-1/T)
% 
% 
% f = @(t) 20 + (t^2 - 15*sin(t/1000))*exp(-t/8);
% 
% t = 1:50;
% points = 20 + (t.^pi - 5).*exp(-t/8);
% 
% plot(points)

c0 = pi;
h = 50;
dt = 1;
t = 1000; % (100*10) since dt is 100, 10 steps is nice
dz = 1;
Kappa = .9; % idk ? (m/s)


matrix = ones(h,t);
matrix = ones(h, t);
matrix(:,1) = c0;
matrix(h,:) = 0;
matrix(1,:) = 1;

tic
for frame = 2:dt:t-1
    for height = 1:dz:h-1
       matrix(height+1,frame) = matrix(height,frame) + Kappa * dt/dz^2*(matrix(height,frame+1) - 2*matrix(height,frame) + matrix(height,frame-1));
    end
end
toc

figure
hold on
for x = 1:48 
    scatter(x,matrix(x+1,x))
    x1 = [0,x,x+1,0];
    y1 = [matrix(x+2,x+1),matrix(x+2,x+1),matrix(x+1,x),matrix(x+1,x)];
    patch(x1,y1,256*pi/matrix(x+1,x),'edgecolor', 'none');
end


% matrix = ones(h, t);
% matrix(:,1) = c0;
% matrix(h,:) = 0;
% matrix(1,:) = 1;    ix = [ii ii+1 N-ii N-ii+1];
% 
% 
% for frame = 1:dt:t
%     for height = 1:h
%         matrix(frame, height+1) = matrix(frame,height) + Kappa * dt/dz^2 * ( matrix(frame+1,height) - 2*matrix(frame,height) + matrix(frame - 1,height)); 
%     end
% end

% c(i,j+1) = c(i,j) + K * dt/dz^2 * ( c(i+1,j) - 2*c(i,j) + c(i-1,j) )
% k =  1E-3
% dz = 1
% h = 50
% dt = 50





