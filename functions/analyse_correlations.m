 
 

 % Brute force & sloppy - calculate all correlations one by one (redundant as it's also symmetric)

 vnames = {'temp','salt','dic','alk','no3','po4','pco2'};
 nvar = length(vnames);

 % Initializes matrices for output
 CorrMatrix = nan(nvar,nvar);
 ProbMatrix = nan(nvar,nvar);

 for indi=1:nvar
    for indj=1:nvar
       [thisCorr thisProb] = corr(smbo.(vnames{indi})(:),smbo.(vnames{indj})(:),'rows','complete');
       CorrMatrix(indi,indj) = thisCorr;
       ProbMatrix(indi,indj) = thisProb;
      %if indi==indj
      %   ProbMatrix(indi,indj) = 1;
      %end
    end
 end
 ACorrMatrix = abs(CorrMatrix);

 pvalue = 0.01;

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

 figure
 hh = sanePColor(xvect2,xvect1,ACorrMatrix1);
 set(groot, 'defaultAxesTickLabelInterpreter','none')
 set(gca,'xtick',xvect2,'xticklabel',vnames2,'fontsize',14);
 set(gca,'ytick',xvect1,'yticklabel',vnames1,'fontsize',14);
 set(gca,'XTickLabelRotation',90);
 colormap(mycolormaps('scheme','jetfirstwhite'))
 colorbar
 caxis([0 1.0]);
 title([comp_name],'interpreter','none');
 mprint_fig('name',['cor_' comp_name ],'for','epsc','sty','nor1')

