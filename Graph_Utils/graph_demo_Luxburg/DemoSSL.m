function varargout = DemoSSL(varargin)
% Usage: DemoSSL()
% 
% Opens a large window, with all sorts of knobs and sliders. Just play :-) 
% 
% Documentation can be found at the GraphDemo webpage. 
% Written by Matthias Hein and Ulrike von Luxburg



% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DemoSSL_OpeningFcn, ...
                   'gui_OutputFcn',  @DemoSSL_OutputFcn, ...
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

% --- Executes just before DemoSSL is made visible.
function DemoSSL_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DemoSSL (see VARARGIN)


% ULE: 
% to avoid the following weird error message: 
% Warning: RGB color data not yet supported in Painter's mode.
% is due to automatic choice of renderer by matlab. 
set(gcf, 'Renderer', 'Zbuffer')
warning('off','MATLAB:dispatcher:InexactMatch')



global ALLDATA_SSL;
global SSLDATA;
ALLDATA_SSL = struct('Dim'  , 3, 'MinDim'   , 2, 'MaxDim'    , 200, 'Num', 500, 'NumLabels', 20 , 'MinLabels', 1, 'MaxLabels', 500, 'NumKNN', 5,  'MinKNN', 1, 'MaxKNN', 200, 'Eps', 0.3, 'MinEps', 0.01, 'MaxEps', 10.0, 'Density', 1, 'x',0, 'y', 0, 'Labeled', 0, 'GraphType', 1, 'K', 0, 'Gamma',1,'MaxGamma',10,'MinGamma',0.1);
SSLDATA = struct('Regul', 1, 'MinRegul',1E-12,'MaxRegul',1E+2,'TestError', 1, 'NotLabeled', 0, 'TrainError', 0, 'Output',0);

% Choose default command line output for DemoSSL
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
main=handles.figure1;
scrsz = get(0,'ScreenSize');
%set(main,'Position',[scrsz(1) scrsz(2) scrsz(3) scrsz(4)])

% set controls to the initial values
set(handles.SldNumNeighbors,'Value',(ALLDATA_SSL.NumKNN-ALLDATA_SSL.MinKNN)/(ALLDATA_SSL.MaxKNN-ALLDATA_SSL.MinKNN));
set(handles.SldNumLabels,'Value',(ALLDATA_SSL.NumLabels-ALLDATA_SSL.MinLabels)/(ALLDATA_SSL.MaxLabels-ALLDATA_SSL.MinLabels));
set(handles.SldDim,'Value',(ALLDATA_SSL.Dim-ALLDATA_SSL.MinDim)/(ALLDATA_SSL.MaxDim-ALLDATA_SSL.MinDim));
set(handles.SldWeights,'Value',(ALLDATA_SSL.Gamma-ALLDATA_SSL.MinGamma)/(ALLDATA_SSL.MaxGamma-ALLDATA_SSL.MinGamma));
% set all static text elements
set(handles.TxtNumNeighbors,'String',num2str(ALLDATA_SSL.NumKNN));
set(handles.TxtNumLabels,'String',num2str(ALLDATA_SSL.NumLabels));
set(handles.TxtDim,'String',num2str(ALLDATA_SSL.Dim));
set(handles.TxtWeights,'String',num2str(ALLDATA_SSL.Gamma));

% update slider for labeled data
set(handles.SldNumLabels,'SliderStep',[1/ALLDATA_SSL.MaxLabels,10/ALLDATA_SSL.MaxLabels]);


