function varargout = DemoSpectralClustering(varargin)
% Usage: DemoSpectralClustering()
% 
% Opens a large window, with all sorts of knobs and sliders. Just play :-) 
% 
% Documentation can be found at the GraphDemo webpage. 
% Written by Matthias Hein and Ulrike von Luxburg


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DemoSpectralClustering_OpeningFcn, ...
                   'gui_OutputFcn',  @DemoSpectralClustering_OutputFcn, ...
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


% --- Executes just before DemoSpectralClustering is made visible.
function DemoSpectralClustering_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DemoSpectralClustering (see VARARGIN)



% Choose default command line output for DemoSpectralClustering
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% ULE: 
% to avoid the following weird error message: 
% Warning: RGB color data not yet supported in Painter's mode.
% is due to automatic choice of renderer by matlab. 
set(gcf, 'Renderer', 'Zbuffer')
warning('off','MATLAB:dispatcher:InexactMatch')


global ALLDATA;
global SCDATA;
ALLDATA = struct('Dim'  , 3, 'MinDim'   , 2, 'MaxDim'    , 200, 'Num', 500, 'NumKNN', 10,  'MinKNN', 1, 'MaxKNN', 200, 'Eps', 0.3, 'MinEps', 0.01, 'MaxEps', 10.0, 'Density', 1, 'x',0, 'y', 0, 'Labeled', 0, 'GraphType', 1, 'K', 0, 'Gamma',1,'MaxGamma',10,'MinGamma',0.1);
SCDATA = struct( 'Output',0, 'NumCluster', 2, 'MinCluster', 2, 'MaxCluster', 9);


set(gcf, 'Name', 'Demo Spectral Clustering', ...
            'Units', 'normalized', ...  %units of measurement used to interpret the position vector
            'Visible','off');
        
% set controls to the initial values
set(handles.SldKNN,'Value',(ALLDATA.NumKNN-ALLDATA.MinKNN)/(ALLDATA.MaxKNN-ALLDATA.MinKNN));
set(handles.SldNrClusters,'Value',(SCDATA.NumCluster-SCDATA.MinCluster)/(SCDATA.MaxCluster-SCDATA.MinCluster));
set(handles.SldWeights,'Value',(ALLDATA.Gamma-ALLDATA.MinGamma)/(ALLDATA.MaxGamma-ALLDATA.MinGamma));

% set all static text elements
set(handles.TxtKNN,'String',['K=',num2str(ALLDATA.NumKNN)]);
set(handles.TxtWeights,'String',['Sigma =',num2str(ALLDATA.Gamma)]);
set(handles.TxtNrClusters,'String',['N=',num2str(SCDATA.NumCluster)]);
set(handles.TxtDim,'String',num2str(ALLDATA.Dim));

% update slider for labeled data
set(handles.SldNrClusters,'SliderStep',[1/(SCDATA.MaxCluster-SCDATA.MinCluster),1/(SCDATA.MaxCluster-SCDATA.MinCluster)]);



% generate data (inital dataset: two moons with balanced classes)
[ALLDATA.x,ALLDATA.y]=GD_GenerateData(2,ALLDATA.Num,3,[0.5,0.5],0.01);

UpdateALL(handles)




% --- Outputs from this function are returned to the command line.
function varargout = DemoSpectralClustering_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on slider movement.
function SldKNN_Callback(hObject, eventdata, handles)
% hObject    handle to SldKNN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ALLDATA;
value = get(hObject,'Value');
if(ALLDATA.GraphType<2)
  ALLDATA.NumKNN = floor(value*(ALLDATA.MaxKNN-ALLDATA.MinKNN) + ALLDATA.MinKNN);
  set(handles.TxtKNN,'String',['K=',num2str(ALLDATA.NumKNN)]);
else
  ALLDATA.Eps = value*(ALLDATA.MaxEps-ALLDATA.MinEps) + ALLDATA.MinEps;
  set(handles.TxtKNN,'String',['Eps=',num2str(ALLDATA.Eps,'%2.2f')]);
end
%UpdateALL(handles);


