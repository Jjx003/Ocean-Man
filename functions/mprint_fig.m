function mprint_fig(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% default arguments:
A.fig       = - 1;
A.sty       = 'nor';
A.name       = 'figure';
A.for       = 'jpeg';
% Parse required variables, substituting defaults where necessary
Param = parse_pv_pairs(A, varargin);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(Param.for,'jpg')
   Param.for = 'jpeg';
end


if strcmp(Param.name,'figure')&Param.fig~=-1
    Param.name = ['figure' num2str(Param.fig)];
end

if Param.fig~=-1
   figure(Param.fig);
end

if strcmp(Param.sty,'nor') | strcmp(Param.sty,'nor1')  
   disp('Normal-1')
   set(gcf,'PaperPosition',[0.5 0.5 8.0 6.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor2') 
   disp('Normal-2')
   set(gcf,'PaperPosition',[0.5 0.5 6.0 8.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor2b') 
   disp('Normal-2')
   set(gcf,'PaperPosition',[0.5 0.5 6.0 14.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor2d') 
   disp('Normal-2')
   set(gcf,'PaperPosition',[0.5 0.5 2*6.0 4.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor3') 
   disp('Normal-3')
   set(gcf,'PaperPosition',[0.5 0.5 6.0 5.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor3b') 
   disp('Normal-3')
   set(gcf,'PaperPosition',[0.5 0.5 6.0 4.5],'Renderer','Painters');
elseif strcmp(Param.sty,'nor4') 
   disp('Normal-4')
   set(gcf,'PaperPosition',[0.5 0.5 5.0 6.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor5') 
   disp('Normal-5')
   set(gcf,'PaperPosition',[0.5 0.5 4.0 3.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor6') 
   disp('Normal-6')
   set(gcf,'PaperPosition',[0.5 0.5 3.0 4.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor7') 
   disp('Normal-7')
   set(gcf,'PaperPosition',[0.5 0.5 10.0 6.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor7b') 
   disp('Normal-7')
   set(gcf,'PaperPosition',[0.5 0.5 9.0 6.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor7c') 
   disp('Normal-7')
   set(gcf,'PaperPosition',[0.5 0.5 20.0 6.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor7c1') 
   disp('Normal-7')
   set(gcf,'PaperPosition',[0.5 0.5 16.0 6.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor7c2') 
   disp('Normal-7')
   set(gcf,'PaperPosition',[0.5 0.5 16.0 9.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor7d') 
   disp('Normal-7')
   set(gcf,'PaperPosition',[0.5 0.5 10.0 6.5],'Renderer','Painters');
elseif strcmp(Param.sty,'nor7e') 
   disp('Normal-7e')
   set(gcf,'PaperPosition',[0.5 0.5 12.0 6.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor7f') 
   disp('Normal-7f')
   set(gcf,'PaperPosition',[0.5 0.5 12.0 9.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor7g') 
   disp('Normal-7g')
   set(gcf,'PaperPosition',[0.5 0.5 14.0 9.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor8') 
   disp('Normal-8')
   set(gcf,'PaperPosition',[0.5 0.5 9.0 10.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor8b2') 
   disp('Normal-8b')
   set(gcf,'PaperPosition',[0.5 0.5 7.0 7.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor8b') 
   disp('Normal-8b')
   set(gcf,'PaperPosition',[0.5 0.5 9.0 9.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor8c') 
   disp('Normal-8b')
   set(gcf,'PaperPosition',[0.5 0.5 8.0 14.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor9') 
   disp('Normal-9')
   set(gcf,'PaperPosition',[0.5 0.5 6.0 9.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor10') 
   disp('Normal-10')
   set(gcf,'PaperPosition',[0.5 0.5 15.0 9.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor11') 
   disp('Normal-7')
   set(gcf,'PaperPosition',[0.5 0.5 9.0 6.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor12') 
   disp('Normal-12')
   set(gcf,'PaperPosition',[0.5 0.5 11.0 9.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor13') 
   disp('Normal-13')
   set(gcf,'PaperPosition',[0.5 0.5 9.0 12.0],'Renderer','Painters');
elseif strcmp(Param.sty,'nor13b') 
   disp('Normal-13b')
   set(gcf,'PaperPosition',[0.5 0.5 12 13],'Renderer','Painters');
elseif strcmp(Param.sty,'nor14') 
   disp('Normal-14')
   set(gcf,'PaperPosition',[0.5 0.5 20.0 12.0],'Renderer','Painters');
elseif strcmp(Param.sty,'sq1') 
   disp('Square-1')
   set(gcf,'PaperPosition',[0.5 0.5 6.0 4.8],'Renderer','Painters');
elseif strcmp(Param.sty,'sq2') 
   disp('Square-2')
   set(gcf,'PaperPosition',[0.5 0.5 8.0 6.4],'Renderer','Painters');
elseif strcmp(Param.sty,'sq3') 
   disp('Square-3')
   set(gcf,'PaperPosition',[0.5 0.5 12.0 10.5],'Renderer','Painters');
elseif strcmp(Param.sty,'pdf_land') 
   disp('PDF landscape')
   set(gcf,'PaperPosition',[0.2 3.0 8.0 6.0],'Renderer','Painters');
elseif strcmp(Param.sty,'pdf_prof') 
   disp('PDF profile')
   set(gcf,'PaperPosition',[0.0 0.0 9.0 11.5],'Renderer','Painters');
else 
  error(['invalid format']);
end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 disp(['print -d' Param.for ' ' Param.name ]);
 eval(['print -d' Param.for ' ' Param.name ]);
 if strcmp(Param.for,'psc')
    eval(['! gv '  Param.name ' &']);
 end
 return

