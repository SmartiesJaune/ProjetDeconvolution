%LOGICIEL DE TRAITEMENT D'IMAGE
% Adapt� � d�convolution et d�tection de gaussiennes/Airy

%De facon g�n�rale on manie des images de double, entre 0 et 1


%Derniere modif:
%images en cellule 
%n images en dynamique
% - incorporer la recherche automatiques des valeurs (seuil / sigma+lambda)

%a faire:

%
% - incorporation des algos contours et deconvolution...
% INCORPORER FITPEAK (dans function imgout = gui_fit(img,seuil)  )


% - histo sur R et I...
% changer noms
% log des operations
% -superpo des images en RGB
% -ouverture tif

%Utiliser des cellules pour enregistrer  les images ?
% plus souple pour appel (pas de switch case)

function varargout = Farview(varargin)
% FARVIEW MATLAB code for Farview.fig
%      FARVIEW, by itself, creates a new FARVIEW or raises the existing
%      singleton*.
%
%      H = FARVIEW returns the handle to a new FARVIEW or the handle to
%      the existing singleton*.
%
%      FARVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FARVIEW.M with the given input arguments.
%
%      FARVIEW('Property','Value',...) creates a new FARVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Farview_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Farview_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Farview

% Last Modified by GUIDE v2.5 18-Jan-2017 12:06:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Farview_OpeningFcn, ...
                   'gui_OutputFcn',  @Farview_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Farview is made visible.
function Farview_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Farview (see VARARGIN)

%VARIABLES
handles.imageisloaded=0;
handles.folderpath='No Path Chosen';
%les listes et images:
    handles.chosenimage=1;  %choix sur premiere liste
    handles.chosenimage2=2; %choix sur deuxieme liste
    handles.nimages=3;  %nombre d'images (pour version dynamique )
    handles.num=4; %numero donn� � la prochaine image qui sera cr��e

% handles.switchaxes=1; %varie entre axes 1 et 2 pour afficher images
%les sliders et lancement auto de la fonction:
    handles.slider_lambda=1;
    handles.slider_radius=1;
    handles.slider_seuil=1;
    handles.do_auto_dec=0;
    handles.do_auto_fit=0;
    handles.imgrgbinit=0;   %initier l'image RGB (zeros (size,3) )
    
cla(handles.axes1,'reset') %reset des axes
cla(handles.axes2,'reset') %reset des axes
% Choose default command line output for Farview
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Farview wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Farview_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.output;


%% LOAD & PATH


%


function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.folder_cal=uigetdir;
% guidata(hObject,handles); %sauvegarde le nouveau handle
% set(handles.edit_path, 'String', handles.folder_cal);

try
    [NomFic,NomEmp] = uigetfile({'*';'*.jpg';'*.png';'*.bmp'},'Choisissez une image',get(handles.edit_showpath,'String')); % Choisir une image 
catch
    [NomFic,NomEmp] = uigetfile({'*';'*.jpg';'*.png';'*.bmp'},'Choisissez une image'); % Choisir une image 
