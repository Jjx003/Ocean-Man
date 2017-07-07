

function [CorrMatrix ProbMatrix hfig] = analyze_correlations(data,varargin)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Given a structure with a set of fields that are vectors o the same length
 % calculats pairwise correlations and plots them as a checkered matrix
 % Usage: plot_map_projection(data);
 % Usage: [CorrMatrix ProbMatrix] = plot_map_projection(data,'var',{'var1','var2','var3',...})
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 A.var = 'all';		% 'all': uses all variables in dataset
 A.pvalue = 0.01;	% 0.01: Threshold for significance (p<pvalue: significant)
 A.removediag = 1;	% 1: Remove diagonal correlations (set to NaN instead of 1)
 A.absval = 0;		% 1: Shows absolute value of correlation
 A.fig = 1;		% 1: Plots a figure
 A.printfig = 0;	% 1: Prints a figure
 A.figfor = 'epsc';	% 1: Figure format
 A.figname = 'fig_correlations';	% Figure name
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 A = parse_pv_pairs(A, varargin);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Brute force & sloppy - calculate all correlations one by one (redundant as it's also symmetric)
 if strcmp(A.var,'all')
    % Uses all fields in data
    vnames = fieldnames(data);
 else
    % uses selected fields
    vnames = {'pCO2_1','PCO2_2','salts','temps','lons','lats'};
 end
 nvar = length(vnames);

 % Checks variables are numeric and have the same size
 % uses the most common size and removes the rest
 tmpisnum = zeros(1,nvar);
 tmplengt = nan(1,nvar);
 tmpwidth = nan(1,nvar);
 tmpndims = nan(1,nvar);
 for indv=1:nvar
   if isnumeric(data.(vnames{indv})) 
      tmpisnum(indv) = 1;
   end
   tmpndims(indv) = ndims(data.(vnames{indv}));
   tmplengt(indv) = length(data.(vnames{indv}));
   % check that data is vector but not array
   tmp = sort(size(data.(vnames{indv})),'descend');
   tmpwidth(indv) = tmp(2);  
 end
 iuse = (tmplengt == mode(tmplengt)) & (tmpwidth==1) & (tmpndims==2) & tmpisnum;
 vnames = vnames(iuse);
 nvar = length(vnames);

 % Initializes matrices for output
 CorrMatrix = nan(nvar,nvar);
 ProbMatrix = nan(nvar,nvar);

 for indi=1:nvar
    for indj=1:nvar
       [thisCorr thisProb] = corr(data.(vnames{indi})(:),data.(vnames{indj})(:),'rows','complete');
       CorrMatrix(indi,indj) = thisCorr;
       ProbMatrix(indi,indj) = thisProb;
       if indi==indj
          if A.removediag==1
             ProbMatrix(indi,indj) = NaN;
          end
       end
    end
 end
 ACorrMatrix = abs(CorrMatrix);

 pvalue = A.pvalue;

 GoodMatrix = real(ProbMatrix<pvalue);
 GoodMatrix(GoodMatrix==0) = nan;

 CorrMatrix = CorrMatrix .* GoodMatrix;
 ACorrMatrix = ACorrMatrix .* GoodMatrix;

 xvect1 = [1:nvar];
 xvect2 = [1:nvar];
 vnames1 = vnames;
 vnames2 = vnames;
 CorrMatrix1 = CorrMatrix;
 ACorrMatrix1 = ACorrMatrix;

 if A.fig==1
    hfig = figure;
    if A.absval==1
       hh = sanePColor(xvect2,xvect1,ACorrMatrix1);
       caxis([0 1.0]);
       colormap(mycolormaps('scheme','jetfirstwhite'))
       title('correlation R (absolute val)','interpreter','none');
    else
       hh = sanePColor(xvect2,xvect1,CorrMatrix1);
       caxis([-1.0 1.0]);
       colormap(mycolormaps('scheme','redblue'))
       title('correlation R','interpreter','none');
    end
    set(groot, 'defaultAxesTickLabelInterpreter','none')
    set(gca,'xtick',xvect2,'xticklabel',vnames2,'fontsize',14);
    set(gca,'ytick',xvect1,'yticklabel',vnames1,'fontsize',14);
    set(gca,'XTickLabelRotation',90);
    colorbar
    box on;
    if A.printfig==1
       mprint_fig('name',A.figname,'for',A.figfor,'sty','nor1')
    end
 end

