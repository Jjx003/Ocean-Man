
g = 9.81;
dt = 1;
dx = 1;
dz = 1;
nc = 30; % number of coloumns
ni = 700; % time iterations
depth = 120;
% depth = @(x) 2*x;

u = ones(ni,nc + 1) * 5;
u(:,1) = 0; % wall boundaries
u(:,nc) = 0;

zeta = zeros(ni,nc);
for i = 1:nc
    zeta(1,i) = 1 + 4 * sin(3*i/(nc));
    u(1,i+1) = zeta(1,i);
end
plot(zeta(1,:))

step = 1;

for t = 1:dt:ni-1 
    % stepping time 
    for c = 2:nc-1
        % stepping coloumns

        u(t+1, c) = -g*dt*(zeta(t, c+1)-zeta(t, c))/dx + u(t, c);
        
        zeta(t+1, c) = -depth*dt*( u(t, c+1) - u(t, c))/dz + zeta(t, c);
        
        
%         -g*dt*(zeta(t, c+1)-zeta(t, c))/dx 
%         u(t, c)
%         -depth*dt*( u(t, c+1) - u(t, c))/dz 
%         zeta(t, c)
    end
    
end

figure
axis tight
set(gca,'nextplot','replacechildren');
for i = 2:ni
    plot(zeta(i,:));
    F(i) = getframe(gcf);
    %writeVideo(vidObj,F(i));
    disp('');
end