% generate data (inital dataset: two moons with balanced classes)
[ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(2,ALLDATA_SSL.Num,3,[0.5,0.5],0.01);
% initialize labeled data
ALLDATA_SSL.Labeled = randperm(ALLDATA_SSL.Num);
ALLDATA_SSL.Labeled = ALLDATA_SSL.Labeled(1:ALLDATA_SSL.NumLabels);

% draw it in the input window
DrawData(handles.axes4);

% build and draw graph
BuildWeights();
DrawWeights(handles.axes2);

% get and set components
numComps = CompComps();
set(handles.TxtNumComps,'String',num2str(numComps));

[EdInBet,EdBet,WBet,WInBet]=getEdgeStatistics();
% set all static text elements for the graph Statistics
set(handles.TxtWBet,'String',num2str(WBet,'%2.2f'));
set(handles.TxtWInBet,'String',num2str(WInBet,'%2.2f'));
set(handles.TxtEdgeBet,'String',num2str(EdBet,'%2.0d'));
set(handles.TxtEdgeInBet,'String',num2str(EdInBet,'%2.0d'));
set(handles.TxtTotalNumberPoints,'String',['Total number of points: ',num2str(ALLDATA_SSL.Num)]);



% set regularization parameter
set(handles.TxtRegul,'String',num2str(SSLDATA.Regul,'%2.2e'));

% set slider of regularization parameter
value=log(SSLDATA.Regul);
value = (value - log(SSLDATA.MinRegul))/(log(SSLDATA.MaxRegul)-log(SSLDATA.MinRegul));
set(handles.SldRegul,'Value',SSLDATA.Regul);



% initialize SSL solution
laplacian=2;
lambda=0;
LabelVector = zeros(ALLDATA_SSL.Num,1);
LabelVector(ALLDATA_SSL.Labeled)=ALLDATA_SSL.y(ALLDATA_SSL.Labeled);
[output,d]=GD_PerformSSL(ALLDATA_SSL.K, LabelVector, max(ALLDATA_SSL.y), laplacian, lambda, SSLDATA.Regul);
[SSLDATA.TestError, SSLDATA.TrainError,SSLDATA.NotLabeled,SSLDATA.Output]= GD_EvalSolution(ALLDATA_SSL.y,output,ALLDATA_SSL.Labeled);
ShowOutput(handles.axes3);

set(handles.TxtTestError,'String',[num2str(100*SSLDATA.TestError,'%2.1f'),'%']);
set(handles.TxtTrainError,'String',[num2str(100*SSLDATA.TrainError,'%2.1f'),'%']);
set(handles.TxtNotLabeled,'String',[num2str(100*SSLDATA.NotLabeled,'%2.1f'),'%']);






% UIWAIT makes DemoSSL wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DemoSSL_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in PshNewData.
function PshNewData_Callback(hObject, eventdata, handles)
% hObject    handle to PshNewData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ALLDATA_SSL;

axes(handles.axes4);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
     case 1 % Two Moons with balanced classes [0.5,0.5]
       ALLDATA_SSL.Density=2;
       % generate data 
       ALLDATA_SSL.Num=500;
       [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.5,0.5],0.01);
       
    case 2 % Two Moons with unbalanced classes [0.2,0.8]
       ALLDATA_SSL.Density=2;
       % generate data 
       ALLDATA_SSL.Num=500;
       [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.2,0.8],0.01);
      
    case 3 % Two isotropic Gaussians balanced classes [0.5,0.5]
      ALLDATA_SSL.Density=3;
      % generate data 
      ALLDATA_SSL.Num=500;
      [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.5,0.5,0],0.01);
     
    case 4 % Two isotropic Gaussians unbalanced classes [0.2,0.8]
      ALLDATA_SSL.Density=3;
      % generate data 
      ALLDATA_SSL.Num=500;
      [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.2,0.8,0],0.01);
      
    case 5 % Two isotropic Gaussians with different variance and balanced classes [0.2,0.8]
      ALLDATA_SSL.Density=4;
      % generate data 
      ALLDATA_SSL.Num=500;
      [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.5,0.5,0],0.01);
    
    case 6 % two isotropic Gaussians where the decision boundary goes through the middle of the Gaussians
       ALLDATA_SSL.Density=5;
       ALLDATA_SSL.Num=500;
       [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.5,0.5,0],0.01);
       
    case 7 % Three isotropic Gaussians almost balanced [0.3,0.3,0.4]
       ALLDATA_SSL.Density=3;
       % generate data 
       ALLDATA_SSL.Num=500;
       [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.3,0.3,0.4],0.01);
    
    
          
    case 8
        ALLDATA_SSL.Density=6;
        load GD_USPSTrain;
        xtrain=x; ytrain=y;
        load GD_USPSTest;
        xtest=x; ytest=y;
        %ALLDATA_SSL.x = [xtrain', xtest'];
        %ALLDATA_SSL.y = [ytrain; ytest];
        ALLDATA_SSL.x = [xtest'];
        ALLDATA_SSL.y = [ytest+1];
        ALLDATA_SSL.Num = length(ALLDATA_SSL.y);
        cla(handles.axes2);
        cla(handles.axes3);
        cla(handles.axes4);
end
% update slider for labeled data
set(handles.SldNumLabels,'SliderStep',[1/ALLDATA_SSL.MaxLabels,10/ALLDATA_SSL.MaxLabels]);

% update labeled data
ALLDATA_SSL.Labeled = randperm(ALLDATA_SSL.Num);
ALLDATA_SSL.Labeled = ALLDATA_SSL.Labeled(1:ALLDATA_SSL.NumLabels);

UpdateALL(handles);







% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
global ALLDATA_SSL;

axes(handles.axes4);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1 % Two Moons with balanced classes [0.5,0.5]
       ALLDATA_SSL.Density=2;
       % generate data 
       ALLDATA_SSL.Num=500;
       [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.5,0.5],0.01);
       
    case 2 % Two Moons with unbalanced classes [0.2,0.8]
       ALLDATA_SSL.Density=2;
       % generate data 
       ALLDATA_SSL.Num=500;
       [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.2,0.8],0.01);
      
    case 3 % Two isotropic Gaussians balanced classes [0.5,0.5]
      ALLDATA_SSL.Density=3;
      % generate data 
      ALLDATA_SSL.Num=500;
      [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.5,0.5,0],0.01);
     
    case 4 % Two isotropic Gaussians unbalanced classes [0.2,0.8]
      ALLDATA_SSL.Density=3;
      % generate data 
      ALLDATA_SSL.Num=500;
      [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.2,0.8,0],0.01);
      
    case 5 % Two isotropic Gaussians with different variance and balanced classes [0.2,0.8]
      ALLDATA_SSL.Density=4;
      % generate data 
      ALLDATA_SSL.Num=500;
      [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.5,0.5,0],0.01);
   
    case 6 % two isotropic Gaussians where the decision boundary goes through the middle of the Gaussians
       ALLDATA_SSL.Density=5;
       ALLDATA_SSL.Num=500;
       [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.5,0.5,0],0.01);
    
    case 7 % Three isotropic Gaussians almost balanced [0.3,0.3,0.4]
       ALLDATA_SSL.Density=3;
       % generate data 
       ALLDATA_SSL.Num=500;
       [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.3,0.3,0.4],0.01); 
          
    case 8
        ALLDATA_SSL.Density=6;   
        load GD_USPSTrain;
        xtrain=x; ytrain=y;
        load GD_USPSTest;
        xtest=x; ytest=y;
        %ALLDATA_SSL.x = [xtrain', xtest'];
        %ALLDATA_SSL.y = [ytrain; ytest];
        ALLDATA_SSL.x = [xtest'];
        ALLDATA_SSL.y = [ytest+1];
        ALLDATA_SSL.Num = length(ALLDATA_SSL.y);
        cla(handles.axes2);
        cla(handles.axes3);
        cla(handles.axes4);
end
% update slider for labeled data
set(handles.SldNumLabels,'SliderStep',[1/ALLDATA_SSL.MaxLabels,10/ALLDATA_SSL.MaxLabels]);

ALLDATA_SSL.Labeled = randperm(ALLDATA_SSL.Num);
ALLDATA_SSL.Labeled = ALLDATA_SSL.Labeled(1:ALLDATA_SSL.NumLabels);

UpdateALL(handles);


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

%set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});
x=0;


