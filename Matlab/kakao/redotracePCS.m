
function [tdat,MeanD] = redotracePCS (file, D, cutoffs, Opts,saveopt,blink)
% function [tdat,MeanD] = redotracePCS (file, D, cutoffs, Opts,saveopt,blink)
% !!!! aux dimensions des images (d�finies au d�but du programme).
disp('!!! Utilise newMSD qui ne calcule que les 150 premiers points du msd cf dans le prog');
% if blink ==1, remove blinking traces
% diffusion analysis using different D (pxl/timelag) values
% read-in peakdata of selected peakfiles
% save teh new trace IN ONE FILE if saveopt==1
% generate new trace data using input D value
% generate new msd data using these new trace data
% save new trace file and msd file
% save file 'msd_data' which is a matrix [msd (pxl), error (pxl)]



if nargin<3
   cutoffs=[1/3 1000 100];
end

if nargin<5
   saveopt=0;
end

if nargin<6
   blink=0;
end
%dimension des images
[d p t c]=userdataread(file);

Xdim=p(1);
Ydim=p(2)/p(4);
clear d, p, t, c;

files=sbe(file,1);
savename=[file];
pkdata=[];
maxim=0;

files;

for k=1:length(files)
   %str=['pk\',files(k).name,'.pk'];
   str=[files(k).name,'.pk']
      if length(dir('pk'))>0		% is there new peakdata?
      cd pk
      Spkdata =load(str);
      cd ..
      SPok=1;
   else
      Spkdata=[];
      SPok=0;
   end
   if SPok>0
      Spkdata(:,1)=Spkdata(:,1)+maxim;		% new imagenumber
   end
   disp(['*  ',num2str(length(Spkdata)),' peaks in file ',files(k).name,sprintf(' (%d/%d)',k,length(files))]);
   pkdata=[pkdata; Spkdata];
   
   if ~isempty(pkdata)
      maxim=max(pkdata(:,1))+20;
   end
end

disp(['Il y a ',num2str(size(pkdata,1)),' pics avant cutoffs.']);
pkdata=clearpk(pkdata,1,Opts(18)); % vire les peaks dont les largeurs sont en dehors de [1., Opts(18)]
pkind = find(pkdata(:,10)<(pkdata(:,5)*cutoffs(1)) & pkdata(:,5)> 0 & pkdata(:,5)< cutoffs(2)) ;
pkdata = pkdata(pkind,:);
disp(['Reste ',num2str(size(pkdata,1)),' pics apr�s cutoffs.']);


if saveopt==1
[NTrace,TraceData]=seqtrace(pkdata,max(pkdata(:,1)),D,Xdim,Ydim,Opts,savename);
else
[NTrace,TraceData]=seqtrace(pkdata,max(pkdata(:,1)),D,Xdim,Ydim,Opts);
end
inddata=traceind(pkdata,TraceData);
ntrclen=sum(inddata(:,2:end)>0,2);

nTracedata=[];
ok=0;
if blink==1
    for i=1:NTrace
        if ntrclen(i)<=cutoffs(3) %filters the traces > cutoffs(3)
            k=TraceData(TraceData(:,1)==i,:);
            if ( k(end,2)-k(1,2)==ntrclen(i)-0 ) %keeps only the traces with no missing peaks
                nTracedata=[nTracedata;k]; 
                ok=ok+1;
            else 
                if ( k(end,2)-k(1,2)==ntrclen(i)-1 )  %allow the traces with one missing peak
                    nTracedata=[nTracedata;k]; 
                    ok=ok+1;
                else 
                    if ( k(end,2)-k(1,2)==ntrclen(i)-2 )  %allow the traces with two missing peaks
                        nTracedata=[nTracedata;k]; 
                        ok=ok+1;
                    else 
                        if ( k(end,2)-k(1,2)==ntrclen(i)-3 )  %allow the traces with 3 missing peaks
                            nTracedata=[nTracedata;k]; 
                            ok=ok+1;
                        end
                    end
                end
            end
        end 
    end
    TraceData=nTracedata;
    disp([num2str(NTrace),' traces trouv�es au d�part et ',num2str(NTrace-ok),' traces perdues par blinking dans redotraceLG.']);
    else
        TraceData;
        disp(['On n''a pas fait de test sur le blinking dans redotraceLG : on garde les ' num2str(NTrace) ' traces.']);
end

if NTrace>0
   [msddata, fullmsddata]=newMSD(TraceData,150); %%%%%%%%%%% !!! MSD de 150 points au max
  	ind = 1:size(msddata,1);
   Diff  = msddata(ind,3) ./ msddata(ind,2) / 4;
	dDiff = msddata(ind,4) ./ msddata(ind,2) / 4;
	MaxTrc = max(msddata(:,2)) ;
	MeanD  = mean(Diff);
   StdD = std(Diff);
      
    %-------------------------------------------------
%save everything to <file>.msd
%if mode==1 
save(['msd/',savename,'.msd'],'msddata','-ascii');      


   
   ntrc=min(min(size(fullmsddata,2),cutoffs(3)),150); %%%%%%%%%%% !!! MSD de 150 points au max
   tdat=[0 0 0];
   for noz=1:ntrc
      val=fullmsddata(:,noz); val=val(val>0);
      if length(val)>0
         tdat=[tdat;[mean(val), std(val)/sqrt(length(val)), length(val)]];
      else
         tdat=[tdat;[0 0 0]];
      end
   end
   
     
else
   disp('Sorry, no traces found');
end
	