% --- Executes during object creation, after setting all properties.
function SldKNN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SldKNN (see GCBO)
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
global ALLDATA;
value = get(hObject,'Value');
ALLDATA.Gamma = value*(ALLDATA.MaxGamma-ALLDATA.MinGamma) + ALLDATA.MinGamma;
set(handles.TxtWeights,'String',['Sigma =',num2str(ALLDATA.Gamma,'%2.1f')]);

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


% --- Executes on slider movement.
function SldNrClusters_Callback(hObject, eventdata, handles)
% hObject    handle to SldNrClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global SCDATA;
value = get(hObject,'Value');
SCDATA.NumCluster = floor(value*(SCDATA.MaxCluster-SCDATA.MinCluster) + SCDATA.MinCluster);
set(handles.TxtNrClusters,'String',['N=',num2str(SCDATA.NumCluster)]);

%UpdateALL(handles);

% --- Executes during object creation, after setting all properties.
function SldNrClusters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SldNrClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end





% --- Executes on selection change in MenuData.
function MenuData_Callback(hObject, eventdata, handles)
% hObject    handle to MenuData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns MenuData contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MenuData
global ALLDATA;

axes(handles.AxsData);
cla;

popup_sel_index = get(handles.MenuData, 'Value');
switch popup_sel_index
    case 1 % Two Moons with balanced classes [0.5,0.5]
       ALLDATA.Density=2;
       % generate data 
       ALLDATA.Num=500;
       [ALLDATA.x,ALLDATA.y]=GD_GenerateData(ALLDATA.Density,ALLDATA.Num,ALLDATA.Dim,[0.5,0.5],0.01);
       
    case 2 % Two Moons with unbalanced classes [0.2,0.8]
       ALLDATA.Density=2;
       % generate data 
       ALLDATA.Num=500;
       [ALLDATA.x,ALLDATA.y]=GD_GenerateData(ALLDATA.Density,ALLDATA.Num,ALLDATA.Dim,[0.2,0.8],0.01);
      
    case 3 % Two isotropic Gaussians balanced classes [0.5,0.5]
      ALLDATA.Density=3;
      % generate data 
      ALLDATA.Num=500;
      [ALLDATA.x,ALLDATA.y]=GD_GenerateData(ALLDATA.Density,ALLDATA.Num,ALLDATA.Dim,[0.5,0.5,0],0.01);
     
    case 4 % Two isotropic Gaussians unbalanced classes [0.2,0.8]
      ALLDATA.Density=3;
      % generate data 
      ALLDATA.Num=500;
      [ALLDATA.x,ALLDATA.y]=GD_GenerateData(ALLDATA.Density,ALLDATA.Num,ALLDATA.Dim,[0.2,0.8,0],0.01);
      
    case 5 % Two isotropic Gaussians with different variance and balanced classes [0.2,0.8]
      ALLDATA.Density=4;
      % generate data 
      ALLDATA.Num=500;
      [ALLDATA.x,ALLDATA.y]=GD_GenerateData(ALLDATA.Density,ALLDATA.Num,ALLDATA.Dim,[0.5,0.5,0],0.01);
   
    case 6 % Three isotropic Gaussians almost balanced [0.3,0.3,0.4]
       ALLDATA.Density=3;
       % generate data 
       ALLDATA.Num=500;
       [ALLDATA.x,ALLDATA.y]=GD_GenerateData(ALLDATA.Density,ALLDATA.Num,ALLDATA.Dim,[0.3,0.3,0.4],0.01); 
          
end

UpdateALL(handles);


% --- Executes during object creation, after setting all properties.
function MenuData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MenuData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MenuGraph.
function MenuGraph_Callback(hObject, eventdata, handles)
% hObject    handle to MenuGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns MenuGraph contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MenuGraph

