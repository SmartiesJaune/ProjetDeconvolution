function Res = MyFFT2(Data,N,M)	

%
% Data:img
% N:taille verticale
% M:taille horizontale

% Quelques tests
	if nargin~=3
	error('Ne sait faire que si 3 arguments en entrée')
	end

% Quelques tests
	if size(Data,1)~=size(Data,2)
	error('Ne sait faire que si matrice carrée')
	end

% Quelques tests
	if N~=M
	error('Ne sait faire que si sortie carrée')
	end

% Quelques tests
	if size(Data,1)>N
	error('Ne sait faire que si on va vers plus de points')
	end

% Calcul
	Res = fft2(Data,N,N)/N;
