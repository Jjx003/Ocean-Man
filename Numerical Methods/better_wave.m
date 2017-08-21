g = 9.81;

dt = .01;

dx = 1;

dz = 1;

nc = 200; % number of coloumns

ni = 5000; % time iterations

depth = 100;

nonlinear = 1; %%% Set true to include nonlinear terms, i.e. du/dt + u du/dx + g dz/dx = 0 and dz/dt + d/dx ( (H+z) u ) = 0

godunov = 1; %%% Set true to use godunov method (shock-resolving) 

leapfrog = 1; %%% Set true to offset u and zeta in time, increasing the accuracy of the time-stepping to second order

%% INITLIALIZE %%

u = ones(ni,nc+1);

zeta = zeros(ni,nc);

KE = zeros(ni,1);

PE = zeros(ni,1);

%% CALCULATE %%

for i = 1:nc

    zeta(1,i) = 20*exp(-((i-nc/2)/(nc/10))^2);

end

for i = 1:nc+1

    %u(1,i) = 1;%5*exp(-i^2/200)+sin(3*i/nc);
    u(1,i) = 0;
end

u(:,1) = 0; % wall boundaries

u(:,nc+1) = 0;

for t = 2:1:ni

    %%% SSH on velocity points

    zeta_u = zeros(1,nc+1);
    if (nonlinear)
        %%% Upwind interpolation of zeta to u-points

        if (godunov)
            zeta_u(2:nc) = 0.5*( zeta(t-1,1:nc-1)+zeta(t-1,2:nc) - sign(u(t-1,2:nc)).*(zeta(t-1,2:nc)-zeta(t-1,1:nc-1)) );
        %%% Centered approximation of zeta on u-points
        else
            zeta_u(2:nc) = 0.5*(zeta(t-1,1:nc-1)+zeta(t-1,2:nc));
        end
    end        

    % stepping time
    
    for c2 = 1:nc
        zeta(t, c2) = -dt*((depth+zeta_u(c2+1))*u(t-1, c2+1) - (depth+zeta_u(c2))*u(t-1, c2))/dz + zeta(t-1, c2);
    end   

    for c = 2:nc 
        %%% Add pressure gradient term
        if (leapfrog)
            %%% Use already-updated zeta to calculate pressure gradient.
            %%% Effectively assumes that u and zeta points are offset by
            %%% 1/2 a time step.
            du_dt = -g*(zeta(t, c)-zeta(t, c-1))/dx;
        else
            %%% Forward Euler time differencing
            du_dt = -g*(zeta(t-1, c)-zeta(t-1, c-1))/dx;
        end
        %%% Adds nonlinear advection term

        if (nonlinear)          
            %%% Upwind differencing to approximate derivative of u
            if (godunov)
                adv_l(2:nc) = (u(t-1,c)-u(t-1,c-1)) / dx;
                adv_r(2:nc) = (u(t-1,c+1)-u(t-1,c)) / dx;
                du_dt = du_dt - 0.5*( u(t-1,c)*(adv_l(c)+adv_r(c)) - abs(u(t-1,c))*(adv_r(c)-adv_l(c)) );
            %%% Fornberg (1973) energy-conserving discretization
            else
                du_dt = du_dt - (1/3) * (u(t-1,c+1).^2-u(t-1,c-1).^2) / (2*dx) - (1/3) * u(t-1,c) .* (u(t-1,c+1)-u(t-1,c-1)) / (2*dx); 
            end
        end

        % note that the actual length of u is nc+1 -we are keeping the left and right sides as 0
        % adjust velocities
        u(t, c) = u(t-1, c) + dt * du_dt;

    end      

end

 

PE = sum(0.5*g*zeta.^2,2);

KE = sum(0.5*depth*u.^2,2);

 

%% DRAW %%

    figure

    for i = 1:5:ni

        plot(depth+zeta(i,:));

        axis([0 nc 0 depth + 26 ])

        pause(0);

    end