global ALLDATA;
value = get(hObject,'Value');
switch value
    case 1, ALLDATA.GraphType = 1; set(handles.TxtNrNN,'String','Number K of Neighbors'); 
                                   value = (ALLDATA.NumKNN - ALLDATA.MinKNN)/(ALLDATA.MaxKNN - ALLDATA.MinKNN);
                                   set(handles.SldKNN,'Value',value);
                                   set(handles.TxtKNN,'String',['K=',num2str(ALLDATA.NumKNN,'%d')]);
    case 2, ALLDATA.GraphType = 0; set(handles.TxtNrNN,'String','Number K  of Neighbors'); 
                                   value = (ALLDATA.NumKNN - ALLDATA.MinKNN)/(ALLDATA.MaxKNN - ALLDATA.MinKNN);
                                   set(handles.SldKNN,'Value',value);
                                   set(handles.TxtKNN,'String',['K=',num2str(ALLDATA.NumKNN,'%d')]);
    case 3, if(ALLDATA.Density~=6) ALLDATA.GraphType = 2; 
                                   set(handles.TxtNrNN,'String','Epsilon Parameter'); 
                                   value = (ALLDATA.Eps - ALLDATA.MinEps)/(ALLDATA.MaxEps - ALLDATA.MinEps);
                                   set(handles.SldKNN,'Value',value); 
                                   set(handles.TxtKNN,'String',['Eps=',num2str(ALLDATA.Eps,'%2.2f')]);
            else
              if(ALLDATA.GraphType==1)
                set(handles.PopGraphType,'Value',1);
              end
              if(ALLDATA.GraphType==0)
                set(handles.PopGraphType,'Value',2);
              end
           end                             
end
%UpdateALL(handles);

% --- Executes during object creation, after setting all properties.
function MenuGraph_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MenuGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function SldDim_Callback(hObject, eventdata, handles)
% hObject    handle to SldDim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global ALLDATA;
value = get(hObject,'Value');
ALLDATA.Dim = floor(value*(ALLDATA.MaxDim-ALLDATA.MinDim) + ALLDATA.MinDim);
set(handles.TxtDim,'String',num2str(ALLDATA.Dim));

popup_sel_index = get(handles.MenuData, 'Value');
switch popup_sel_index
    case 1 % Two Moons with balanced classes [0.5,0.5]
       ALLDATA.Density=2;
       % generate data 
       ALLDATA.Num=500;
       [ALLDATA.x,ALLDATA.y]=GD_GenerateData(ALLDATA.Density,ALLDATA.Num,ALLDATA.Dim,[0.5,0.5],0.01);
       
    case 2 % Two Moons with unbalanced classes [0.2,0.8]
       ALLDATA.Density=2;
       % generate data 
       ALLDATA.Num=500;
       [ALLDATA.x,ALLDATA.y]=GD_GenerateData(ALLDATA.Density,ALLDATA.Num,ALLDATA.Dim,[0.2,0.8],0.01);
      
    case 3 % Two isotropic Gaussians balanced classes [0.5,0.5]
      ALLDATA.Density=3;
      % generate data 
      ALLDATA.Num=500;
      [ALLDATA.x,ALLDATA.y]=GD_GenerateData(ALLDATA.Density,ALLDATA.Num,ALLDATA.Dim,[0.5,0.5,0],0.01);
     
    case 4 % Two isotropic Gaussians unbalanced classes [0.2,0.8]
      ALLDATA.Density=3;
      % generate data 
      ALLDATA.Num=500;
      [ALLDATA.x,ALLDATA.y]=GD_GenerateData(ALLDATA.Density,ALLDATA.Num,ALLDATA.Dim,[0.2,0.8,0],0.01);
      
    case 5 % Two isotropic Gaussians with different variance and balanced classes [0.2,0.8]
      ALLDATA.Density=4;
      % generate data 
      ALLDATA.Num=500;
      [ALLDATA.x,ALLDATA.y]=GD_GenerateData(ALLDATA.Density,ALLDATA.Num,ALLDATA.Dim,[0.5,0.5,0],0.01);
   
    case 6 % Three isotropic Gaussians almost balanced [0.3,0.3,0.4]
       ALLDATA.Density=3;
       % generate data 
       ALLDATA.Num=500;
       [ALLDATA.x,ALLDATA.y]=GD_GenerateData(ALLDATA.Density,ALLDATA.Num,ALLDATA.Dim,[0.3,0.3,0.4],0.01); 
          
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


