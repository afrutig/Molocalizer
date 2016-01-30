function varargout = molo_select_GUI(varargin)
% MOLO_SELECT_GUI MATLAB code for molo_select_GUI.fig
%      MOLO_SELECT_GUI, by itself, creates a new MOLO_SELECT_GUI or raises the existing
%      singleton*.
%
%      H = MOLO_SELECT_GUI returns the handle to a new MOLO_SELECT_GUI or the handle to
%      the existing singleton*.
%
%      MOLO_SELECT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOLO_SELECT_GUI.M with the given input arguments.
%
%      MOLO_SELECT_GUI('Property','Value',...) creates a new MOLO_SELECT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before molo_select_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to molo_select_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help molo_select_GUI

% Last Modified by GUIDE v2.5 29-Jan-2016 15:21:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @molo_select_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @molo_select_GUI_OutputFcn, ...
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

% ----------------------------------------------------------------------------------------------------

% --- Executes just before molo_select_GUI is made visible.
function molo_select_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to molo_select_GUI (see VARARGIN)
handles.output = hObject;
% initialize the handles structure derived from the other GUI. 
handles = initialize_handles_structure(handles);

% initalize variables that will be needed later on

% initialize the array, points to delete
handles.points_to_delete = {}
handles.points_to_add = {}
handles.moloVector = {}
handles.MoloLocationsConfirmedbool = false;

axes(handles.axes1)

% per default display the last image

% set the image slider to the start values


set(handles.image_selector,'Min',1);
set(handles.image_selector,'Max',length(handles.filenames));
set(handles.image_selector,'Value',length(handles.filenames));
sliderStep = [1, 1] / (length(handles.filenames)-1)
set(handles.image_selector, 'SliderStep',sliderStep);
imagesc(handles.current_image);


handles = update_axis1(handles)

set(handles.Confirm_Molo_Selection,'BackgroundColor',[1 0 0]);
set(handles.Select_Background_Area,'BackgroundColor',[1 0 0]);


% Update handles structure
guidata(hObject, handles);

function handles = initialize_handles_structure(handles)

data_from_other_GUI = getappdata(0,'data_to_pass_to_other_GUI');

handles.path = data_from_other_GUI.path
handles.filenames = data_from_other_GUI.filenames;
handles.current_image = data_from_other_GUI.current_image;





% --- Outputs from this function are returned to the command line.
function varargout = molo_select_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on slider movement.
% this is the tolerance slider

function Threshold_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles = update_axis1(handles)

set(handles.Confirm_Molo_Selection,'BackgroundColor',[1 0 0]);
set(handles.Select_Background_Area,'BackgroundColor',[1 0 0]);


guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Threshold_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Min',-5);
set(hObject,'Max',20);
set(hObject,'Value',10);

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function image_selector_Callback(hObject, eventdata, handles)
% hObject    handle to image_selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

axes(handles.axes1)
get(hObject,'Value')
% per default display the last image
handles.current_image = imread(handles.filenames(round(get(hObject,'Value'))).name);
imagesc(handles.current_image);
handles = update_axis1(handles)

set(handles.MoloLocationsConfirmed,'BackgroundColor',[1 0 0]);


guidata(hObject, handles);

function handles = update_axis1(handles)

cla(handles.axes1)
[handles.image_above_threshold,handles.centroids] = getMoloSpots(handles.current_image,handles.Threshold_Slider);
handles.moloVector = generateMoloVector(handles.centroids,handles.points_to_add,handles.points_to_delete,handles.radius,handles.current_image,handles);
plotSelection(handles);

if isfield(handles,'Background_Area')
    rectangle('Position',handles.Background_Area)

end