% --- Executes on slider movement.
function SldNumNeighbors_Callback(hObject, eventdata, handles)
% hObject    handle to SldNumNeighbors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ALLDATA_SSL;
value = get(hObject,'Value');
if(ALLDATA_SSL.GraphType<2)
  ALLDATA_SSL.NumKNN = floor(value*(ALLDATA_SSL.MaxKNN-ALLDATA_SSL.MinKNN) + ALLDATA_SSL.MinKNN);
  set(handles.TxtNumNeighbors,'String',num2str(ALLDATA_SSL.NumKNN));
else
  ALLDATA_SSL.Eps = value*(ALLDATA_SSL.MaxEps-ALLDATA_SSL.MinEps) + ALLDATA_SSL.MinEps;
  set(handles.TxtNumNeighbors,'String',num2str(ALLDATA_SSL.Eps,'%2.2f'));
end
%UpdateALL(handles);



% --- Executes during object creation, after setting all properties.
function SldNumNeighbors_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SldNumNeighbors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end






% --- Executes on slider movement.
function SldDim_Callback(hObject, eventdata, handles)
% hObject    handle to SldDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider
global ALLDATA_SSL;
value = get(hObject,'Value');
ALLDATA_SSL.Dim = floor(value*(ALLDATA_SSL.MaxDim-ALLDATA_SSL.MinDim) + ALLDATA_SSL.MinDim);
set(handles.TxtDim,'String',num2str(ALLDATA_SSL.Dim));

popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
     case 1 % Two Moons with balanced classes [0.5,0.5]
       ALLDATA_SSL.Density=2;
       % generate data 
       ALLDATA_SSL.Num=500;
       [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.5,0.5],0.01);
       
    case 2 % Two Moons with unbalanced classes [0.2,0.8]
       ALLDATA_SSL.Density=2;
       % generate data 
       ALLDATA_SSL.Num=500;
       [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.2,0.8],0.01);
      
    case 3 % Two isotropic Gaussians balanced classes [0.5,0.5]
      ALLDATA_SSL.Density=3;
      % generate data 
      ALLDATA_SSL.Num=500;
      [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.5,0.5,0],0.01);
     
    case 4 % Two isotropic Gaussians unbalanced classes [0.2,0.8]
      ALLDATA_SSL.Density=3;
      % generate data 
      ALLDATA_SSL.Num=500;
      [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.2,0.8,0],0.01);
      
    case 5 % Two isotropic Gaussians with different variance and balanced classes [0.2,0.8]
      ALLDATA_SSL.Density=4;
      % generate data 
      ALLDATA_SSL.Num=500;
      [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.5,0.5,0],0.01);
    
    case 6 % two isotropic Gaussians where the decision boundary goes through the middle of the Gaussians
       ALLDATA_SSL.Density=5;
       ALLDATA_SSL.Num=500;
       [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.5,0.5,0],0.01);
     
    case 7 % Three isotropic Gaussians almost balanced [0.3,0.3,0.4]
       ALLDATA_SSL.Density=3;
       % generate data 
       ALLDATA_SSL.Num=500;
       [ALLDATA_SSL.x,ALLDATA_SSL.y]=GD_GenerateData(ALLDATA_SSL.Density,ALLDATA_SSL.Num,ALLDATA_SSL.Dim,[0.3,0.3,0.4],0.01);
    
    case 8
       display('WARNING: Dimension of USPS is fixed !');
end

%UpdateALL(handles);


% --- Executes during object creation, after setting all properties.
function SldDim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SldDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
x=0;




% --- Executes on slider movement.
function SldNumLabels_Callback(hObject, eventdata, handles)
% hObject    handle to SldNumLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ALLDATA_SSL;
value = get(hObject,'Value');
ALLDATA_SSL.NumLabels = floor(value*(ALLDATA_SSL.MaxLabels-ALLDATA_SSL.MinLabels) + ALLDATA_SSL.MinLabels);
set(handles.TxtNumLabels,'String',num2str(ALLDATA_SSL.NumLabels));

% initialize labeled data
ALLDATA_SSL.Labeled = randperm(ALLDATA_SSL.Num);
ALLDATA_SSL.Labeled = ALLDATA_SSL.Labeled(1:ALLDATA_SSL.NumLabels);

%UpdateALL(handles);



% --- Executes during object creation, after setting all properties.
function SldNumLabels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SldNumLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
x=0;





