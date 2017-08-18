%%%=SETTINGS=%%%
save_to_file = 1;
playback_dt = 10;

g = 9.81;
dt = .001;

dx = 1;
dz = 1;
nc = 100; % number of coloumns
ni = 8000; % time iterations
depth = 100;
%%%=INITLIALIZE=%%%
u = ones(ni,nc+1);
zeta = zeros(ni,nc);

for i = 1:nc
    zeta(1,i) = 15*exp(-((i-nc/2)/(nc/10))^2)+sin(i/nc*3+rand/100)*(5+rand/5);    
end

for i = 1:nc+1
    u(1,i) = sin(i/nc*3+rand/100)*(3);
end

u(:,1) = 0; % wall boundaries
u(:,nc+1) = 0;
%%%=CALCULATE=%%%

for t = 2:1:ni
    % stepping time 

    for c2 = 1:nc
        % adjust heights
        d = depth - (15*sin(c2)+log(c2.^2+1)*9*exp(-c2.^2/3000)+1);
        % zeta(t, c2) = -d*dt*( u(t-1, c2+1) - u(t-1, c2))/dz + zeta(t-1, c2);
        % I was testing variable depth ^ 
        % https://www.desmos.com/calculator/nmj3rr6egqr
        
        zeta(t, c2) = -d*dt*( u(t-1, c2+1) - u(t-1, c2))/dz + zeta(t-1, c2);
        %zeta(t, c2) = -depth*dt*( u(t-1, c2+1) - u(t-1, c2))/dz + zeta(t-1, c2);
    end
    
    for c = 2:nc 
        % note that the actual length of u is nc+1 -we are keeping the left and right sides as 0
        % adjust velocities
        % u(t, c) = -g*dt*(zeta(t-1, c)-zeta(t-1, c-1))/dx + u(t-1, c);
        
        % leap-frogging
        u(t,c) = -g*dt*(zeta(t, c)-zeta(t, c-1))/dx + u(t-1, c);
    end  
end

try 
    delete('/home/jeffxy/Documents/nice waves.avi');
catch
    disp('ok');
end


if save_to_file

    vidObj = VideoWriter('nice waves');
    open(vidObj);
    figure
    x = 1:ni;
    y = (15*sin(x)+log(x.^2+1).*9.*exp(-x.^2/3000)+1);
    
    
    for i = 1:playback_dt:ni
        plot(depth+zeta(i,:));
        hold on
        plot(x,y)
        hold off
        axis([0 nc 0 depth + 26 ])
        F(i) = getframe(gcf);
        writeVideo(vidObj,F(i));
    end
    close(vidObj)

else    

    figure
    x = 1:ni;
    y = (15*sin(x)+log(x.^2+1).*9.*exp(-x.^2/3000)+1);
    
    for i = 1:playback_dt:ni 
        plot(depth+zeta(i,:));
        hold on
        plot(x,y)
        hold off
        axis([0 nc 0 depth + 26 ])
        pause(0);
    end

end
display('Done!');
close all;




