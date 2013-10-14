function varargout = DemoSimilarityGraphs(varargin)
% Usage: DemoSimilarityGraphs()
% 
% Opens a large window, with all sorts of knobs and sliders. Just play :-) 
% 
% Documentation can be found at the GraphDemo webpage. 
% Written by Matthias Hein and Ulrike von Luxburg



% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DemoSimilarityGraphs_OpeningFcn, ...
                   'gui_OutputFcn',  @DemoSimilarityGraphs_OutputFcn, ...
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



% --- Executes just before DemoSimilarityGraphs is made visible.
function DemoSimilarityGraphs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DemoSimilarityGraphs (see VARARGIN)

% Choose default command line output for DemoSimilarityGraphs
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DemoSimilarityGraphs wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% ------------------------------------------------------------
% ULE begin initializing 
% do this within this function as it only has to happen once
% ------------------------------------------------------------

% ULE: 
% to avoid the following weird error message: 
% Warning: RGB color data not yet supported in Painter's mode.
% is due to automatic choice of renderer by matlab. 
set(gcf, 'Renderer', 'Zbuffer')
warning('off','MATLAB:dispatcher:InexactMatch')


global GD_Global;

GD_Global = struct('CurrentNumPoints',100, 'MinNumPoints',10, 'MaxNumPoints',500, ...
                   'CurrentDataDim',2, 'MinDataDim',2, 'MaxDataDim',200,... 
                   'CurrentDataSet',1, ... %referst to position in list
                   'CurrentSimFct','Gaussian kernel',...
                   'CurrentGraph1', 1, ... %refers to position in list, 1=eps
                   'CurrentGraph2',2,...  %refers to position in list, 2 = symm knn
                   'CurrentGraphPara1',0.5,... 
                   'CurrentGraphPara2',5, ...
                   'DefaultK',5,'DefaultEps',0.5,... %default para values
                   'CurrentSigma',0.5, 'MinLogSigma',-2, 'MaxLogSigma',2, ... %sigma of the similarity function
                   'DefaultSigma',0.5, ... 
                   'CurrentVarNoise',0.01, 'MinVarNoise',0,'MaxVarNoise',0.1,... 
                    'MinK', 1, 'MaxK',50, 'MinEps', 0, 'MaxEps',100, ...
                   'points', [], 'labels', [] , ... %data set
                   'D', [], ... % data distance matrix
                   'S', [], ... %data similarity matrix
                   'W1', [], ... %adjacency matrix of first graph
                   'W2',[]); %adjacency matrix of second graph                   


% set colormap, this is the one implicitly used everywhere: 
% note that a colormap refers to a figure, not to an axis; cannot choose different 
% colormaps in different axes of the same figure
%set(0, 'colormap',autumn)
% somehow does not really work, gets reset all the time, giving up. 

% set  data sliders to their default values, and edit the min/max texts: 
InitializeSliders(handles)

% draw data set: 
DrawDataAndPlot(handles)

% compute new similarity function: 
ComputeSimilarityAndPlot(handles)

% plot the graphs a first time: 
ComputeGraphAndPlot(handles, 1)
ComputeGraphAndPlot(handles, 2)

% ------------------------------------------------------------
% ULE end initializing
% ------------------------------------------------------------





% --- Outputs from this function are returned to the command line.
function varargout = DemoSimilarityGraphs_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in type_graph2.
function type_graph2_Callback(hObject, eventdata, handles)
% hObject    handle to type_graph2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns type_graph2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from type_graph2
%ULE:
global GD_Global; 
GD_Global.CurrentGraph2 =get(hObject,'Value') ;
% set values back to default:
switch GD_Global.CurrentGraph2
 case 1
    GD_Global.CurrentGraphPara2 = SelectGoodEps(handles); 
 case 2
  GD_Global.CurrentGraphPara2 = GD_Global.DefaultK;
 case 3
  GD_Global.CurrentGraphPara2 = GD_Global.DefaultK;
 case 4
    GD_Global.CurrentGraphPara2 = SelectGoodEps(handles); 
end
InitializeSliders(handles);


% --- Executes during object creation, after setting all properties.
function type_graph2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to type_graph2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% ULE: note that the entries in the popup menue have been defined in the property editor in the string property