% --- Executes on button press in PshUpdateALL.
function PshUpdateALL_Callback(hObject, eventdata, handles)
% hObject    handle to PshUpdateALL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UpdateALL(handles);

%--------------------------------------------------------------------------
function DrawData(Fig)
global ALLDATA;

if(ALLDATA.Density==6)
  cla(Fig);
end

if(ALLDATA.Density~=6)
  num_classes=max(ALLDATA.y);
  colors = {'red','blue','black'};
  hold(Fig,'on'); 
  % unlabeled data
  for i=1:num_classes
   plot(Fig,ALLDATA.x(1,ALLDATA.y==i),ALLDATA.x(2,ALLDATA.y==i),'MarkerEdgeColor',colors{i},'Marker','.','LineStyle','none')
  end
  axis(Fig,'equal');
  hold(Fig,'off'); 
end

%--------------------------------------------------------------------------
function ShowOutput(Fig,output)
global ALLDATA;
global SCDATA;

cla(Fig);

if(ALLDATA.Density~=6)
  num_classes=max(SCDATA.Output);
  colors = {[1, 0, 0], [0,0,1], [0,0,0], [0,1,0], [0,1,1], [1,1,0], [1,0,1], [0.5,0,0], [0,0,0.5],[0,0.5,0]};
  %colors = {'red','blue','black','green','yellow','magenta','cyan'};
  hold(Fig,'on'); 
  % output of the classifier
  for i=1:num_classes
   plot(Fig,ALLDATA.x(1,SCDATA.Output==i),ALLDATA.x(2,SCDATA.Output==i),'MarkerEdgeColor',colors{i},'Marker','.','LineStyle','none')
  end
  % points which have no label
  plot(Fig,ALLDATA.x(1,SCDATA.Output==0),ALLDATA.x(2,SCDATA.Output==0),'MarkerEdgeColor','magenta','Marker','.','LineStyle','none')
  axis(Fig,'equal');
  hold(Fig,'off'); 
end




%--------------------------------------------------------------------------
function BuildWeights()
global ALLDATA;

%tic
dist2 =DistEuclideanPiotrDollar(ALLDATA.x',ALLDATA.x'); % squared distances
if(ALLDATA.GraphType<2)
  if(ALLDATA.Density<6)
    [SD,IX]=sort(dist2,2);
    KNN     = IX(:,2:ALLDATA.NumKNN+1)';
    KNNDist = SD(:,2:ALLDATA.NumKNN+1)';
  else
    load USPSKNN;
    KNN    =KNN(1:ALLDATA.NumKNN,:);
    KNNDist=KNNDist(1:ALLDATA.NumKNN,:);
  end
  % get kNN weight matrix
  ALLDATA.K = sparse(ALLDATA.Num,ALLDATA.Num);
  for i=1:ALLDATA.Num
    ALLDATA.K(KNN(:,i),i)=exp(-1/(2*ALLDATA.Gamma^2)*KNNDist(:,i));
  end
  % note that K is not symmetric yet , now we symmetrize K 
  if(ALLDATA.GraphType==1) ALLDATA.K=(ALLDATA.K+ALLDATA.K')+abs(ALLDATA.K-ALLDATA.K'); ALLDATA.K=0.5*ALLDATA.K; end
  if(ALLDATA.GraphType==0) ALLDATA.K=(ALLDATA.K+ALLDATA.K')-abs(ALLDATA.K-ALLDATA.K'); ALLDATA.K=0.5*ALLDATA.K; end 
else
  ALLDATA.K = exp(-1/(2*ALLDATA.Gamma^2)*dist2).*(dist2 < ALLDATA.Eps^2 & dist2~=0);
end
%t=toc; display(['Time for building weights: ',num2str(t)]);



