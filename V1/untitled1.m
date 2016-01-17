function varargout = untitled1(varargin)
% UNTITLED1 MATLAB code for untitled1.fig
%      UNTITLED1, by itself, creates a new UNTITLED1 or raises the existing
%      singleton*.
%
%      H = UNTITLED1 returns the handle to a new UNTITLED1 or the handle to
%      the existing singleton*.
%
%      UNTITLED1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED1.M with the given input arguments.
%
%      UNTITLED1('Property','Value',...) creates a new UNTITLED1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled1

% Last Modified by GUIDE v2.5 08-Oct-2015 20:16:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled1_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled1_OutputFcn, ...
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

% The main data structure of the GUI is the struct handles, it contains the
% following fields:
% - points_to_add: type: cell array;  cell array that stores all the points that
% have to be added to the molovector.

% - points_to_delete: type: cell array;  cell array that stores all the points that
% have to be deleted from the molovector.

% - moloVector: type: cell array ; contains all the points that were
% identified as the center spots of the molograms.

% - path: type: string ; contains the path to the image folder.
% - filenames().name: type: string ; is a vector containing all the tif file names
% 

% - time: type: vector double ; stores the time information of the measurements

% - centroids: type: (n,2) vector of doubles;  contains the location of the
% molographic spot locations.
% - radius:

% - pixelsize: pixelsize of the image (default is 12.5, is overwritten by
% the textbox

% - Moloarea: rectangle specifying the positions of the mologram. 







% --- Executes just before untitled1 is made visible.
function untitled1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled1 (see VARARGIN)

% Choose default command line output for untitled1
handles.output = hObject;
addpath(genpath(pwd));

% cell array that stores the content of the Console
handles.Consolecontent = {};



% Update handles structure
guidata(hObject, handles);





% --- Outputs from this function are returned to the command line.
function varargout = untitled1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Update_text.
function Update_text_Callback(hObject, eventdata, handles)
% hObject    handle to Update_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set(handles.text2,'String',get(handles.edit1,'String'))
set(handles.text2,'String',handles.filename)



% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --------------------------------------------------------------------
function Start_Experiment_Callback(hObject, eventdata, handles)
% hObject    handle to Start_Experiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% UIWAIT makes untitled1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% initalize variables that will be needed later on

% initialize the array, points to delete
handles.points_to_delete = {}
handles.points_to_add = {}
handles.moloVector = {}
handles.MoloLocationsConfirmedbool = false;

handles.dynamic_plotting = false;
handles.Processed_image_button_clicked = false;

handles.current_data_set = 1; % up to which dataset the data should be displayed in the Data visualization window. 
handles.molo = struct;
handles.time = [];

% tmpo =imfinfo(files(countfv).name); 
% files(countfv).datetime = tmpo.DateTime; %auslesen Aufnahme Zeitpkt. DateTime: '11.03.2015 13:35:16'

% handles.confirmedMoloSpots is a structured array with the three
% molographic lines clustered. 


% get the path where the images are and also all the images in this
% directory

handles.path = uigetdir(pwd);
addpath(handles.path);

handles.filenames = dir([handles.path,'/Images/*.tif']);


% get the first tif file in the directory
handles.filenumbers = get_file_numbers(handles.filenames);


axes(handles.axes1)

% per default display the last image
handles.current_image = imread(handles.filenames(end).name);

% set the image slider to the start values


set(handles.image_selector,'Min',1);
set(handles.image_selector,'Max',length(handles.filenames));
set(handles.image_selector,'Value',length(handles.filenames));
sliderStep = [1, 1] / (length(handles.filenames)-1)
set(handles.image_selector, 'SliderStep',sliderStep);
imagesc(handles.current_image);


[handles.image_above_threshold,handles.centroids] = getMoloSpots(handles.current_image,handles.Threshold_Slider);
handles.moloVector = generateMoloVector(handles.centroids,handles.points_to_add,handles.points_to_delete,handles.radius,handles.current_image,handles);
plotSelection(handles);

set(handles.MoloLocationsConfirmed,'BackgroundColor',[1 0 0]);

% create a folder evaluation if not exist

mkdir(strcat(handles.path,'/Evaluation'))



guidata(hObject, handles);


% --- Executes on slider movement.
% this is the tolerance slider

function Threshold_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
[handles.image_above_threshold,handles.centroids] = getMoloSpots(handles.current_image,handles.Threshold_Slider);
handles.moloVector = generateMoloVector(handles.centroids,handles.points_to_add,handles.points_to_delete,handles.radius,handles.current_image,handles);
plotSelection(handles);

set(handles.MoloLocationsConfirmed,'BackgroundColor',[1 0 0]);


guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Threshold_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Min',1);
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

[handles.image_above_threshold,handles.centroids] = getMoloSpots(handles.current_image,handles.Threshold_Slider);
handles.moloVector = generateMoloVector(handles.centroids,handles.points_to_add,handles.points_to_delete,handles.radius,handles.current_image,handles);
plotSelection(handles);

set(handles.MoloLocationsConfirmed,'BackgroundColor',[1 0 0]);


guidata(hObject, handles);


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

for i = 1:length(handles.points_to_delete)
    
    if handles.radius > (handles.points_to_delete{i}(1,1) - point(1,1))^2 + (handles.points_to_delete{i}(1,2) - point(1,2))^2
            
            handles.points_to_delete(i) = []
            break;
            
    end
    
end
    
    

handles.points_to_add{end+1} = point;

handles.moloVector = generateMoloVector(handles.centroids,handles.points_to_add,handles.points_to_delete,handles.radius,handles.current_image,handles);
plotSelection(handles);


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
            
            handles.points_to_add(i)= []
            break;
            
    end
    
end
    
    

handles.points_to_delete{end+1} = point;

handles.moloVector = generateMoloVector(handles.centroids,handles.points_to_add,handles.points_to_delete,handles.radius,handles.current_image,handles);
plotSelection(handles);

guidata(hObject, handles);


function Pixelsize_Callback(hObject, eventdata, handles)
% hObject    handle to Pixelsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pixelsize = str2double(get(hObject,'String'));
handles.radius = handles.radius_um/handles.pixelsize;

% Hints: get(hObject,'String') returns contents of Pixelsize as text
%        str2double(get(hObject,'String')) returns contents of Pixelsize as a double

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

%% ------ From here the mololocations are confirmed. 

% --- Executes on button press in Confirm_Molo_Selection.
% to confirm the moloselection

function Confirm_Molo_Selection_Callback(hObject, eventdata, handles)
% hObject    handle to Confirm_Molo_Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% this function will also Group the lines

x_coord = cell2mat(handles.moloVector);
x_coord = x_coord(1:2:end-1);
y_coord = cell2mat(handles.moloVector);
y_coord = y_coord(2:2:end);

% do the clustering of the data into three rows.
clustered_data = kmeans(y_coord',3);

% commented stuff is to test, whether the lines are detected correctly 
% styles = 'rgb'
% figure1 = figure()
% hold on;
% here the three mololines are gathered. 
for i = 1:3 
    handles.confirmedMoloSpots(i).x_coord = x_coord(clustered_data == i);
    handles.confirmedMoloSpots(i).y_coord = y_coord(clustered_data == i);
    % plot(x_coord(clustered_data == i),y_coord(clustered_data == i),'Color',styles(i))
end

   set(handles.MoloLocationsConfirmed,'BackgroundColor',[0 1 0]);

guidata(hObject, handles);


% --- Executes on button press in Process_all_images.
function Process_all_images_Callback(hObject, eventdata, handles)
% hObject    handle to Process_all_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.filenames = dir([handles.path,'/Images/*.tif']);

% reset all variables
handles.filenumbers = [];
handles.molo = struct
handles.time = []



% I actually only have to change this loop for the dynamic plotting.

% this will be a function: update_molosignals. 
% maybe I have to change the variable filenumbers. 

old_filenames = 0;

handles = Process_images_hilf(old_filenames,handles);


% this part goes into the function update data visualization!!
       
axes(handles.axes5);

hold on

% this is for looping through the mololines (has to be more general....)
for j = 1:3
    
    for i =1:size(handles.molo,2)
        handles.molo(j,2).timepoint.signal;
        plot(handles.time,cell2mat({(handles.molo(j,i).timepoint(:).signal)}));
        
    end
    
end

hold off

% display the last image. 
axes(handles.axes4);
handles.current_image = imread(handles.filenames(end).name);
imagesc(handles.current_image);

handles.Processed_image_button_clicked  = true;

guidata(hObject, handles);


% --- Executes on button press in Process_images_and_start_dynamic_plotting.
function Process_images_and_start_dynamic_plotting_Callback(hObject, eventdata, handles)
% hObject    handle to Process_images_and_start_dynamic_plotting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the file list from the directory:
handles.dynamic_plotting = true;
while handles.dynamic_plotting
    old_filenames = handles.filenames;
    handles.filenames = dir([handles.path,'/Images/*.tif']);
    rehash;
    pause(10);

    if handles.Processed_image_button_clicked 
        handles = Process_images_hilf(old_filenames,handles);
        
    else
        handles = Process_images_hilf(1,handles);
    end
    
    axes(handles.axes5);

    hold on

    % this is for looping through the mololines (has to be more general....)
    
    size(handles.time)
    size(cell2mat({(handles.molo(2,2).timepoint(:).signal)}))
    
    for j = 1:3

        for i =1:size(handles.molo,2)
            handles.molo(j,2).timepoint.signal;
            plot(handles.time,cell2mat({(handles.molo(j,i).timepoint(:).signal)}));

        end

    end

hold off

% display the last image. 
axes(handles.axes4);
handles.current_image = imread(handles.filenames(end).name);
imagesc(handles.current_image);
   
    
end

guidata(hObject, handles);


function handles = Process_images_hilf(old_filenames,handles)
    
    hilf = handles.filenames(1).name;
    hilf2 = imfinfo(hilf);
    handles.iniTime = datenum(hilf2.DateTime);
    
    if length(handles.filenames) - length(old_filenames) > 0
    
        for i = length(old_filenames):length(handles.filenames)


                hilf = handles.filenames(i).name
                handles.current_image = imread(strcat('/Images/',hilf));
                hilf2 = imfinfo(hilf);


                if i == 1

                    continue;

                end

                handles.time(end + 1) = datenum(hilf2.DateTime) - handles.iniTime;
                first_split = strsplit(hilf,'_');
                hilf = (first_split{end});
                hilf = strsplit(hilf,'.');
                
                handles.filenumbers(end + 1) = str2num(hilf{1});
                handles.cut_molocircles = cut_Molo_circles(handles.confirmedMoloSpots,handles.current_image);
                options.Algorithm = 'histogram';

                [signals, backgrounds] = process_molocircles(handles.cut_molocircles,options);



                for j = 1:size(signals,1)

                    for k = 1:size(signals,2)

                        handles.molo(j,k).timepoint(i).signal = signals(j,k);
                        handles.molo(j,k).timepoint(i).background = backgrounds(j,k);

                    end

                end




        end
        
    end
    

    
    
    % --- Executes on button press in Stop_dynamic_plotting.
function Stop_dynamic_plotting_Callback(hObject, eventdata, handles)
% hObject    handle to Stop_dynamic_plotting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dynamic_plotting = false;

guidata(hObject, handles);


function Log_input_Callback(hObject, eventdata, handles)
% hObject    handle to Log_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



hilf2 = imfinfo(handles.filenames(end).name);
           


handles.Consolecontent = [strcat(get(hObject,'String'),' , ',num2str(datenum(hilf2.DateTime))) handles.Consolecontent ];

set(handles.Console_Output,'String',handles.Consolecontent);
% Hints: get(hObject,'String') returns contents of Log_input as text
%        str2double(get(hObject,'String')) returns contents of Log_input as a double

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Log_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Log_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --------------------------------------------------------------------
function SaveDatalog_Callback(hObject, eventdata, handles)
% hObject    handle to SaveDatalog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fid = fopen(strcat(handles.path,'/Evaluation/Experiment_log.txt'), 'a');

for i=1:length(handles.Consolecontent)

    fprintf(fid, '%s\n', handles.Consolecontent{i});

    
    
    
end

fclose(fid);




% --- Executes on selection change in Console_Output.
function Console_Output_Callback(hObject, eventdata, handles)
% hObject    handle to Console_Output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Console_Output contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Console_Output


% --- Executes during object creation, after setting all properties.
function Console_Output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Console_Output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Edit_Console_Entry_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_Console_Entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

index_selected = uint8(get(handles.Console_Output,'Value'))

hilf = get(handles.Console_Output,'String');


answer = inputdlg({'Change Log entry:'},'Input',1,hilf(index_selected));

hilf(index_selected) = answer;

handles.Consolecontent = hilf
set(handles.Console_Output,'Value',index_selected)
set(handles.Console_Output,'String',handles.Consolecontent)

guidata(hObject, handles);





% --------------------------------------------------------------------
function Delete_Console_entry_Callback(hObject, eventdata, handles)
% hObject    handle to Delete_Console_entry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

index_selected = uint8(get(handles.Console_Output,'Value'))

hilf = get(handles.Console_Output,'String');

hilf(index_selected) = [];
handles.Consolecontent = hilf'
set(handles.Console_Output,'Value',1)
set(handles.Console_Output,'String',handles.Consolecontent)

guidata(hObject, handles);


% --------------------------------------------------------------------
function Logging_context_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Logging_context_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Select_Molo_Area.
function Select_Molo_Area_Callback(hObject, eventdata, handles)
% hObject    handle to Select_Molo_Area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MoloArea = getrect(handles.axes1);

handles.moloVector = generateMoloVector(handles.centroids,handles.points_to_add,handles.points_to_delete,handles.radius,handles.current_image,handles);
plotSelection(handles);

guidata(hObject, handles);


% --- Executes on slider movement.
function scan_through_data_Callback(hObject, eventdata, handles)
% hObject    handle to scan_through_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function scan_through_data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scan_through_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Molo_Line_4.
function Molo_Line_4_Callback(hObject, eventdata, handles)
% hObject    handle to Molo_Line_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Molo_Line_4


% --- Executes on button press in Molo_Line_2.
function Molo_Line_2_Callback(hObject, eventdata, handles)
% hObject    handle to Molo_Line_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Molo_Line_2


% --- Executes on button press in Molo_line1.
function Molo_line1_Callback(hObject, eventdata, handles)
% hObject    handle to Molo_line1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Molo_line1


% --- Executes on button press in Define_Normalization_area.
function Define_Normalization_area_Callback(hObject, eventdata, handles)
% hObject    handle to Define_Normalization_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