% --- Executes on slider movement.
function slider_graph_para2_Callback(hObject, eventdata, handles)
% hObject    handle to slider_graph_para2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%ULE:
global GD_Global; 
GD_Global.CurrentGraphPara2 =get(hObject,'Value') ;
InitializeSliders(handles);



% --- Executes during object creation, after setting all properties.
function slider_graph_para2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_graph_para2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in type_graph1.
function type_graph1_Callback(hObject, eventdata, handles)
% hObject    handle to type_graph1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns type_graph1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from type_graph1
%ULE:
global GD_Global; 
GD_Global.CurrentGraph1 =get(hObject,'Value') ;
% set values back to default:
switch GD_Global.CurrentGraph1
 case 1
  
  % try to choose a useful eps in the first place: 
  GD_Global.CurrentGraphPara1 = SelectGoodEps(handles); 
  
 case 2
  GD_Global.CurrentGraphPara1 = GD_Global.DefaultK;
 case 3
  GD_Global.CurrentGraphPara1 = GD_Global.DefaultK;
 case 4
  GD_Global.CurrentGraphPara1 = SelectGoodEps(handles); 
end
InitializeSliders(handles);

% --- Executes during object creation, after setting all properties.
function type_graph1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to type_graph1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_graph_para1_Callback(hObject, eventdata, handles)
% hObject    handle to slider_graph_para1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%ULE:
global GD_Global; 
GD_Global.CurrentGraphPara1 =get(hObject,'Value') ;
InitializeSliders(handles);


% --- Executes during object creation, after setting all properties.
function slider_graph_para1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_graph_para1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in select_data_set.
function select_data_set_Callback(hObject, eventdata, handles)
% hObject    handle to select_data_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns select_data_set contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_data_set
global GD_Global; 
GD_Global.CurrentDataSet =get(hObject,'Value') ;
InitializeSliders(handles);
% DrawDataAndPlot(handles); 
% ComputeSimilarityAndPlot(handles);
% ComputeGraphAndPlot(handles, 1)
% ComputeGraphAndPlot(handles, 2)

% --- Executes during object creation, after setting all properties.
function select_data_set_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_data_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_num_points_Callback(hObject, eventdata, handles)
% hObject    handle to slider_num_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% ULE: 
global GD_Global; 
GD_Global.CurrentNumPoints = ceil(get(hObject,'Value'));
InitializeSliders(handles);
% DrawDataAndPlot(handles); 
% ComputeSimilarityAndPlot(handles); 
% ComputeGraphAndPlot(handles, 1)
% ComputeGraphAndPlot(handles, 2)


% --- Executes during object creation, after setting all properties.
function slider_num_points_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_num_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_num_dim_Callback(hObject, eventdata, handles)
% hObject    handle to slider_num_dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% ULE: 
global GD_Global; 
GD_Global.CurrentDataDim = ceil(get(hObject,'Value'));
InitializeSliders(handles);
% DrawDataAndPlot(handles); 
% ComputeSimilarityAndPlot(handles); 
% ComputeGraphAndPlot(handles, 1)
% ComputeGraphAndPlot(handles, 2)



% --- Executes during object creation, after setting all properties.
function slider_num_dim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_num_dim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in which_similarity_function.
function which_similarity_function_Callback(hObject, eventdata, handles)
% hObject    handle to which_similarity_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns which_similarity_function contents as cell array
%        contents{get(hObject,'Value')} returns selected item from which_similarity_function