end
if(NomFic) %if a file has been chosen
    %CHARGEMENT IMAGE
        if(NomFic(end-3:end)=='.dat')
            %ouverture avec trackread
            [a,p,t,c,p2]=trackread([NomEmp,'\',NomFic]);
            img=(calcR(a)); %double
            handles.stepsize = p2.stepsize;
            set(handles.text_stepsize,'String',['stepsize: ',num2str(p2.stepsize), '�m/pix']);
            
            MAX=max(max(img))
            img=img/MAX;    %on met le maximum � 1
            
        else
            img=double(imread(strcat(NomEmp,NomFic)));
            try %if image has multiple arrays
                img=(img(:,:,1)+img(:,:,2)+img(:,:,3))/3/255; % 1:3 because of problem with tiff image
                %si img est double, rgb2gray donnera que des 1...
                'conversion en gris'
            end
            
            MAX=max(max(img))
            if(MAX>1)  
                %on fait un recalage de contraste entre min et 1
                img=img/MAX;
            end
        end
    
    % ON ATTRIBUE L'IMAGE A LIMAGE SELECTIONNEE DANS LISTE
    handles.img{handles.chosenimage}=img;
%     if((handles.imageisloaded==0)&(handles.chosenimage==1))
%         %si on a encore rien charg� et laiss� par d�faut, 
% %  on charge dans
% %         %toutes les images (juste pour cot� pratique)
% %         for(n=1:handles.nimages)
% %             handles.img{n}=img;
% %         end
% 
%     end

            contents = cellstr(get(handles.listbox_img,'String'));
            contents{handles.chosenimage}=NomFic;
            set(handles.listbox_img,'String',contents);
            set(handles.listbox_out,'String',contents);
            b=['Opening ',NomEmp,'\',NomFic,' '];
            handles.log{handles.chosenimage}=b;
            try
                editlog(handles);
            end

    axes(handles.axes1)
    imshow(img); title(NomFic);
    
    handles.folderpath=NomEmp;

    
    if(~handles.imageisloaded)  %si on avait pas charg� d'image avant, on va initialiser imgrgb avec 
        s=size(img)
        handles.imgrgb=zeros(s(1),s(2),3);
    end
    handles.imageisloaded=1;
    guidata(hObject,handles)
 
	addpath(NomEmp)
    set(handles.edit_showpath,'String',NomEmp);
    
end %else: no file chosen


function edit_showpath_Callback(hObject, eventdata, handles)
% hObject    handle to edit_showpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_showpath as text
%        str2double(get(hObject,'String')) returns contents of edit_showpath as a double
handles.folderpath=get(hObject,'String');

% --- Executes during object creation, after setting all properties.
function edit_showpath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_showpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%% LES LISTES

% --- Choix d'une image dans la liste:
% ( ! Au debut image X correspond au choix n�X et � handles.img{X}
% Mais si on supprime une image ca peut induire un d�calage.)
function listbox_img_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_img contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_img
% contents = cellstr(get(hObject,'String'))

choice=get(hObject,'Value');    % correspond � handles.img{choice}

contents=get(hObject,'String');  %
contents=contents{choice};     % nom de l'image
handles.chosenimage=choice;

% handles.switchaxes=mod(handles.switchaxes,2)+1; % on alterne pour afficher: 1 donne 2, 2 donne 1
% 
% %Affichage
% switch handles.switchaxes
%     case 1
%         axes(handles.axes1)
%     case 2
%         axes(handles.axes2)
% end
% choice3
axes(handles.axes1)
try
    imshow(handles.img{choice});
    title(contents);
end
editlog(handles)
guidata(hObject, handles);


% --- Liste des images
function listbox_img_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ( ! Au debut image X correspond au choix n�X et � handles.img{X}
% Mais si on supprime une image ca peut induire un d�calage.)
% --- Executes on selection change in listbox_out.
function listbox_out_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_out contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_out

choice=get(hObject,'Value');    % correspond � handles.img{choice}

contents=get(hObject,'String');  %
contents=contents{choice};
handles.chosenimage2=choice;
% handles.switchaxes=mod(handles.switchaxes,2)+1; % on alterne pour afficher: 1 donne 2, 2 donne 1
% 
% %Affichage
% switch handles.switchaxes
%     case 1
%         axes(handles.axes1)
%     case 2
%         axes(handles.axes2)
% end
% % choice3
axes(handles.axes2)
try
imshow(handles.img{choice});
title(contents);
end
guidata(hObject, handles);

  


% --- Executes during object creation, after setting all properties.
function listbox_out_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_out (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%% FIN DES LISTES


%% Basic operations

% --- Executes on button press in pushbutton_show.
function pushbutton_show_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_show (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure
imshow(handles.img{handles.chosenimage})



% --- Executes on button press in pushbutton_contrast.
function pushbutton_contrast_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        figure(1)
        imshow(uint8(handles.img{handles.chosenimage}*255))
        ht=imcontrast(gcf);
        
        uiwait
        F=getframe();
        test=frame2im(F);
        handles.img{handles.chosenimage2}=double(test(:,:,1))/255;
%         handles.img{handles.chosenimage}=F.cdata;
 
        handles.log{handles.chosenimage2}=[handles.log{handles.chosenimage}, 'contrasting']; % comment ajouter les min et max ?
        affichage(2,handles)
        close(figure())
guidata(hObject, handles);


% --- Executes on button press in pushbutton_crop.
function pushbutton_crop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure
        imshow(handles.img{handles.chosenimage})
        img=imcrop(handles.img{handles.chosenimage})
        handles.img{handles.chosenimage2}=img;
        handles.log{handles.chosenimage2}=[handles.log{handles.chosenimage}, ' cropped '];
        %ajouter les positions de crop ?
        affichage(2,handles)
guidata(hObject, handles);


% --- Executes on button press in pushbutton_log.
function pushbutton_log_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        img=log(1+(handles.img{handles.chosenimage}))/log(2);
        handles.img{handles.chosenimage2}=img;
        handles.log{handles.chosenimage2}=[handles.log{handles.chosenimage}, ' log '];
        affichage(2,handles)
guidata(hObject, handles);

warning('L''application du log peut influencer les parametres finaux du fit gaussien')

% --- Executes on button press in pushbutton_neg.
function pushbutton_neg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_neg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
img=handles.img{handles.chosenimage};
img=1-img;
handles.img{handles.chosenimage2}=img;
handles.log{handles.chosenimage2}=[handles.log{handles.chosenimage}, ' neg '];
affichage(2,handles)

guidata(hObject, handles);


% --- Executes on button press in pushbutton_gradient.
function pushbutton_gradient_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_gradient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

imgtemp=(handles.img{handles.chosenimage});
% [gx,gy]=gradient(double(imgtemp));
[gx,gy]=gradient((imgtemp));
imgtemp=(abs(gx+i*gy));
handles.img{handles.chosenimage2}=(imgtemp); %pb sur ce qu'on affiche en double ou uint8
% handles.img{handles.chosenimage}=sqrt(gx.^2+gy.^2); %idem
handles.log{handles.chosenimage2}=[handles.log{handles.chosenimage}, ' gradient '];
affichage(2,handles)
guidata(hObject, handles);


%% FIN BASIC OP



% --- Executes when figure1 is resized.



function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






%% Big Operations

% ---
% --- Executes on button press in pushbutton_deconv.
function pushbutton_deconv_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_deconv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
'lancement Deconvolution -----'

img=handles.img{handles.chosenimage};

handles.img{handles.chosenimage2}=gui_deconv(img , handles);

guidata(hObject, handles);






% --- Executes on button press in pushbutton_contours.
function pushbutton_contours_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_contours (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
'lancement algo Contours -----'
%%A MODIFIER


img=handles.img{handles.chosenimage};
handles.img{handles.chosenimage2} = gui_fit(img,handles);
handles.log{handles.chosenimage2}=[handles.log{handles.chosenimage}, ' Fit@seuil=',num2str(handles.slider_seuil)];



% handles.img{handles.chosenimage2}=imgout;


function pushbutton_trapide_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_trapide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
'lancement Traitement rapide'




% --- Executes on button press in pushbutton_arrow.
function pushbutton_arrow_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_arrow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

c1=handles.chosenimage;
c2=handles.chosenimage2;
handles.img{c2}=handles.img{c1};
affichage(2,handles)

%renommation:
    contents = cellstr(get(handles.listbox_img,'String'));
    if(c1~=c2) %on va avoir deux images meme nom -> on evite
        contents{c2}=[contents{c1},''''];
        set(handles.listbox_img,'String',contents);
        set(handles.listbox_out,'String',contents);
     %passage des logs:
        handles.log{handles.chosenimage2}=handles.log{handles.chosenimage};
    end

guidata(hObject, handles);



%% SLIDERS

% --- Executes on slider movement.
function slideroflambda_Callback(hObject, eventdata, handles)
% hObject    handle to slideroflambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
 value=(get(hObject, 'Value')); 

 handles.slider_lambda = value;
 set(handles.text_slider_lambda,'String',num2str(value)); %texte au dessus
 set(handles.edit_slider_lambda,'String',num2str(value)); %texte � cot�
  
 %fit auto
 if(handles.do_auto_dec)
    handles.img{handles.chosenimage2} =gui_deconv(handles.img{handles.chosenimage},handles);
    handles.log{handles.chosenimage2}=[handles.log{handles.chosenimage}, ' Dec@lambda=',num2str(value),'sigma=',num2str(handles.slider_radius)];
 end
 
 guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slideroflambda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slideroflambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% set the slider range and step size
 numSteps = 200;
 set(hObject, 'Min', 0);
 set(hObject, 'Max', 1);
 set(hObject, 'Value', 1);
 set(hObject, 'SliderStep', [1/(numSteps-1) , 1/(numSteps-1) ]);
 % save the current/last slider value
 handles.slider_lambda = 1;
 % Update handles structure
 guidata(hObject, handles);
 

 
% --- Executes on slider movement.
function sliderofradius_Callback(hObject, eventdata, handles)
% hObject    handle to sliderofradius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
 value=(get(hObject, 'Value')); 

 handles.slider_radius = value;
 set(handles.text_slider_radius,'String',num2str(value)); %texte au dessus
 set(handles.edit_slider_radius,'String',num2str(value));
 
  if(handles.do_auto_dec)
    handles.img{handles.chosenimage2} =gui_deconv(handles.img{handles.chosenimage},handles);
    handles.log{handles.chosenimage2}=[handles.log{handles.chosenimage}, ' Dec@lambda=',num2str(handles.slider_lambda),'sigma=',num2str(handles.slider_radius)];
 end
 
 %texte �cot�
 guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function sliderofradius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderofradius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
% set the slider range and step size
 numSteps = 1000;
 set(hObject, 'Min', 0);
 set(hObject, 'Max', 1);
 set(hObject, 'Value', 0.5);
 set(hObject, 'SliderStep', [1/(numSteps-1) , 1/(numSteps-1) ]);
 % save the current/last slider value
 handles.slider_radius = 1;
 % Update handles structure
 guidata(hObject, handles);


% --- Executes on slider movement.
function sliderofseuil_Callback(hObject, eventdata, handles)
% hObject    handle to sliderofseuil (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
 value=(get(hObject, 'Value')); 

 handles.slider_seuil = value;
 set(handles.text_slider_seuil,'String',num2str(value)); %texte au dessus
 set(handles.edit_slider_seuil,'String',num2str(value)); %texte �cot�
 
 %Fit auto:
 if(handles.do_auto_fit)
    handles.img{handles.chosenimage2} =gui_fit(handles.img{handles.chosenimage},handles);
    handles.log{handles.chosenimage2}=[handles.log{handles.chosenimage}, ' Fit@seuil=',num2str(handles.slider_seuil)];
 end
 
 guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function sliderofseuil_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderofseuil (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
 numSteps = 500;
 set(hObject, 'Min', 0);
 set(hObject, 'Max', 1);
 set(hObject, 'Value', 0.5);
 set(hObject, 'SliderStep', [1/(numSteps-1) , 1/(numSteps-1) ]);
 % save the current/last slider value
 handles.slider_seuil = 0.5;
 % Update handles structure
 guidata(hObject, handles);
 

function edit_slider_lambda_Callback(hObject, eventdata, handles)
% hObject    handle to edit_slider_lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_slider_lambda as text
%        str2double(get(hObject,'String')) returns contents of edit_slider_lambda as a double
value=get(hObject,'String');
value2=str2double(value);
if(~isnan(value2))
    set(handles.text_slider_lambda,'String',(value)); %texte au dessus
    set(hObject,'String',(value)); %texte �cot�
    %slider:
        if(value2>get(handles.slideroflambda,'Max'))
            set(handles.slideroflambda,'Value',get(handles.slideroflambda,'Max')); %slider � cot� max
        elseif(value2<get(handles.slideroflambda,'Min'))
            set(handles.slideroflambda,'Value',get(handles.slideroflambda,'Min')); %slider � cot� min
        else
            set(handles.slideroflambda,'Value',value2); %slider �cot�
        end
handles.slider_lambda=value2;

 if(handles.do_auto_dec)
    handles.img{handles.chosenimage2} =gui_deconv(handles.img{handles.chosenimage},handles);
    handles.log{handles.chosenimage2}=[handles.log{handles.chosenimage}, ' Dec@lambda=',num2str(handles.slider_lambda),'sigma=',num2str(handles.slider_radius)];
 end

guidata(hObject, handles);

else
    
end

% --- Executes during object creation, after setting all properties.
function edit_slider_lambda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_slider_lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_slider_radius_Callback(hObject, eventdata, handles)
% hObject    handle to edit_slider_radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_slider_radius as text
%        str2double(get(hObject,'String')) returns contents of edit_slider_radius as a double
value=get(hObject,'String');
value2=str2double(value);
if(~isnan(value2))
    set(handles.text_slider_radius,'String',(value)); %texte au dessus
    set(hObject,'String',(value)); %texte �cot�
    %slider:
        if(value2>get(handles.sliderofradius,'Max'))
            set(handles.sliderofradius,'Value',get(handles.sliderofradius,'Max')); %slider � cot� max
        elseif(value2<get(handles.sliderofradius,'Min'))
            set(handles.sliderofradius,'Value',get(handles.sliderofradius,'Min')); %slider � cot� min
        else
            set(handles.sliderofradius,'Value',value2); %slider �cot�
        end
handles.slider_radius=value2;

 if(handles.do_auto_dec)
    handles.img{handles.chosenimage2} =gui_deconv(handles.img{handles.chosenimage},handles);
    handles.log{handles.chosenimage2}=[handles.log{handles.chosenimage}, ' Dec@lambda=',num2str(handles.slider_lambda),'sigma=',num2str(handles.slider_radius)];
 end

guidata(hObject, handles);

else
    
end

% --- Executes during object creation, after setting all properties.
function edit_slider_radius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_slider_radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'BackgroundColor','white');


function edit_slider_seuil_Callback(hObject, eventdata, handles)
% hObject    handle to edit_slider_seuil (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_slider_seuil as text
%        str2double(get(hObject,'String')) returns contents of edit_slider_seuil as a double

value=get(hObject,'String');
value2=str2double(value);
if(~isnan(value2))
    set(handles.text_slider_seuil,'String',(value)); %texte au dessus
    set(hObject,'String',(value)); %texte �cot�
    %slider:
        if(value2>get(handles.sliderofseuil,'Max'))
            set(handles.sliderofseuil,'Value',get(handles.sliderofseuil,'Max')); %slider � cot� max
        elseif(value2<get(handles.sliderofseuil,'Min'))
            set(handles.sliderofseuil,'Value',get(handles.sliderofseuil,'Min')); %slider � cot� min
        else
            set(handles.sliderofseuil,'Value',value2); %slider �cot�
        end
handles.slider_seuil=value2;

%on lance le fit automatiquement:
if(handles.do_auto_fit)
    handles.img{handles.chosenimage2} =gui_fit(handles.img{handles.chosenimage},handles);
    handles.log{handles.chosenimage2}=[handles.log{handles.chosenimage}, ' Fit@seuil=',num2str(handles.slider_seuil)];
end


guidata(hObject, handles);

else
    
end


% --- Executes during object creation, after setting all properties.
function edit_slider_seuil_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_slider_seuil (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

 %% FIN SLIDER


% --- Executes on button press in pushbutton_add.
function pushbutton_add_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nimages=handles.nimages;
contents = cellstr(get(handles.listbox_img,'String'));
contents = [contents ;['Image ',num2str(handles.num)]] %ajout image X;
set(handles.listbox_img,'String',contents);
set(handles.listbox_out,'String',contents);
handles.nimages=nimages+1;
handles.num=handles.num+1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton_delete.
function pushbutton_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nimages=handles.nimages;
todelete=handles.chosenimage;

contents = cellstr(get(handles.listbox_img,'String'));
contents(todelete)=[];
set(handles.listbox_img,'String',contents);
set(handles.listbox_out,'String',contents);
handles.nimages=nimages-1;

%Replacement des Marqueurs:
if(handles.chosenimage2==todelete) 
    handles.chosenimage2=1;
    set(handles.listbox_out,'Value',1);
else
    set(handles.listbox_out,'Value',handles.chosenimage2);
end %si marqueur liste out sur img suprim�e on remet 1
handles.chosenimage=1; set(handles.listbox_img,'Value',1); %retourne le marqueur sur 1ere image
%fin replacement

guidata(hObject, handles);


%trouve automatiquement les valeurs biens
function pushbutton_autodec_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_autodec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

img=handles.img{handles.chosenimage};

% Valeurs automatiques:

radius=approxR( img , 20);
% x = -20:20; x=exp(-x.*x/radius/radius);
x = -20:20; x=exp(-x.*x/2/radius/radius)/sqrt(2*pi)/radius;
RI=transpose(x)*x;
D = [0 -1 0;-1 4 -1 ; 0 -1 0];   %filtre
lambda=filtreWienerAuto2(img,RI,D,50);

% %en attendant: (a supprimer) 
% lambda=handles.slider_lambda;
% radius=handles.slider_radius;

%Actualisation des valeurs trouv�es:
    set(handles.text_slider_lambda,'String',(lambda)); %texte au dessus
    set(handles.text_slider_radius,'String',(radius)); %texte au dessus
    set(handles.edit_slider_lambda,'String',(lambda)); %texte au dessus
    set(handles.edit_slider_radius,'String',(radius)); %texte au dessus
    
    %slider 1:
        if(lambda>get(handles.slideroflambda,'Max'))
            set(handles.slideroflambda,'Value',get(handles.slideroflambda,'Max')); %slider � cot� max
        elseif(lambda<get(handles.slideroflambda,'Min'))
            set(handles.slideroflambda,'Value',get(handles.slideroflambda,'Min')); %slider � cot� min
        else
            set(handles.slideroflambda,'Value',lambda); %slider �cot�
        end
    %slider 2:
        if(radius>get(handles.sliderofradius,'Max'))
            set(handles.sliderofradius,'Value',get(handles.sliderofradius,'Max')); %slider � cot� max
        elseif(radius<get(handles.sliderofradius,'Min'))
            set(handles.sliderofradius,'Value',get(handles.sliderofradius,'Min')); %slider � cot� min
        else
            set(handles.sliderofradius,'Value',radius); %slider �cot�
        end
        
handles.slider_lambda=lambda;
handles.slider_radius=radius;

%auto
 if(handles.do_auto_dec)
    handles.img{handles.chosenimage2} =gui_deconv(img,handles);
    handles.log{handles.chosenimage2}=[handles.log{handles.chosenimage}, ' Dec@lambda=',num2str(handles.slider_lambda),'sigma=',num2str(handles.slider_radius)];
 end


%fin actualisation ---
guidata(hObject, handles);

% Si coch�: on lance automatiquement la deconv a chaque changement valeur
function checkbox_autodec_Callback(hObject, ~, handles)
% hObject    handle to checkbox_autodec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_autodec
handles.do_auto_dec=get(hObject,'Value');
guidata(hObject, handles);

%trouve automatiquement les valeurs biens
function pushbutton_autocont_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_autocont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Give automatic values for threshold (seuil)

img=handles.img{handles.chosenimage};

value = graythresh(img); %regle d'Otsu pour le seuil


    set(handles.text_slider_seuil,'String',(value)); %texte au dessus
    set(handles.edit_slider_seuil,'String',(value)); %texte �cot�
    %slider:
        if(value>get(handles.sliderofseuil,'Max'))
            set(handles.sliderofseuil,'Value',get(handles.sliderofseuil,'Max')); %slider � cot� max
        elseif(value<get(handles.sliderofseuil,'Min'))
            set(handles.sliderofseuil,'Value',get(handles.sliderofseuil,'Min')); %slider � cot� min
        else
            set(handles.sliderofseuil,'Value',value); %slider �cot�
        end
handles.slider_seuil=value;

if(handles.do_auto_fit)
    handles.img{handles.chosenimage2} = gui_fit(img,handles);
    handles.log{handles.chosenimage2}=[handles.log{handles.chosenimage}, ' Fit@seuil=',num2str(handles.slider_seuil)];
end

guidata(hObject, handles);


% Si coch�: on lance automatiquement le fit a chaque changement valeur
function checkbox_autofit_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_autofit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_autofit

handles.do_auto_fit=get(hObject,'Value')
guidata(hObject, handles);

%DECONVOLUTION
function [imgout] = gui_deconv(img,handles)

    lambda=handles.slider_lambda
    largeur=handles.slider_radius;

    H = largeur/handles.stepsize;
    n = H/2/sqrt(2*log(2));
    %PSF et D:
    t=floor(min(size(img)/8))
    x = -t:t; x=exp(-x.*x/2/n/n)/sqrt(2*pi)/n;
    RI=transpose(x)*x;
    D = [0 -1 0;-1 4 -1 ; 0 -1 0];

    imgout=filtreWiener(img,RI,lambda,D);
    imgout=imgout/max(max(imgout)); %retabissement � 1
    handles.img{handles.chosenimage2}=imgout;
    'deconv finie'
    
    %Affichage
    contents = cellstr(get(handles.listbox_img,'String'));
    contents{handles.chosenimage2}=[contents{handles.chosenimage},' deconv'];
    set(handles.listbox_img,'String',contents);
    set(handles.listbox_out,'String',contents);
        axes(handles.axes2);

%             imshow(imgout,[]);
            imshow(imgout);
            title(contents{handles.chosenimage2});


     %Bouton Contour =>
    %FIT, mais ne modifie pas le handle
function [imgout,p] = gui_fit(img,handles)
%renvoie l'image fit�e et les parametres de chaque gaussienne
'fit lance'

seuil=handles.slider_seuil

% barycentres=contours(img,handles.slider_seuil); %premiere detec de x y et R, mais fitpeak le fait ?

% imgout=(img).*img>seuil; % FAire le fit ici les copains
% OU UTILISATION DE FITPEAK

maxloops=100;
p=fitngauss(img,seuil,handles.algofit,1); %fait le boulot

name=datestr(datetime('now'));
name(name==' ')='_';
save (['parametres_g',name,'.txt'],'p','-ascii')     %pas de soucis si il fait pas deux fits sur la meme seconde..
% save (['parametres_g',date,'.txt'],'p','-ascii')

sp=size(p);
s=size(img);
n=sp(1) %nombre gaussiennes

imgout=zeros(s(1),s(2));    %fit
    %utiliser gaussian plutot:
    for(g=1:n)
        imgout=imgout+gaussian(p,s(2),s(1));        %c'est bien gaussian (p) ?
    end
    MSQ=sum(sum((imgout-img).^2))
    
%affichage et edition liste
    contents = cellstr(get(handles.listbox_img,'String'));
    contents{handles.chosenimage2}=[contents{handles.chosenimage},' fit'];
    set(handles.listbox_img,'String',contents);
    set(handles.listbox_out,'String',contents);
    
    
%         axes(handles.axes2)
%         imshow(imgout)
%         title(contents{handles.chosenimage2})
        
        
        

% --- Detection de touche !
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

eventdata.Key;
switch eventdata.Key
    case 'c'
        'affichage contrast�'
        if(handles.imageisloaded)
            %CONTRAST: affichage du min au max
            contents = cellstr(get(handles.listbox_img,'String'));
           
            axes(handles.axes1)
            imshow(handles.img{handles.chosenimage},[])
             title([contents{handles.chosenimage},' contrastee'])
            axes(handles.axes2)
            imshow(handles.img{handles.chosenimage2},[])
             title([contents{handles.chosenimage2},' contrastee'])
        end
    case 'l'
        'affichage log'
        if(handles.imageisloaded)
            %CONTRAST: affichage du min au max
            contents = cellstr(get(handles.listbox_img,'String'));
            axes(handles.axes1)
            imshow(log(1+handles.img{handles.chosenimage})/log(2),[])
            title(['log(',contents{handles.chosenimage},')'])
            axes(handles.axes2)
            imshow(log( 1+handles.img{handles.chosenimage2} )/log(2),[])
            title(['log(',contents{handles.chosenimage2},')'])
        end   
    case 'n'
        'affichage normal'
        if(handles.imageisloaded)
            contents = cellstr(get(handles.listbox_img,'String'));
            
            axes(handles.axes1)
            imshow(handles.img{handles.chosenimage})
            title(contents{handles.chosenimage})
            axes(handles.axes2)
            imshow(handles.img{handles.chosenimage2})
             title(contents{handles.chosenimage2})

            
        end    
end 
        
        

function affichage(naxes,handles) %affiche une image sur l'axes correspondant

switch naxes
    case 1
        axes(handles.axes1)
        imshow(handles.img{handles.chosenimage})
        contents = cellstr(get(handles.listbox_img,'String'));
        title(contents{handles.chosenimage})
    case 2
        axes(handles.axes2)
        imshow(handles.img{handles.chosenimage2})
        contents = cellstr(get(handles.listbox_img,'String'));
        title(contents{handles.chosenimage2})
end

function editlog(handles)
if(handles.imageisloaded)
    handles.log{handles.chosenimage}
    set(handles.edit_log,'String',handles.log{handles.chosenimage});
end


function edit_log_Callback(hObject, eventdata, handles)
% hObject    handle to edit_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_log as text
%        str2double(get(hObject,'String')) returns contents of edit_log as a double


%Texte du log
% --- Executes during object creation, after setting all properties.
function edit_log_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Choix algo pour fit
% --- Executes on selection change in listbox_algo.
function listbox_algo_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_algo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_algo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_algo

choice=get(hObject,'Value');    % correspond � l'algo choisi
handles.algofit=choice;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function listbox_algo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_algo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.algofit=get(hObject,'Value');
guidata(hObject, handles);



%%
%Superposition RGB
%notes:
%Pour l'instant images de m�me tailles seulement, la taille est prise au
%premier chargement d'image. 

% Chaque bouton RGB associe l'image choisie dans la liste 1 � l'espace
% respectif RGB de l'image

% --- Executes on button press in pushbutton_red.
function pushbutton_red_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_red (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.imgrgb(:,:,1)=handles.img{handles.chosenimage};
affichagergb(handles)
guidata(hObject, handles);

% --- Executes on button press in pushbutton_green.
function pushbutton_green_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_green (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.imgrgb(:,:,2)=handles.img{handles.chosenimage};
affichagergb(handles)
guidata(hObject, handles);

% --- Executes on button press in pushbutton_blue.
function pushbutton_blue_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_blue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.imgrgb(:,:,3)=handles.img{handles.chosenimage};
affichagergb(handles)
guidata(hObject, handles);

%Permet de red�finir la taille que de l'image rgb avec l'image actuelle
% --- Executes on button press in pushbutton_resetrgb.
function pushbutton_resetrgb_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_resetrgb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=size(handles.img{handles.chosenimage});
handles.imgrgb=zeros(s(1),s(2),3);
affichagergb(handles)
guidata(hObject, handles);


function affichagergb(handles) %affiche une image sur l'axes correspondant

        axes(handles.axes3)
        imshow(handles.imgrgb,[]);


      %%
      


