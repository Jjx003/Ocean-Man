function Cw = CalculateCw(Cm,window,tau,n)
    % tau ~ 120-150, 130 is best?
    
    Cw = [];
    time = 1:length(window);

    nv = length(window);
    wsiz = 3;
    sh = round((wsiz-1)/2);


    for i=wsiz:nv-wsiz
        syms t;
        domain = i-sh:i+sh;
        wi = window(domain);
        ti = time(domain);
        co = polyfit(ti,wi,n);
        t = .5 * (max(wi)-min(wi));
        
        if n == 1
            e = co(1);
        elseif n == 2 
            e = 2*co(1)*t + co(2);
        elseif n == 3
            e = 3*co(1)*t^2 + 2*co(1)*t + co(3);
        end
        dCm = e;
        Cw(i) = Cm + tau * dCm;

    end
    
    Cw(isnan(Cw)) = [];
    windowSize = 5; 
    
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    Cw = filter(b,a,Cw);
    
        
% plot(c(6800)-CalculateCw(c(6400),c(6400:6600),140,1))
    
% 	dist = window(nv)-Cw;
% 	avg_dist = abs(mean(dist));
% 	if avg_dist <= 8 
%         disp('aaaa');
%         disp(avg_dist)
%     else
%         disp('u fail');
%     end
%     
% 	figure
% 	plot(Cw)
% 	figure 
% 	plot(dist)
%     hold on
%     plot(avg_dist)
%     hold off
    
    
    