% --- Executes during object creation, after setting all properties.
function which_similarity_function_CreateFcn(hObject, eventdata, handles)
% hObject    handle to which_similarity_function (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_sigma_Callback(hObject, eventdata, handles)
% hObject    handle to slider_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global GD_Global; 
GD_Global.CurrentSigma = 10^(get(hObject,'Value')) ;
InitializeSliders(handles);


% % clear all the axes
% %cla(handles.axes_data_left)
% cla(handles.axes_data_middle)
% cla(handles.axes_data_right)
% cla(handles.axes_graph1_left)
% cla(handles.axes_graph1_middle)
% cla(handles.axes_graph1_right)
% cla(handles.axes_graph1_rr)
% cla(handles.axes_graph2_left)
% cla(handles.axes_graph2_middle)
% cla(handles.axes_graph2_right)
% cla(handles.axes_graph2_rr)
% drawnow

% ComputeSimilarityAndPlot(handles);
% ComputeGraphAndPlot(handles, 1)
% ComputeGraphAndPlot(handles, 2)



% --- Executes during object creation, after setting all properties.
function slider_sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end







% --- Executes on button press in button_graph1.
function button_graph1_Callback(hObject, eventdata, handles)
% hObject    handle to button_graph1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ULE: 
ComputeGraphAndPlot(handles,1);



% --- Executes on button press in button_graph2.
function button_graph2_Callback(hObject, eventdata, handles)
% hObject    handle to button_graph2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ULE: 
ComputeGraphAndPlot(handles,2);


% --- Executes on button press in button_data.
function button_data_Callback(hObject, eventdata, handles)
% hObject    handle to button_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%ULE: 
DrawDataAndPlot(handles); 
ComputeSimilarityAndPlot(handles); 
ComputeGraphAndPlot(handles, 1)
ComputeGraphAndPlot(handles, 2)








% --- Executes on button press in button_update_data_plots_only.
function button_update_data_plots_only_Callback(hObject, eventdata, handles)
% hObject    handle to button_update_data_plots_only (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%ULE: 
DrawDataAndPlot(handles); 
ComputeSimilarityAndPlot(handles); 









% ------------------------------------------------------------
% ------------------------------------------------------------
% Ules functions: 
% ------------------------------------------------------------
% ------------------------------------------------------------


% ------------------------------------------------------------
function InitializeSliders(handles)
% ------------------------------------------------------------
% after changing something about the data set, the sliders min/max/current values
% have to be reset: 

global GD_Global;

%disp('start init')

% slider num points: 
set(handles.slider_num_points,...
    'Value', GD_Global.CurrentNumPoints, ...
    'Min', GD_Global.MinNumPoints, ...
    'Max', GD_Global.MaxNumPoints);

set(handles.text_min_num_points,'String',num2str(GD_Global.MinNumPoints))
set(handles.text_max_num_points,'String',num2str(GD_Global.MaxNumPoints))
set(handles.text_current_num_points,'String',['Number of data points: ', num2str(GD_Global.CurrentNumPoints)])

% slider num dim: 
set(handles.slider_num_dim,...
    'Value', GD_Global.CurrentDataDim, ...
    'Min', GD_Global.MinDataDim, ...
    'Max', GD_Global.MaxDataDim);

set(handles.text_min_num_dim,'String',num2str(GD_Global.MinDataDim))
set(handles.text_max_num_dim,'String',num2str(GD_Global.MaxDataDim))
set(handles.text_current_num_dim,'String',['Data Dimensions: ', num2str(GD_Global.CurrentDataDim)])


% slider sigma: 
set(handles.slider_sigma,...
    'Value', log10(GD_Global.CurrentSigma), ...
    'Min', (GD_Global.MinLogSigma), ...
    'Max', (GD_Global.MaxLogSigma));

set(handles.text_min_sigma,'String',['10^(',num2str(GD_Global.MinLogSigma),')'])
set(handles.text_max_sigma,'String',['10^(',num2str(GD_Global.MaxLogSigma),')'])
set(handles.text_current_sigma,'String',['Kernel width sigma: ', num2str(GD_Global.CurrentSigma,'%2.2g')])




% adjust all paras for graph1, depending on graph type: 
set(handles.type_graph1, 'Value', GD_Global.CurrentGraph1);


switch GD_Global.CurrentGraph1
  
 case 1 %eps graph
  set(handles.slider_graph_para1,  'Min', GD_Global.MinEps, 'Max',GD_Global.MaxEps);
set(handles.slider_graph_para1, 'Value', GD_Global.CurrentGraphPara1); %set after setting min/max
  set(handles.text_graph_para1,'String', ['Current eps: ', num2str(GD_Global.CurrentGraphPara1)])
  set(handles.text_min_graph1,'String', num2str(GD_Global.MinEps))
  set(handles.text_max_graph1,'String', num2str(GD_Global.MaxEps))
      set(handles.text_min_graph1, 'Visible','on')
 set(handles.text_max_graph1, 'Visible','on')
 set(handles.slider_graph_para1,'Visible','on')

 case 2 %symmetric knn
  set(handles.slider_graph_para1,  'Min', GD_Global.MinK, 'Max',GD_Global.MaxK);
set(handles.slider_graph_para1, 'Value', ceil(GD_Global.CurrentGraphPara1)); %set after setting min/max
  set(handles.text_graph_para1,'String', ['Current k: ', num2str(ceil(GD_Global.CurrentGraphPara1))])
  set(handles.text_min_graph1,'String', num2str(GD_Global.MinK))
  set(handles.text_max_graph1,'String', num2str(GD_Global.MaxK))
 set(handles.text_min_graph1, 'Visible','on')
 set(handles.text_max_graph1, 'Visible','on')
 set(handles.slider_graph_para1,'Visible','on')
 set(handles.slider_graph_para1','SliderStep',[1 / (GD_Global.MaxK - GD_Global.MinK), 0.1])
 
 
 case 3 %mutual knn] 
  set(handles.slider_graph_para1, 'Min', GD_Global.MinK, 'Max',GD_Global.MaxK);
set(handles.slider_graph_para1, 'Value', ceil(GD_Global.CurrentGraphPara1)); %set after setting min/max
  set(handles.text_graph_para1,'String', ['Current k: ', num2str(ceil(GD_Global.CurrentGraphPara1))])
  set(handles.text_min_graph1,'String', num2str(GD_Global.MinK))
  set(handles.text_max_graph1,'String', num2str(GD_Global.MaxK))
      set(handles.text_min_graph1, 'Visible','on')
 set(handles.text_max_graph1, 'Visible','on')
 set(handles.slider_graph_para1,'Visible','on')
  set(handles.slider_graph_para1','SliderStep',[1 / (GD_Global.MaxK - GD_Global.MinK), 0.1])

 case 4 %eps graph unweighted
  
   set(handles.slider_graph_para1,  'Min', GD_Global.MinEps, 'Max',GD_Global.MaxEps);
set(handles.slider_graph_para1, 'Value', GD_Global.CurrentGraphPara1); %set after setting min/max
  set(handles.text_graph_para1,'String', ['Current eps: ', num2str(GD_Global.CurrentGraphPara1)])
  set(handles.text_min_graph1,'String', num2str(GD_Global.MinEps))
  set(handles.text_max_graph1,'String', num2str(GD_Global.MaxEps))
      set(handles.text_min_graph1, 'Visible','on')
 set(handles.text_max_graph1, 'Visible','on')
 set(handles.slider_graph_para1,'Visible','on')

end


% adjust all paras for graph2, depending on graph type: 
set(handles.type_graph2, 'Value', GD_Global.CurrentGraph2);

switch GD_Global.CurrentGraph2
  
 case 1 %eps graph weighted
  set(handles.slider_graph_para2,  'Min', GD_Global.MinEps, 'Max',GD_Global.MaxEps);
  set(handles.slider_graph_para2, 'Value', GD_Global.CurrentGraphPara2); %set after setting min/max
  set(handles.text_graph_para2,'String', ['Current eps: ', num2str(GD_Global.CurrentGraphPara2)])
  set(handles.text_min_graph2,'String', num2str(GD_Global.MinEps))
  set(handles.text_max_graph2,'String', num2str(GD_Global.MaxEps))
    set(handles.text_min_graph2, 'Visible','on')
 set(handles.text_max_graph2, 'Visible','on')
 set(handles.slider_graph_para2,'Visible','on')

 case 2 %symmetric knn
  set(handles.slider_graph_para2,  'Min', GD_Global.MinK, 'Max',GD_Global.MaxK);
 set(handles.slider_graph_para2, 'Value', ceil(GD_Global.CurrentGraphPara2)); %set after setting min/max
 set(handles.text_graph_para2,'String', ['Current k: ', num2str(ceil(GD_Global.CurrentGraphPara2))])
  set(handles.text_min_graph2,'String', num2str(GD_Global.MinK))
  set(handles.text_max_graph2,'String', num2str(GD_Global.MaxK))
   set(handles.text_min_graph2, 'Visible','on')
 set(handles.text_max_graph2, 'Visible','on')
 set(handles.slider_graph_para2,'Visible','on')
 set(handles.slider_graph_para2','SliderStep',[1 / (GD_Global.MaxK - GD_Global.MinK), 0.1])

 case 3 %mutual knn] 
  set(handles.slider_graph_para2, 'Min', GD_Global.MinK, 'Max',GD_Global.MaxK);
 set(handles.slider_graph_para2, 'Value', ceil(GD_Global.CurrentGraphPara2)); %set after setting min/max
 set(handles.text_graph_para2,'String', ['Current k: ', num2str(ceil(GD_Global.CurrentGraphPara2))])
  set(handles.text_min_graph2,'String', num2str(GD_Global.MinK))
  set(handles.text_max_graph2,'String', num2str(GD_Global.MaxK))
  set(handles.text_min_graph2, 'Visible','on')
 set(handles.text_max_graph2, 'Visible','on')
 set(handles.slider_graph_para2,'Visible','on')
 set(handles.slider_graph_para2','SliderStep',[1 / (GD_Global.MaxK - GD_Global.MinK), 0.1])

 case 4 %eps graph unweighted
 set(handles.slider_graph_para2,  'Min', GD_Global.MinEps, 'Max',GD_Global.MaxEps);
  set(handles.slider_graph_para2, 'Value', GD_Global.CurrentGraphPara2); %set after setting min/max
  set(handles.text_graph_para2,'String', ['Current eps: ', num2str(GD_Global.CurrentGraphPara2)])
  set(handles.text_min_graph2,'String', num2str(GD_Global.MinEps))
  set(handles.text_max_graph2,'String', num2str(GD_Global.MaxEps))
    set(handles.text_min_graph2, 'Visible','on')
 set(handles.text_max_graph2, 'Visible','on')
 set(handles.slider_graph_para2,'Visible','on')
end

%disp('end init')


% ------------------------------------------------------------
function DrawDataAndPlot(handles)
% ------------------------------------------------------------
global GD_Global;

% clear all the axes
cla(handles.axes_data_left)
cla(handles.axes_data_middle)
cla(handles.axes_data_right)
cla(handles.axes_graph1_left)
cla(handles.axes_graph1_middle)
cla(handles.axes_graph1_right)
cla(handles.axes_graph1_rr)
cla(handles.axes_graph2_left)
cla(handles.axes_graph2_middle)
cla(handles.axes_graph2_right)
cla(handles.axes_graph2_rr)
drawnow




%disp('start DrawData 1')

% draw data set and plot it: 


switch GD_Global.CurrentDataSet;
  
 case 1 % Two Moons with balanced classes [0.5,0.5]
  density = 2;
  [pointstrans,labelstrans] =GD_GenerateData(density,...
                                                   GD_Global.CurrentNumPoints,...
                                                   GD_Global.CurrentDataDim , ...
                                                   [0.5,0.5],...
                                                   GD_Global.CurrentVarNoise);
  
 case 2 % Two Moons with unbalanced classes [0.2,0.8]
  density=2;  
  [pointstrans,labelstrans] =GD_GenerateData(density,...
                                                   GD_Global.CurrentNumPoints,...
                                                   GD_Global.CurrentDataDim , ...
                                                   [0.2,0.8],...
                                                   GD_Global.CurrentVarNoise);
  
  
  
 case 3 % Two isotropic Gaussians balanced classes [0.5,0.5]
  density=3;
  [pointstrans,labelstrans] =GD_GenerateData(density,...
                                                   GD_Global.CurrentNumPoints,...
                                                   GD_Global.CurrentDataDim , ...
                                                   [0.5,0.5,0],...
                                                   GD_Global.CurrentVarNoise);
  
 case 4 % Two isotropic Gaussians unbalanced classe [0.2,0.8]
  density=3;
  [pointstrans,labelstrans] =GD_GenerateData(density,...
                                                   GD_Global.CurrentNumPoints,...
                                                   GD_Global.CurrentDataDim , ...
                                                   [0.2,0.8,0],...
                                                   GD_Global.CurrentVarNoise);

 case 5 % Two isotropic Gaussians with different variance and balanced classes [0.2,0.8]
  density=4;
    [pointstrans,labelstrans] =GD_GenerateData(density,...
                                                   GD_Global.CurrentNumPoints,...
                                                   GD_Global.CurrentDataDim , ...
                                                   [0.2,0.8,0],...
                                                   GD_Global.CurrentVarNoise);
  
 case 6 % Three isotropic Gaussians almost balanced [0.3,0.3,0.4]
  density=3;
  
    [pointstrans,labelstrans] =GD_GenerateData(density,...
                                                   GD_Global.CurrentNumPoints,...
                                                   GD_Global.CurrentDataDim , ...
                                                   [0.3,0.3,0.4],...
                                                   GD_Global.CurrentVarNoise);

  
end

GD_Global.points = pointstrans';




% set current axis to plot in: 
set(gcf, 'CurrentAxes',handles.axes_data_left); 


% now plot it: 
GD_PlotLabels(GD_Global.points(:,1:2), ones(size(GD_Global.points(:,1))), 'Data set (relvant dimensions)');
axis equal



% ------------------------------------------------------------
function ComputeSimilarityAndPlot(handles)
% ------------------------------------------------------------
global GD_Global; 
%disp('start compute sim')

% compute similarity matrix: 
GD_Global.D = DistEuclideanPiotrDollar( GD_Global.points, GD_Global.points ); % GD_ComputeDistanceMatrix(GD_Global.points,2);
GD_Global.S = exp(- GD_Global.D / (2 * GD_Global.CurrentSigma^2)); 
%compute_gaussian_kernel_matrix(GD_Global.points,GD_Global.points,GD_Global.CurrentSigma);


% plot similarity heat map: 
set(gcf, 'CurrentAxes',handles.axes_data_middle); cla
imagesc(GD_Global.S)
title('Heat map of similarity values')
colorbar('Xtick',[1,60], 'XtickLabels',[0,1], 'FontSize', 10)


% plot similarity histogram
set(gcf, 'CurrentAxes',handles.axes_data_right); cla
hist(GD_Global.S(:))
title('Histogram of the similarity values')


% set max epsilon to max distance: 
GD_Global.MaxEps = max(max(GD_Global.D)); 



% if one of the current graphs is an eps graph, assign good para to it: 
if (GD_Global.CurrentGraph1 == 1 || GD_Global.CurrentGraph1 == 4)
  GD_Global.CurrentGraphPara1 = SelectGoodEps(handles);
end
if (GD_Global.CurrentGraph2 == 1 || GD_Global.CurrentGraph2 == 4)  
  GD_Global.CurrentGraphPara2 = SelectGoodEps(handles);
end
% need to initialize sliders again afterwards: 
InitializeSliders(handles);




% ------------------------------------------------------------
function ComputeGraphAndPlot(handles, whichone)
% ------------------------------------------------------------
global GD_Global; 

%disp('start comptue graph')
if (whichone==1)
  type = GD_Global.CurrentGraph1;
  currentPara = GD_Global.CurrentGraphPara1;
  cla(handles.axes_graph1_left)
  cla(handles.axes_graph1_middle)
  cla(handles.axes_graph1_right)
  cla(handles.axes_graph1_rr)
  drawnow
  
else
  type = GD_Global.CurrentGraph2;
  currentPara = GD_Global.CurrentGraphPara2;
  cla(handles.axes_graph2_left)
  cla(handles.axes_graph2_middle)
  cla(handles.axes_graph2_right)
  cla(handles.axes_graph2_rr)
  drawnow

end

% compute adjacency matrix of graph: 
switch type; 
 case 1 %weighted eps graph
%  W = build_epsilon_graph(GD_Global.S, currentPara,'sim');
  Wunweighted = GD_BuildEpsilonGraph(GD_Global.D, currentPara, 'dist'); 
  W = Wunweighted .* GD_Global.S; 
 case 2 %symm knn 
  W = GD_BuildSymmetricKnnGraph(GD_Global.S, ceil(currentPara),'sim');
 case 3 % mut knn
  W = GD_BuildMutualKnnGraph(GD_Global.S, ceil(currentPara),'sim');
 case 4 % unweithed eps graph
  W = GD_BuildEpsilonGraph(GD_Global.D, currentPara, 'dist'); 
end

if (whichone ==1 )
  GD_Global.W1 = W;
  
else
  GD_Global.W2 = W;
end



% plot it graph itself: 
if (whichone==1)
  set(gcf, 'CurrentAxes',handles.axes_graph1_left); cla 
else
  set(gcf, 'CurrentAxes',handles.axes_graph2_left); cla 
end
cla

GD_PlotGraph(GD_Global.points(:,1:2), W, 'Connectivity')
axis equal





% plot the degrees of the graph nodes: 
if (whichone==1)
  set(gcf, 'CurrentAxes',handles.axes_graph1_middle); cla 
else
  set(gcf, 'CurrentAxes',handles.axes_graph2_middle); cla 
end
cla

d = sum(W,2); 
GD_PlotFunction(gca, GD_Global.points(:,1:2),d,'Degrees of the vertices')
%colorbar('Location','EastOutside')
axis equal



% % plot the degrees statitics: 
% if (whichone==1)
%   set(gcf, 'CurrentAxes',handles.axes_graph1_right); cla 
% else
%   set(gcf, 'CurrentAxes',handles.axes_graph2_right); cla 
% end
% cla
% hist(d); 
% title('Histogram of degrees')

% plot the adjacency heat map: 
if (whichone==1)
  set(gcf, 'CurrentAxes',handles.axes_graph1_right); cla
imagesc(GD_Global.W1); 

else
  set(gcf, 'CurrentAxes',handles.axes_graph2_right); cla 
  imagesc(GD_Global.W2); 
end
title('Adjacency matrix')



% plot statistics on connected components: 
%[num_components, index_components] = connected_components_ule(W); 
index_components = GD_GetComps(W); 
num_components = max(index_components);

size_components = zeros(max([num_components,5]),1);
for it=1:num_components
  size_components(it) = length(find(index_components==it));
end

size_components = sort(size_components,'descend');

if (whichone==1)
  set(gcf, 'CurrentAxes',handles.axes_graph1_rr); cla 
else
  set(gcf, 'CurrentAxes',handles.axes_graph2_rr); cla 
end
cla

bar(size_components)
title('Points per conn. comp.')
%ylabel('Points per component')
%xlabel('Index of the component')



% ------------------------------------------------------------
function goodeps = SelectGoodEps(handles)
% ------------------------------------------------------------
% set current value of current eps to something useful in the beginning:

global GD_Global; 


if (isempty(GD_Global.S))
  goodeps = GD_Global.DefaultEps; 
else 
  
  % try to select reasonable eps according to bold rule of thumb
  % mean of distance of k-th nearest neighbor: 
  
  k = 7; 
  Ssorted = sort(GD_Global.S,2,'descend');
  Sk = Ssorted(:,k+1); %attention, start to count at second col, first is always 1
  epsilon = mean(Sk); 

  Dsorted = sort(GD_Global.D,2,'ascend');
  Dk = Dsorted(:,k+1); %attention, start to count at second col, first is always 1
  epsilon = mean(Dk); 


  % but need to make sure it is ine the correct range: 
  if (GD_Global.MinEps <= epsilon && GD_Global.MaxEps >= epsilon)
    goodeps = epsilon; 
  else
    disp(sprintf('goodeps would be %f, which is not in the range',epsilon))
  goodeps = GD_Global.DefaultEps; 
  end
end


% ------------------------------------------------------------
function goodeps = SelectGoodSigma(handles)
% ------------------------------------------------------------
% set current value of current eps to something useful in the beginning:

global GD_Global; 


if (isempty(GD_Global.D))
  goodsigma = GD_Global.DefaultSigma; 
else 
  
  % try to select reasonable eps according to bold rule of thumb
  % mean of similarity of k-th nearest neighbor: 
  
  k = 7; 
  Dsorted = sort(GD_Global.D,2,'ascend');
  Dk = Dsorted(:,k+1); %attention, start to count at second col, first is always 1
  sigma = mean(Dk); 

  % but need to make sure it is ine the correct range: 
  if (GD_Global.MinSigma <= sigma && GD_Global.MaxSigma >= sigma)
    goodsigma = sigma; 
  else
    disp(sprintf('goodsigma would be %f, which is not in the range',sigma))
    goodsigma = GD_Global.DefaultSigma; 
  end
end


  