% --- Executes during object creation, after setting all properties.
function image_selector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image_selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Add_a_position.
% to add a point to the molovector
function Add_a_position_Callback(hObject, eventdata, handles)
% hObject    handle to Add_a_position (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

k = waitforbuttonpress;

point = get(gca,'CurrentPoint');
point = round(point(1,1:2));
% check whether the point is already in the vector points_to_add, remove it
% if it is there


% here you have to apply the recentering, just search in the neighbouring
% 20 pixels (square), commented sections are for recentering. 
diameter_pixel = 40;

x_ind = point(1) - diameter_pixel/2:point(1) + diameter_pixel/2;
y_ind = point(2) - diameter_pixel/2:point(2) + diameter_pixel/2;

square_image = handles.image_above_threshold(y_ind,x_ind);

s = regionprops(square_image,'centroid');
centroids = cat(1, s.Centroid)
y_new = centroids(1);
x_new = centroids(2);
% figure;
% imagesc(square_image)

% viscircles([y_new, x_new], 10,'EdgeColor','g','LineWidth',2,'DrawBackgroundCircle',false);

point(1) = point(1) + y_new - diameter_pixel/2 - 1;
point(2) = point(2) + x_new - diameter_pixel/2 - 1;







for i = 1:length(handles.points_to_delete)
    
    if handles.radius > (handles.points_to_delete{i}(1,1) - point(1,1))^2 + (handles.points_to_delete{i}(1,2) - point(1,2))^2
            
            handles.points_to_delete(i) = []
            break;
            
    end
    
end
    
    

handles.points_to_add{end+1} = point;

% handles.moloVector = generateMoloVector(handles.centroids,handles.points_to_add,handles.points_to_delete,handles.radius,handles.current_image,handles);

% plotSelection(handles);
handles = update_axis1(handles)


guidata(hObject, handles);

% --- Executes on button press in Delete_a_position.
% to delete a point from the array.
function Delete_a_position_Callback(hObject, eventdata, handles)
% hObject    handle to Delete_a_position (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = waitforbuttonpress;
point = get(gca,'CurrentPoint');
point = round(point(1,1:2));

% check whether the point is already in the vector points_to_add, remove it
% if it is there

for i = 1:length(handles.points_to_add)
    
    if handles.radius > (handles.points_to_add{i}(1,1) - point(1,1))^2 + (handles.points_to_add{i}(1,2) - point(1,2))^2
            
            handles.points_to_add(i)= [];
            
            break;
            
    end
    
end

handles.points_to_delete{end+1} = point;

handles = update_axis1(handles)
%handles.moloVector = generateMoloVector(handles.centroids,handles.points_to_add,handles.points_to_delete,handles.radius,handles.current_image,handles);
%plotSelection(handles);

guidata(hObject, handles);


function Pixelsize_Callback(hObject, eventdata, handles)
% hObject    handle to Pixelsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pixelsize = str2double(get(hObject,'String'));
handles.radius = handles.radius_um/handles.pixelsize
% Hints: get(hObject,'String') returns contents of Pixelsize as text
%        str2double(get(hObject,'String')) returns contents of Pixelsize as a double
%plotSelection(handles);
handles = update_axis1(handles)

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Pixelsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pixelsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.pixelsize = 12.5; % default pixelsize of the image.
handles.radius_um = 350; % radius of influence for the selection of points in the image with the molo selection at the beginning (in um, pixelsize is 12.5 um)

handles.radius = handles.radius_um/handles.pixelsize;

set(hObject,'String',handles.pixelsize)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


guidata(hObject, handles);

% --- Executes on button press in Select_Molo_Area.
function Select_Molo_Area_Callback(hObject, eventdata, handles)
% hObject    handle to Select_Molo_Area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MoloArea = getrect(handles.axes1);

% handles.moloVector = generateMoloVector(handles.centroids,handles.points_to_add,handles.points_to_delete,handles.radius,handles.current_image,handles);
% plotSelection(handles);
handles = update_axis1(handles)

guidata(hObject, handles);


% --- Executes on button press in Confirm_Molo_Selection.
% to confirm the moloselection

function Confirm_Molo_Selection_Callback(hObject, eventdata, handles)
% hObject    handle to Confirm_Molo_Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% this function will also Group the lines

hilf = cell2mat(handles.moloVector);
x_coord = hilf(1:2:end-1);
hilf = cell2mat(handles.moloVector);
y_coord = hilf(2:2:end);

% do the clustering of the data into as many lines, as the value of number of mololines.
clustered_data = kmeans(y_coord',handles.number_of_mololines);

% commented stuff is to test, whether the lines are detected correctly 
% styles = 'rgb'
% figure1 = figure()
% hold on;
% here the three mololines are gathered.


y_means = zeros(1,handles.number_of_mololines);

for i = 1:handles.number_of_mololines 
    
    y_means(1,i) = mean(y_coord(clustered_data == i)) % sort the x coordinate ascending. 
   
    % plot(x_coord(clustered_data == i),y_coord(clustered_data == i),'Color',styles(i))
    
    
end

% sort them correctly
[ymeans index] = sort(y_means);


for i = 1:handles.number_of_mololines 
    
    handles.confirmedMoloSpots(i).x_coord = sort(x_coord(clustered_data == index(i))); % sort the x coordinate ascending. 
    handles.confirmedMoloSpots(i).y_coord = y_coord(clustered_data == index(i));
    % plot(x_coord(clustered_data == i),y_coord(clustered_data == i),'Color',styles(i))
    
end


   confirmedMoloSpots = handles.confirmedMoloSpots;
   
   set(handles.Confirm_Molo_Selection,'BackgroundColor',[0 1 0]);
 
   
   % save the Molo

   save(strcat(handles.path,'/Evaluation/Confirmed_Molo_Spots_positions.mat'),'confirmedMoloSpots');
   
   number_of_mololines = handles.number_of_mololines;
   setappdata(0,'confirmedMoloSpots',confirmedMoloSpots);
   setappdata(0,'number_of_mololines',number_of_mololines);
   Molocalizer();
   
guidata(hObject, handles);




function num_mololines_value_Callback(hObject, eventdata, handles)
% hObject    handle to num_mololines_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.number_of_mololines = str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of num_mololines_value as text
%        str2double(get(hObject,'String')) returns contents of num_mololines_value as a double
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function num_mololines_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_mololines_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.number_of_mololines = str2double(get(hObject,'String'));
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

guidata(hObject, handles);


% --- Executes on button press in Select_Background_Area.
function Select_Background_Area_Callback(hObject, eventdata, handles)
% hObject    handle to Select_Background_Area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Background_Area = getrect(handles.axes1);
handles = update_axis1(handles)

set(handles.Select_Background_Area,'BackgroundColor',[0 1 0]);

guidata(hObject, handles);