% --- Executes on selection change in PopGraphType.
function PopGraphType_Callback(hObject, eventdata, handles)
% hObject    handle to PopGraphType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns PopGraphType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopGraphType
global ALLDATA_SSL;
value = get(hObject,'Value');
switch value
    case 1, ALLDATA_SSL.GraphType = 1; set(handles.TxtNeighborhood,'String','Number of Neighbors'); 
                                   value = (ALLDATA_SSL.NumKNN - ALLDATA_SSL.MinKNN)/(ALLDATA_SSL.MaxKNN - ALLDATA_SSL.MinKNN);
                                   set(handles.SldNumNeighbors,'Value',value);
                                   set(handles.TxtNumNeighbors,'String',num2str(ALLDATA_SSL.NumKNN,'%d'));
    case 2, ALLDATA_SSL.GraphType = 0; set(handles.TxtNeighborhood,'String','Number of Neighbors'); 
                                   value = (ALLDATA_SSL.NumKNN - ALLDATA_SSL.MinKNN)/(ALLDATA_SSL.MaxKNN - ALLDATA_SSL.MinKNN);
                                   set(handles.SldNumNeighbors,'Value',value);
                                   set(handles.TxtNumNeighbors,'String',num2str(ALLDATA_SSL.NumKNN,'%d'));
    case 3, if(ALLDATA_SSL.Density~=6) ALLDATA_SSL.GraphType = 2; set(handles.TxtNeighborhood,'String','Epsilon Parameter'); 
                                   value = (ALLDATA_SSL.Eps - ALLDATA_SSL.MinEps)/(ALLDATA_SSL.MaxEps - ALLDATA_SSL.MinEps);
                                   set(handles.SldNumNeighbors,'Value',value); 
                                   set(handles.TxtNumNeighbors,'String',num2str(ALLDATA_SSL.Eps,'%2.2f'));
            else
              if(ALLDATA_SSL.GraphType==1)
                set(handles.PopGraphType,'Value',1);
              end
              if(ALLDATA_SSL.GraphType==0)
                set(handles.PopGraphType,'Value',2);
              end
           end                             
end
%UpdateALL(handles);