% if(ALLDATA.GraphType<2)
%   if(ALLDATA.Density<6)
%     [KNN,KNNDist]=getKNN(ALLDATA.x,ALLDATA.NumKNN);
%   else
%     load USPSKNN;
%     KNN    =KNN(1:ALLDATA.NumKNN,:);
%     KNNDist=KNNDist(1:ALLDATA.NumKNN,:);
%   end
%   % get kNN weight matrix
%   ALLDATA.K = getSparseWeightMatrixFromKNN(KNNDist,KNN,1/(2*ALLDATA.Gamma^2),ALLDATA.GraphType,1); 
%   % note that K is not symmetric yet (in the case of the symmetric KNN), now we symmetrize K 
%   if(ALLDATA.GraphType==1) ALLDATA.K=(ALLDATA.K+ALLDATA.K')+abs(ALLDATA.K-ALLDATA.K'); ALLDATA.K=0.5*ALLDATA.K; end
% else
%   dist=getDistanceMatrix(ALLDATA.x);
%   ALLDATA.K = exp(-1/(2*ALLDATA.Gamma^2)*dist.^2).*(dist < ALLDATA.Eps & dist~=0);
% end

%--------------------------------------------------------------------------
function DrawWeights(Fig)
global ALLDATA

cla(Fig);

if(ALLDATA.Density~=6)
  hold(Fig,'on');
  STEP=1; NNZK=nnz(ALLDATA.K);
%   if(NNZK>60000)
%    STEP=ceil(NNZK/60000); display(['WARNING: TOO MANY EDGES, WILL ONLY SHOW 1/',num2str(STEP),' of all points']);
%   end
  xx=zeros(2*ALLDATA.Num,1);
  yy=zeros(2*ALLDATA.Num,1);
%  tic
  for i=1:STEP:ALLDATA.Num
    indices = find(ALLDATA.K(i+1:end,i)>0)+i;
    NumIndices=length(indices);
    xx(1:2:2*NumIndices)=ALLDATA.x(1,i);
    xx(2:2:2*NumIndices)=ALLDATA.x(1,indices);
    yy(1:2:2*NumIndices)=ALLDATA.x(2,i);
    yy(2:2:2*NumIndices)=ALLDATA.x(2,indices);
    plot(Fig,xx(1:2*NumIndices),yy(1:2*NumIndices),'-g');
  end
%  t1=toc
%   STEP=1;
%   hold(Fig2,'on');
%   tic
%   for i=1:STEP:ALLDATA.Num
%     indices = find(ALLDATA.K(i+1:end,i)>0)+i;
%     NumIndices=length(indices);
%     %plot(Fig,[repmat(ALLDATA.x(1,i),1,NumIndices); ALLDATA.x(1,indices)], [repmat(ALLDATA.x(2,i),1,NumIndices);ALLDATA.x(2,indices)], '-g');
%     if(NumIndices>0)
%      plot(Fig2,[repmat(ALLDATA.x(1,i),1,NumIndices); ALLDATA.x(1,indices)], [repmat(ALLDATA.x(2,i),1,NumIndices);ALLDATA.x(2,indices)], '-g');
%      %plot(Fig,[repmat(ALLDATA.x(1,i),NumIndices,1), ALLDATA.x(1,indices)], [repmat(ALLDATA.x(2,i),NumIndices,1), ALLDATA.x(2,indices)], '-g');
%     end
%   end
%   t2=toc
%    hold(Fig2,'off');
  axis(Fig,'equal');
  hold(Fig,'off');
  DrawData(Fig);
end

%--------------------------------------------------------------------------
function UpdateSC(handles)
global ALLDATA
global SCDATA

%disp('drawing eigs and clust')
   
% compute the clustering, the eigvals, and eigvecs: 
normalized = 1; %always use normalized sp clust
[SCDATA.Output,centers,eigvecs,eigvals] = GD_SpectralClustering(ALLDATA.K,SCDATA.NumCluster,normalized);
     
