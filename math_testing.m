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


c0 = 50;
h = 25;

dz = 1;
Kappa = 1E-3; % idk ? (m^2/s)
t = (h^2)/Kappa; % (100*10) since dt is 100, 10 steps is nice
dt = .5*(dz^2)/Kappa-20;

% boundary conditions?
matrix = ones(h,t);
matrix = ones(h, t);
matrix(:,1) = c0;
matrix(h,:) = 0;
matrix(1,:) = 1;   

actual_time = 1;

indicies = t/dt;

for time = 1:dt:t-1
    actual_depth = 1;
    for depth = 2:dz:h-1 
        actual_depth = actual_depth + 1;
    	matrix(actual_depth,actual_time+1) = matrix(actual_depth,actual_time)...
        + Kappa * (dt/dz^2)*(matrix(actual_depth+1,actual_time) - 2*matrix(actual_depth,actual_time) + matrix(actual_depth-1,actual_time));
    end
	actual_time = actual_time+1;
end



selected = matrix(:,1:indicies);
axis tight
set(gca,'nextplot','replacechildren');
%vidObj = VideoWriter('peaks.avi');
%open(vidObj);

for i = 1:indicies
    plot(selected(:,i));
    F(i) = getframe(gcf);
    %writeVideo(vidObj,F(i));
end

disp('aaaaaa');

%close(vidObj);

figure
movie(F,2)
close all;


 
% for x = 1:48  
%     hold on
%     scatter(x,matrix(x+1,x))
% 	x1 = [0,x,x+1,0];
% 	y1 = [matrix(x+1,x),matrix(x+1,x),matrix(x+2,x+1),matrix(x+2,x+1)];
% 	patch(x1,y1,256*pi/matrix(x+1,x),'edgecolor', 'none');
% end



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