% --- Executes during object creation, after setting all properties.
function PopGraphType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopGraphType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function SldRegul_Callback(hObject, eventdata, handles)
% hObject    handle to SldRegul (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global SSLDATA;
value = get(hObject,'Value');
value = (log10(SSLDATA.MaxRegul)-log10(SSLDATA.MinRegul))*value + log10(SSLDATA.MinRegul);
SSLDATA.Regul = 10^value;
set(handles.TxtRegul,'String',num2str(SSLDATA.Regul,'%2.2e'));
%UpdateALL(handles);



% --- Executes during object creation, after setting all properties.
function SldRegul_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SldRegul (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes on slider movement.
function SldWeights_Callback(hObject, eventdata, handles)
% hObject    handle to SldWeights (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ALLDATA_SSL;
value = get(hObject,'Value');
ALLDATA_SSL.Gamma = value*(ALLDATA_SSL.MaxGamma-ALLDATA_SSL.MinGamma) + ALLDATA_SSL.MinGamma;
set(handles.TxtWeights,'String',num2str(ALLDATA_SSL.Gamma,'%2.1f'));

%UpdateALL(handles);

% --- Executes during object creation, after setting all properties.
function SldWeights_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SldWeights (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in PshNewLabels.
function PshNewLabels_Callback(hObject, eventdata, handles)
% hObject    handle to PshNewLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ALLDATA_SSL;

ALLDATA_SSL.Labeled = randperm(ALLDATA_SSL.Num);
ALLDATA_SSL.Labeled = ALLDATA_SSL.Labeled(1:ALLDATA_SSL.NumLabels);

UpdateALL(handles);

% --- Executes on button press in PshUpdateALL.
function PshUpdateALL_Callback(hObject, eventdata, handles)
% hObject    handle to PshUpdateALL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UpdateALL(handles);


%--------------------------------------------------------------------------
function DrawData(Fig)
global ALLDATA_SSL;

if(ALLDATA_SSL.Density==6)
    cla(Fig);
end

if(ALLDATA_SSL.Density~=6)
  num_classes=max(ALLDATA_SSL.y);
  colors = {'red','blue','black'};
  hold(Fig,'on'); 
  % unlabeled data
  for i=1:num_classes
   plot(Fig,ALLDATA_SSL.x(1,ALLDATA_SSL.y==i),ALLDATA_SSL.x(2,ALLDATA_SSL.y==i),'MarkerEdgeColor',colors{i},'Marker','.','LineStyle','none')
  end

  % labeled data
  LabelVector =zeros(ALLDATA_SSL.Num,1);
  LabelVector(ALLDATA_SSL.Labeled)=ALLDATA_SSL.y(ALLDATA_SSL.Labeled);

  for i=1:num_classes
   plot(Fig,ALLDATA_SSL.x(1,LabelVector==i),ALLDATA_SSL.x(2,LabelVector==i),'MarkerFaceColor',colors{i},'MarkerEdgeColor',colors{3},'Marker','o','LineStyle','none','MarkerSize',8)
  end
  hold(Fig,'off'); 
  axis(Fig,'equal');
end

%--------------------------------------------------------------------------
function ShowOutput(Fig,output)
global ALLDATA_SSL;
global SSLDATA;

cla(Fig);

if(ALLDATA_SSL.Density~=6)
  num_classes=max(ALLDATA_SSL.y);
  colors = {'red','blue','black'};
  hold(Fig,'on'); 
  % output of the classifier
  for i=1:num_classes
   plot(Fig,ALLDATA_SSL.x(1,SSLDATA.Output==i),ALLDATA_SSL.x(2,SSLDATA.Output==i),'MarkerEdgeColor',colors{i},'Marker','.','LineStyle','none')
  end
  % points which have no label
  plot(Fig,ALLDATA_SSL.x(1,SSLDATA.Output==0),ALLDATA_SSL.x(2,SSLDATA.Output==0),'MarkerEdgeColor','magenta','Marker','.','LineStyle','none')

  % labeled data  
  LabelVector =zeros(ALLDATA_SSL.Num,1);
  LabelVector(ALLDATA_SSL.Labeled)=ALLDATA_SSL.y(ALLDATA_SSL.Labeled);

  for i=1:num_classes
   plot(Fig,ALLDATA_SSL.x(1,LabelVector==i),ALLDATA_SSL.x(2,LabelVector==i),'MarkerFaceColor',colors{i},'MarkerEdgeColor',colors{3},'Marker','o','LineStyle','none','MarkerSize',8)
  end
  hold(Fig,'off'); 
  axis(Fig,'equal');
end




%--------------------------------------------------------------------------
function BuildWeights()
global ALLDATA_SSL;

dist2 = DistEuclideanPiotrDollar(ALLDATA_SSL.x',ALLDATA_SSL.x'); % squared distances
if(ALLDATA_SSL.GraphType<2)
  if(ALLDATA_SSL.Density<6)
    [SD,IX]=sort(dist2,2);
    KNN     = IX(:,2:ALLDATA_SSL.NumKNN+1)';
    KNNDist = SD(:,2:ALLDATA_SSL.NumKNN+1)';
  else
    load GD_USPSKNN;
    KNN    =KNN(1:ALLDATA_SSL.NumKNN,:);
    KNNDist=KNNDist(1:ALLDATA_SSL.NumKNN,:);
  end
  % get kNN weight matrix
  ALLDATA_SSL.K = sparse(ALLDATA_SSL.Num,ALLDATA_SSL.Num);
  for i=1:ALLDATA_SSL.Num
    ALLDATA_SSL.K(KNN(:,i),i)=exp(-1/(2*ALLDATA_SSL.Gamma^2)*KNNDist(:,i));
  end
  % note that K is not symmetric yet , now we symmetrize K 
  if(ALLDATA_SSL.GraphType==1) ALLDATA_SSL.K=(ALLDATA_SSL.K+ALLDATA_SSL.K')+abs(ALLDATA_SSL.K-ALLDATA_SSL.K'); ALLDATA_SSL.K=0.5*ALLDATA_SSL.K; end
  if(ALLDATA_SSL.GraphType==0) ALLDATA_SSL.K=(ALLDATA_SSL.K+ALLDATA_SSL.K')-abs(ALLDATA_SSL.K-ALLDATA_SSL.K'); ALLDATA_SSL.K=0.5*ALLDATA_SSL.K; end 
else
  ALLDATA_SSL.K = exp(-1/(2*ALLDATA_SSL.Gamma^2)*dist2).*(dist2 < ALLDATA_SSL.Eps^2 & dist2~=0);
end

% if(ALLDATA_SSL.GraphType<2)
%   if(ALLDATA_SSL.Density<6)
%     [KNN,KNNDist]=getKNN(ALLDATA_SSL.x,ALLDATA_SSL.NumKNN);
%   else
%     load USPSKNN;
%     KNN    =KNN(1:ALLDATA_SSL.NumKNN,:);
%     KNNDist=KNNDist(1:ALLDATA_SSL.NumKNN,:);
%   end
%   % get kNN weight matrix
%   ALLDATA_SSL.K = getSparseWeightMatrixFromKNN(KNNDist,KNN,1/(2*ALLDATA_SSL.Gamma^2),ALLDATA_SSL.GraphType,1); 
%   % note that K is not symmetric yet (in the case of the symmetric KNN), now we symmetrize K 
%   if(ALLDATA_SSL.GraphType==1) ALLDATA_SSL.K=(ALLDATA_SSL.K+ALLDATA_SSL.K')+abs(ALLDATA_SSL.K-ALLDATA_SSL.K'); ALLDATA_SSL.K=0.5*ALLDATA_SSL.K; end
% else
%   dist=getDistanceMatrix(ALLDATA_SSL.x);
%   ALLDATA_SSL.K = exp(-1/(2*ALLDATA_SSL.Gamma^2)*dist.^2).*(dist < ALLDATA_SSL.Eps & dist~=0);
% end

%--------------------------------------------------------------------------
function DrawWeights(Fig)
global ALLDATA_SSL

cla(Fig);

if(ALLDATA_SSL.Density~=6)
  hold(Fig,'on');
  STEP=1; NNZK=nnz(ALLDATA_SSL.K);
%   if(NNZK>60000)
%    STEP=ceil(NNZK/60000); display(['WARNING: TOO MANY EDGES, WILL ONLY SHOW 1/',num2str(STEP),' of all points']);
%   end
  xx=zeros(2*ALLDATA_SSL.Num,1);
  yy=zeros(2*ALLDATA_SSL.Num,1);
  tic
  for i=1:STEP:ALLDATA_SSL.Num
    indices = find(ALLDATA_SSL.K(i+1:end,i)>0)+i;
    NumIndices=length(indices);
    xx(1:2:2*NumIndices)=ALLDATA_SSL.x(1,i);
    xx(2:2:2*NumIndices)=ALLDATA_SSL.x(1,indices);
    yy(1:2:2*NumIndices)=ALLDATA_SSL.x(2,i);
    yy(2:2:2*NumIndices)=ALLDATA_SSL.x(2,indices);
    plot(Fig,xx(1:2*NumIndices),yy(1:2*NumIndices),'-g');
  end
  t1=toc
%   STEP=1;
%   hold(Fig2,'on');
%   tic
%   for i=1:STEP:ALLDATA_SSL.Num
%     indices = find(ALLDATA_SSL.K(i+1:end,i)>0)+i;
%     NumIndices=length(indices);
%     %plot(Fig,[repmat(ALLDATA_SSL.x(1,i),1,NumIndices); ALLDATA_SSL.x(1,indices)], [repmat(ALLDATA_SSL.x(2,i),1,NumIndices);ALLDATA_SSL.x(2,indices)], '-g');
%     if(NumIndices>0)
%      plot(Fig2,[repmat(ALLDATA_SSL.x(1,i),1,NumIndices); ALLDATA_SSL.x(1,indices)], [repmat(ALLDATA_SSL.x(2,i),1,NumIndices);ALLDATA_SSL.x(2,indices)], '-g');
%      %plot(Fig,[repmat(ALLDATA_SSL.x(1,i),NumIndices,1), ALLDATA_SSL.x(1,indices)], [repmat(ALLDATA_SSL.x(2,i),NumIndices,1), ALLDATA_SSL.x(2,indices)], '-g');
%     end
%   end
%   t2=toc
%    hold(Fig2,'off');
  hold(Fig,'off');
  axis(Fig,'equal');
  DrawData(Fig);
end

%--------------------------------------------------------------------------
function numComps = CompComps()
global ALLDATA_SSL
compvec = GD_GetComps(ALLDATA_SSL.K);
numComps = max(compvec);

% disp(['Number of connected components: ', num2str(max(compvec))]);
% numPointsInComps = zeros(numComps,1);
%     for i=1:numComps
%       numPointsInComps(i)=nnz(compvec==i);
%     end      
% numPointsInComps=sort(numPointsInComps,'descend');
% disp(['Number of points in the ',num2str(min(numComps,10)),' largest components']);
% for i=1:min(numComps,10)
%   disp(['Cluster ',num2str(i),' with ',num2str(numPointsInComps(i)),' points']);
% end

%--------------------------------------------------------------------------
function [EdInBet,EdBet,WBet,WInBet] = getEdgeStatistics()
% EdInBet : Edges inbetween classes
% EdBet   : Edges between classes
% WBet    : Weights between classes
% WInBet  : weights inbetween classes
global ALLDATA_SSL

num_classes=max(ALLDATA_SSL.y);
WInBet =0; EdInBet=0;
for i=1:num_classes
  WInBet = WInBet    + (ALLDATA_SSL.y==i)'*ALLDATA_SSL.K*(ALLDATA_SSL.y==i);
  EdInBet= EdInBet   + (ALLDATA_SSL.y==i)'*double(ALLDATA_SSL.K>0)*(ALLDATA_SSL.y==i);
end

WBet = 0.5*(sum(sum(ALLDATA_SSL.K)) - WInBet);
EdBet= 0.5*(nnz(ALLDATA_SSL.K) - EdInBet);
WInBet = 0.5*WInBet;
EdInBet= 0.5*EdInBet;

%--------------------------------------------------------------------------
function UpdateSSL(handles)
global ALLDATA_SSL
global SSLDATA
    
laplacian=2;
lambda=0;
LabelVector = zeros(ALLDATA_SSL.Num,1);
LabelVector(ALLDATA_SSL.Labeled)=ALLDATA_SSL.y(ALLDATA_SSL.Labeled);
[output,d]=GD_PerformSSL(ALLDATA_SSL.K, LabelVector, max(ALLDATA_SSL.y), laplacian, lambda, SSLDATA.Regul);
[SSLDATA.TestError, SSLDATA.TrainError,SSLDATA.NotLabeled,SSLDATA.Output]=GD_EvalSolution(ALLDATA_SSL.y,output,ALLDATA_SSL.Labeled);
ShowOutput(handles.axes3);

set(handles.TxtTestError,'String',[num2str(100*SSLDATA.TestError,'%2.1f'),'%']);
set(handles.TxtTrainError,'String',[num2str(100*SSLDATA.TrainError,'%2.1f'),'%']);
set(handles.TxtNotLabeled,'String',[num2str(100*SSLDATA.NotLabeled,'%2.1f'),'%']);

% set controls to the initial values
%set(handles.SldNumNeighbors,'Value',(ALLDATA_SSL.NumKNN-ALLDATA_SSL.MinKNN)/(ALLDATA_SSL.MaxKNN-ALLDATA_SSL.MinKNN));
set(handles.SldNumLabels,'Value',(ALLDATA_SSL.NumLabels-ALLDATA_SSL.MinLabels)/(ALLDATA_SSL.MaxLabels-ALLDATA_SSL.MinLabels));
set(handles.SldDim,'Value',(ALLDATA_SSL.Dim-ALLDATA_SSL.MinDim)/(ALLDATA_SSL.MaxDim-ALLDATA_SSL.MinDim));
% set all static text elements
% if(ALLDATA_SSL.GraphType<2)
%  set(handles.TxtNumNeighbors,'String',num2str(ALLDATA_SSL.NumKNN));
% else
%  set(handles.TxtNumNeighbors,'String',num2str(ALLDATA_SSL.Eps,'%2.2f'));
% end
set(handles.TxtNumLabels,'String',num2str(ALLDATA_SSL.NumLabels));
set(handles.TxtDim,'String',num2str(ALLDATA_SSL.Dim));


%--------------------------------------------------------------------------
function UpdateALL(handles)
global ALLDATA_SSL
global SSLDATA

% clear all graphs
cla(handles.axes2);
cla(handles.axes3);
cla(handles.axes4);


% draw dataset
DrawData(handles.axes4);

% build and draw graph
BuildWeights();
DrawWeights(handles.axes2);
drawnow;

% get and set components
numComps = CompComps();
set(handles.TxtNumComps,'String',num2str(numComps));

[EdInBet,EdBet,WBet,WInBet]=getEdgeStatistics();
% set all static text elements for the graph Statistics
set(handles.TxtWBet,'String',num2str(WBet,'%2.2f'));
set(handles.TxtWInBet,'String',num2str(WInBet,'%2.2f'));
set(handles.TxtEdgeBet,'String',num2str(EdBet,'%2.0d'));
set(handles.TxtEdgeInBet,'String',num2str(EdInBet,'%2.0d'));

if(ALLDATA_SSL.Density<6)
 set(handles.TxtTotalNumberPoints,'String',['Total number of points: ',num2str(ALLDATA_SSL.Num)]);
else
 set(handles.TxtTotalNumberPoints,'String',['Total number of points: ',num2str(ALLDATA_SSL.Num),', ONLY KNN POSSIBLE !']);
end


% set regularization parameter
set(handles.TxtRegul,'String',num2str(SSLDATA.Regul,'%2.2e'));

UpdateSSL(handles);









