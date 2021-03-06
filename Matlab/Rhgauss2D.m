function [ R ] = Rhgauss2D(data,p0,dim_h,dim_v,power)
%%Calcule la gaussienne en deux dimensions en utilisant des vecteurs 1D
%con�u pour �tre utilis� avec lsqnonlin
%data est de taille (1,dim_h*dim_v)
%R est de taille (1,dim_h*dim_v)
%%

x=zeros(1,dim_v*dim_h);
y=x;
for i=0:dim_v-1
    for j=1:dim_h
        x(1,i*dim_h+j)=i;
        y(1,i*dim_h+j)=j;
    end
end
%%
%x vaut 1 sur les dim_h premi�res cases, 2 entre dim_h+1 et 2*dim_h...
%y vaut 1 jusqu'� dim_h sur les dim_h premi�res cases puis repart � 1 etc..
%%
      
 r=sqrt((x-p0(3)).^2+(y-p0(4)).^2)/(sqrt(2)*p0(5));
 R=data-p0(1)-p0(2)*exp(-r.^power );
end