% plot the clustering: 
%cla(handles.AxsClustering);  
set(gcf,'CurrentAxes',handles.AxsClustering);   
ShowOutput(handles.AxsClustering)
%plot_labels(ALLDATA.x',clustering,'Current Clustering')
drawnow
     
     
% plot the eigenvalues: 
%     set(mainfig,'CurrentAxes',axes_eigenvalues);   
%     cla, hold all 
%cla(handles.AxsEvDistribution);
%set(handles.AxsEvDistribution,'Units','normalized','Position',[0.01 0.05 0.26 0.26])
plot(handles.AxsEvDistribution,eigvals, 'x'); 
title(handles.AxsEvDistribution,'Eigenvalues','Units','normalized')
axis(handles.AxsEvDistribution,'tight');
  
     
 %     %plot the first few eigenvectors: 
%          set(mainfig,'CurrentAxes',axes_eigenvector2);   
%          cla, hold all 
%      plot_function(global_data_points,eigvecs(:,2), 'Second eigenvector'); 
     
 cla(handles.AxsEv1); cla(handles.AxsEv2); cla(handles.AxsEv3); cla(handles.AxsEv4); cla(handles.AxsEv5); 
 %set(gcf,'Name','Eigenvectors')
 %    set(gcf,'Units','normalized','Position',[0.01 0.42 0.6 0.2])
     
 fmin = min(min(eigvecs(:,1:5))); fmax = max(max(eigvecs(:,1:5)));
 GD_PlotFunction(handles.AxsEv1, ALLDATA.x',eigvecs(:,1), 'eig 1',fmin,fmax);
 set(handles.AxsEv1,'XTick',[]); set(handles.AxsEv1,'YTick',[]); set(handles.AxsEv1,'XTickLabel',[]); set(handles.AxsEv1,'YTickLabel',[]);

 GD_PlotFunction(handles.AxsEv2,ALLDATA.x',eigvecs(:,2), 'eig 2',fmin,fmax);
 set(handles.AxsEv2,'XTick',[]); set(handles.AxsEv2,'YTick',[]); set(handles.AxsEv2,'XTickLabel',[]); set(handles.AxsEv2,'YTickLabel',[]);
 
 GD_PlotFunction(handles.AxsEv3,ALLDATA.x',eigvecs(:,3), 'eig 3',fmin,fmax);
 set(handles.AxsEv3,'XTick',[]); set(handles.AxsEv3,'YTick',[]); set(handles.AxsEv3,'XTickLabel',[]); set(handles.AxsEv3,'YTickLabel',[]);
  
 GD_PlotFunction(handles.AxsEv4,ALLDATA.x',eigvecs(:,4), 'eig 4',fmin,fmax);
 set(handles.AxsEv4,'XTick',[]); set(handles.AxsEv4,'YTick',[]); set(handles.AxsEv4,'XTickLabel',[]); set(handles.AxsEv4,'YTickLabel',[]);
 
 GD_PlotFunction(handles.AxsEv5,ALLDATA.x',eigvecs(:,5), 'eig 5',fmin,fmax);
 set(handles.AxsEv5,'XTick',[]); set(handles.AxsEv5,'YTick',[]); set(handles.AxsEv5,'XTickLabel',[]); set(handles.AxsEv5,'YTickLabel',[]);
 
 % "hand-made" colorbar
 cmap = colormap;
 set(gcf,'CurrentAxes',handles.AxsColorbar); 
 cla(handles.AxsColorbar);
 set(handles.AxsColorbar,'YAxisLocation','right');   
 axis(handles.AxsColorbar,[0 1 0 1]);
 NumColors=size(cmap,1);
 step=1/NumColors;
 xvector(1)=0; xvector(2)=1; xvector(3)=1; xvector(4)=0;
 hold(handles.AxsColorbar,'on');
 for i=1:NumColors
   yvector(1)=(i-1)*step; yvector(2)=(i-1)*step; 
   yvector(3)=i*step; yvector(4)=i*step;
   fill(xvector,yvector,cmap(i,:),'EdgeColor','none');
 end
 hold(handles.AxsColorbar,'off');
 mid = (-fmin/(fmax-fmin)); 
 if(mid<=0) mid=0.01; end
 if(mid>=1) mid=0.99; end
 set(handles.AxsColorbar,'XTick',[],'XTickLabel',[]);
 set(handles.AxsColorbar,'YTick',[0,mid,1],'YTickLabel',{num2str(fmin+1/60*(fmax-fmin),'%2.2f'),num2str(0),num2str(fmax,'%2.2f')});
 %colorbar('peer',handles.AxsEv5,'YTick',[1,mid,60],'YTickLabel',{num2str(fmin+1/60*(fmax-fmin),'%2.2f'),num2str(0),num2str(fmax,'%2.2f')})
 %hold off
 
 % plot the embedding in R^3:
 set(gcf,'CurrentAxes',handles.AxsEmbedding);
 cla(handles.AxsEmbedding);
 rotate3d(handles.AxsEmbedding,'on');

 colors = [[1, 0, 0]; [0,0,1]; [0,0,0]; [0,1,0]; [0,1,1]; [1,1,0]; [1,0,1]; [0.5,0,0]; [0,0,0.5]; [0,0.5,0]];
 hold(handles.AxsEmbedding,'on');
 if(sum(abs(eigvecs(:,1)-mean(eigvecs(:,1))*ones(size(eigvecs(:,1),1),1)))<1E-10)
   scatter3(handles.AxsEmbedding, eigvecs(:,2), eigvecs(:,3), eigvecs(:,4), 5,colors(ALLDATA.y,:),'filled')  
   % plot centers
   for i=1:size(centers,1)
     if(size(centers,2)==2)
       plot3(handles.AxsEmbedding,centers(i,2),0,0,'bx','markersize',8);
     end
     if(size(centers,2)==3)
       plot3(handles.AxsEmbedding,centers(i,2),centers(i,3),0,'bx','markersize',8);
     end
     if(size(centers,2)>=4)
       plot3(handles.AxsEmbedding,centers(i,2),centers(i,3),centers(i,4),'bx','markersize',8);
     end
   end
    axis(handles.AxsEmbedding,'equal');
   title(handles.AxsEmbedding,'Embedding in R^3 - EV 2-4','Units','normalized')
   xLabel(handles.AxsEmbedding,'EV2');,
   yLabel(handles.AxsEmbedding,'EV3');
   zLabel(handles.AxsEmbedding,'EV4');
 else
   scatter3(handles.AxsEmbedding,eigvecs(:,1), eigvecs(:,2), eigvecs(:,3), 5,colors(ALLDATA.y,:),'filled')
   
   % plot centers
   for i=1:size(centers,1)
    if(size(centers,2)>=3)
      plot3(handles.AxsEmbedding,centers(i,1),centers(i,2),centers(i,3),'bx','markersize',8);
    end
    if(size(centers,2)==2)
       plot3(handles.AxsEmbedding,centers(i,1),centers(i,2),0,'bx','markersize',8);
    end  
    if(size(centers,2)==1)
       plot3(handles.AxsEmbedding,centers(i,1),0,0,'bx','markersize',8);
    end  
   end
   axis(handles.AxsEmbedding,'equal');
   title(handles.AxsEmbedding,'Embedding in R^3 - EV 1-3','Units','normalized')
   xLabel(handles.AxsEmbedding,'EV1');,
   yLabel(handles.AxsEmbedding,'EV2');
   zLabel(handles.AxsEmbedding,'EV3');
 end
 hold(handles.AxsEmbedding,'off');
   

%--------------------------------------------------------------------------
function UpdateALL(handles)
global ALLDATA
global SCDATA

% clear all windows
cla(handles.AxsData);
cla(handles.AxsGraph);
cla(handles.AxsClustering);
cla(handles.AxsEv1); cla(handles.AxsEv2); cla(handles.AxsEv3); cla(handles.AxsEv4); cla(handles.AxsEv5);
cla(handles.AxsEvDistribution);
drawnow;
%cla(handles.AxsEmbedding);

% draw it in the input window
DrawData(handles.AxsData);
title(handles.AxsData,'Data','Units','normalized');
title(handles.AxsClustering,'Current Clustering','Units','normalized');

% build and draw graph
BuildWeights();
DrawWeights(handles.AxsGraph);
switch ALLDATA.GraphType
    case 0, title(handles.AxsGraph ,'Mutual KNN','Units','normalized');
    case 1, title(handles.AxsGraph ,'Symmetric KNN','Units','normalized');
    case 2, title(handles.AxsGraph ,'Epsilon Neighborhood','Units','normalized');
end

c = GD_GetComps(ALLDATA.K);
NumComps=max(c);
set(handles.TxtNumComps,'String',['Number of connected components: ',num2str(NumComps)]);

UpdateSC(handles);












