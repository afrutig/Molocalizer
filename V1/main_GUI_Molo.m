function varargout = main_GUI_Molo(varargin)
% MAIN_GUI_MOLO MATLAB code for main_GUI_Molo.fig
%      MAIN_GUI_MOLO, by itself, creates a new MAIN_GUI_MOLO or raises the existing
%      singleton*.
%
%      H = MAIN_GUI_MOLO returns the handle to a new MAIN_GUI_MOLO or the handle to
%      the existing singleton*.
%
%      MAIN_GUI_MOLO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_GUI_MOLO.M with the given input arguments.
%
%      MAIN_GUI_MOLO('Property','Value',...) creates a new MAIN_GUI_MOLO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_GUI_Molo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_GUI_Molo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main_GUI_Molo

% Last Modified by GUIDE v2.5 14-Oct-2015 18:20:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_GUI_Molo_OpeningFcn, ...
                   'gui_OutputFcn',  @main_GUI_Molo_OutputFcn, ...
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
% - Selected_Molospots: bool Matrix controls which molograms to be
%   displayed!

% --- Executes just before main_GUI_Molo is made visible.
function main_GUI_Molo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main_GUI_Molo (see VARARGIN)

% Choose default command line output for main_GUI_Molo
handles.output = hObject;
addpath(genpath(pwd));

% cell array that stores the content of the Console

handles = initialize_handles_structure(handles);




% Update handles structure
guidata(hObject, handles);

function handles = initialize_handles_structure(handles)

    handles.Consolecontent = {};
    % stores which standard algorithm processes the data.
    handles.algorithm = 'std_5_times';
  
    
    % these variables store the processed data of the different
    % algorithms
    handles.molo_algo_data.std_5_times = struct();
    handles.molo_algo_data.iter_sig_area_inc_3std = struct();
    handles.molo_algo_data.maximum_vs_background = struct();
    
    
    handles.axes_data_display =  'raw_data';
    set(handles.Stop_dynamic_plotting,'UserData',false);
    

   
    
    







% --- Outputs from this function are returned to the command line.
function varargout = main_GUI_Molo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

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

% UIWAIT makes main_GUI_Molo wait for user response (see UIRESUME)
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
mkdir(strcat(handles.path,'/Evaluation/Cut_Images'))



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
            
            handles.points_to_add(i)= [];
            
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


% do the clustering of the data into three rows.
clustered_data = kmeans(y_coord',3);

% commented stuff is to test, whether the lines are detected correctly 
% styles = 'rgb'
% figure1 = figure()
% hold on;
% here the three mololines are gathered.


y_means = zeros(1,3);
for i = 1:3 
    
    y_means(1,i) = mean(y_coord(clustered_data == i)) % sort the x coordinate ascending. 
   
    % plot(x_coord(clustered_data == i),y_coord(clustered_data == i),'Color',styles(i))
    
    
end

% sort them correctly
[ymeans index] = sort(y_means)


for i = 1:3 
    
    handles.confirmedMoloSpots(i).x_coord = sort(x_coord(clustered_data == index(i))); % sort the x coordinate ascending. 
    handles.confirmedMoloSpots(i).y_coord = y_coord(clustered_data == index(i));
    % plot(x_coord(clustered_data == i),y_coord(clustered_data == i),'Color',styles(i))
    
    
end


   confirmedMoloSpots = handles.confirmedMoloSpots;
   
   set(handles.MoloLocationsConfirmed,'BackgroundColor',[0 1 0]);
   
   % save the Molo

   save(strcat(handles.path,'/Evaluation/Confirmed_Molo_Spots_positions.mat'),'confirmedMoloSpots');
   handles.Selected_MoloSpots = true(3,length(handles.confirmedMoloSpots(1).x_coord))
   
guidata(hObject, handles);

% --- Executes on button press in Select_Molo_Area.
function Select_Molo_Area_Callback(hObject, eventdata, handles)
% hObject    handle to Select_Molo_Area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.MoloArea = getrect(handles.axes1);

handles.moloVector = generateMoloVector(handles.centroids,handles.points_to_add,handles.points_to_delete,handles.radius,handles.current_image,handles);
plotSelection(handles);

guidata(hObject, handles);



%% ------ From here the mololocations are confirmed. 

% --- Executes on button press in Process_all_images.
function Process_all_images_Callback(hObject, eventdata, handles)
% hObject    handle to Process_all_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.filenames = dir([handles.path,'/Images/*.tif']);

% reset all variables
handles.filenumbers = [];
handles.molo = struct;
handles.molo(1:size(handles.confirmedMoloSpots,1),1:size(handles.confirmedMoloSpots,2)) = struct();
handles.time = [];

% set the slider to correct min and max values corresponding to the number
% of files in the directory. 
set(handles.scan_through_data,'Min',1);
set(handles.scan_through_data,'Max',length(handles.filenames));
set(handles.scan_through_data,'Value',length(handles.filenames));
sliderStep = [1, 1] / (length(handles.filenames)-1)
set(handles.scan_through_data, 'SliderStep',sliderStep);

% I actually only have to change this loop for the dynamic plotting.

% this will be a function: update_molosignals. 
% maybe I have to change the variable filenumbers. 


handles = Process_images_hilf(1,length(handles.filenames),handles);

handles.current_image = imread(handles.filenames(end).name);
handles.current_time = handles.time(end);

% if the normalization was already performed with an another algorithm,
% then normalize this signal as well.
if isfield(handles,'Norm_Lower_ind_confirmed')
    
    handles.molo = calc_chemical_integrities_and_normalize_signal(handles.Norm_Lower_ind_confirmed,handles.Norm_Upper_ind_confirmed,handles.molo,handles.Norm_conc);
    
end


handles = update_Datavisualization(handles);

% this is to tell the function Process_images_and_start_dynamic_plotting
% that this function here was executed. 
handles.Processed_image_button_clicked  = true;

guidata(hObject, handles);

% --- Executes on button press in Process_images_and_start_dynamic_plotting.
function Process_images_and_start_dynamic_plotting_Callback(hObject, eventdata, handles)
% hObject    handle to Process_images_and_start_dynamic_plotting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the file list from the directory:
set(handles.Stop_dynamic_plotting,'UserData',true);
handles = update_Datavisualization(handles);

while get(handles.Stop_dynamic_plotting,'UserData')
    
    old_filenames = handles.filenames; 
    handles.filenames = dir([handles.path,'/Images/*.tif']);
    rehash; % very important otherwise the image is not found.
    
    pause(2);

    % check whether the image files were already processed
    
    if handles.Processed_image_button_clicked
        
        handles = Process_images_hilf(length(old_filenames) + 1,length(handles.filenames),handles);
        
    else
        handles.filenumbers = [];
        handles.molo = struct;
        handles.molo(1:size(handles.confirmedMoloSpots,1),1:size(handles.confirmedMoloSpots,2)) = struct();
        handles.time = [];
        handles = Process_images_hilf(1,length(handles.filenames),handles);
        
    end
        
    handles.current_image = imread(handles.filenames(end).name);
    handles.current_time = handles.time(end);
    
    handles = update_Datavisualization(handles);
   
    
end

guidata(hObject, handles);

function handles = Process_images_hilf(Startfileindex, Endfileindex, handles)
    % this function updates three variables
    % - filenumbers,
    % - time
    % - molo (information associated with the molograms. 
    
    % set the variable iniTime of the first image if it has not been set
    % yet.
    
    if not(isfield(handles,'iniTime'))
        
        hilf = handles.filenames(1).name;
        hilf2 = imfinfo(hilf);
        handles.iniTime = datenum(hilf2.DateTime)*60*60*24;
        
    end
    
    % check whether there is a new file in the folder, otherwise do not do
     
    % this needs to loop through all new filenames and only append,
    % then everything should be fine.
    
    h = waitbar(0,'Images are processed...');
    
    steps = Endfileindex-Startfileindex;
    
    for i = Startfileindex:Endfileindex


            hilf = handles.filenames(i).name;
            handles.current_image = imread(strcat('/Images/',hilf));
            hilf2 = imfinfo(hilf);

            % this entire paragraph is for updating the file numbers

            first_split = strsplit(hilf,'_');
            hilf = (first_split{end});
            hilf = strsplit(hilf,'.');

            handles.cut_molocircles = cut_Molo_circles(handles.confirmedMoloSpots,handles.current_image);
            
            % the next two lines are only for 
            cut_molocircles = handles.cut_molocircles;
            save(strcat(handles.path,'/Evaluation/Cut_Images/moloimages_',num2str(i),'.mat'),'cut_molocircles')
            
            
            options.Algorithm = handles.algorithm;
            waitbar(i / steps);
            [signals, backgrounds] = process_molocircles(handles.cut_molocircles,options);
        


            % this is dangerous, two different indices mechanisms...
            for j = 1:size(signals,1)

                for k = 1:size(signals,2)
                    
                    % these structures are not initialized yet...
                    handles.molo(j,k).signal(i) = signals(j,k);
                    handles.molo(j,k).background(i) = backgrounds(j,k);
%                     handles.molo(j,k).timepoint(i).signal = signals(j,k);
%                     handles.molo(j,k).timepoint(i).background = backgrounds(j,k);

                end
            end

            handles.filenumbers(i) = str2num(hilf{1});
            handles.time(i) = datenum(hilf2.DateTime)*60*60*24 - handles.iniTime;
        


    end
    close(h)

    
    
    % --- Executes on button press in Stop_dynamic_plotting.
function Stop_dynamic_plotting_Callback(hObject, eventdata, handles)
% hObject    handle to Stop_dynamic_plotting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.Stop_dynamic_plotting,'UserData',false);
handles = update_Datavisualization(handles);

guidata(hObject, handles);


function handles = update_Axes_Molosignals(handles)

% this function clears and updates axes5.

cla(handles.axes5);
axes(handles.axes5);

hold on

% this is for looping through the mololines (has to be more general....)


styles = 'rbg';

for j = 1:3
    
    for i =1:size(handles.molo,2)
        
        if not(get(handles.Molo_line1,'Value')) && j ==1
           
            continue;
            
        end
        
        if not(get(handles.Molo_line3,'Value')) && j ==2
           
            continue;
            
        end
        
        if not(get(handles.Molo_line4,'Value')) && j ==3
           
            continue;
            
        end
        
%         size(handles.time)
%         handles.time
%         size(real(cell2mat({(handles.molo(j,i).timepoint(:).signal)})))
%         real(cell2mat({(handles.molo(j,i).timepoint(:).signal)}))
        switch handles.axes_data_display
          
          case 'raw_data'
           
            
            plot(handles.time,real(handles.molo(j,i).signal),'Linewidth',1,'Color',styles(j),'UserData',[num2str(j) ',' num2str(i)]);
            xlabel('Time [s]');
            ylabel('MoloSignal a.u.');
              
          case 'sqrt_signal'
            
            plot(handles.time,real(handles.molo(j,i).sqrt_signal),'Linewidth',1,'Color',styles(j),'UserData',[num2str(j) ',' num2str(i)]);
            xlabel('Time [s]');
            ylabel('Sqrt(MoloSignal) a.u.');
            
          case 'norm_signal'
              
            plot(handles.time,real(handles.molo(j,i).norm_signal),'Linewidth',1,'Color',styles(j),'UserData',[num2str(j) ',' num2str(i)]);
            xlabel('Time [s]');
            ylabel('MoloSignal [uM Strept]');
        end
        

        
    end
    
end

if isfield(handles,'Norm_Lower_pos')
    
    % if the user has selected the lower normalization area, then visualize
    % it with a blue box of transparency 50.
    limits = ylim;
    patch([handles.Norm_Lower_pos(1) handles.Norm_Lower_pos(1) handles.Norm_Lower_pos(2) handles.Norm_Lower_pos(2)],[limits(1) limits(2) limits(2) limits(1)],'blue','FaceAlpha',.3,'EdgeColor','None')
    

end

if isfield(handles,'Norm_Upper_pos')
    
    % if the user has selected the lower normalization area, then visualize
    % it with a blue box of transparency 50.
    limits = ylim;
    patch([handles.Norm_Upper_pos(1) handles.Norm_Upper_pos(1) handles.Norm_Upper_pos(2) handles.Norm_Upper_pos(2)],[limits(1) limits(2) limits(2) limits(1)],'blue','FaceAlpha',.3,'EdgeColor','None')
    

end

hold off


function handles = update_Datavisualization(handles)

handles = update_Axes_Molosignals(handles);

set(handles.current_time_display,'String',strcat('Time [s]:  ', num2str(handles.current_time)));
set(handles.Image_number_display,'String',strcat('Image number:  ',num2str(round(get(handles.scan_through_data,'Value')))));

axes(handles.axes4)
imagesc(handles.current_image);

set(handles.scan_through_data,'Min',1);
set(handles.scan_through_data,'Max',length(handles.filenames));
sliderStep = [1, 1] / (length(handles.filenames)-1);
set(handles.scan_through_data, 'SliderStep',sliderStep);



if isfield(handles,'Norm_Lower_pos')
    
    set(handles.Norm_Lower,'BackgroundColor',[0 1 0]);
    
else
    
    set(handles.Norm_Lower,'BackgroundColor',[0.94 0.94 0.94]);
    
end



if isfield(handles,'Norm_Upper_pos')
    
    set(handles.Norm_Upper,'BackgroundColor',[0 1 0]);
    
else
    
    set(handles.Norm_Upper,'BackgroundColor',[0.94 0.94 0.94]);
end

if isfield(handles,'Norm_Lower_ind_confirmed')
    
    set(handles.Confirm_Norm_Selection,'BackgroundColor',[0 1 0]);
    set(handles.Norm_Lower,'BackgroundColor',[0.94 0.94 0.94]);
    set(handles.Norm_Upper,'BackgroundColor',[0.94 0.94 0.94]);

else
    
    set(handles.Confirm_Norm_Selection,'BackgroundColor',[0.94 0.94 0.94]);
    
end





if get(handles.Stop_dynamic_plotting,'UserData');
    
   set(handles.Process_images_and_start_dynamic_plotting,'BackgroundColor',[0 1 0]) 

else
    
    set(handles.Process_images_and_start_dynamic_plotting,'BackgroundColor',[0.94 0.94 0.94]) 
end










function Log_input_Callback(hObject, eventdata, handles)
% hObject    handle to Log_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


hilf1 = imfinfo(handles.filenames(1).name);
handels.iniTime = datenum(hilf1.DateTime)*60*60*24
hilf2 = imfinfo(handles.filenames(end).name);
           


handles.Consolecontent = [strcat(get(hObject,'String'),' , ',num2str(datenum(hilf2.DateTime)),', Time [s]: ', num2str(datenum(hilf2.DateTime)*60*60*24 - handles.iniTime)) handles.Consolecontent ];

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




% --- Executes on slider movement.
function scan_through_data_Callback(hObject, eventdata, handles)
% hObject    handle to scan_through_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

axes(handles.axes4)
get(hObject,'Value')
% per default display the last image


handles.current_image = imread(handles.filenames(round(get(hObject,'Value'))).name);
handles.current_time = handles.time(round(get(hObject,'Value')));

handles = update_Datavisualization(handles);

axes(handles.axes5)
hold on

line_pos = handles.time(round(get(hObject,'Value')))
line([line_pos line_pos],ylim)

hold off

guidata(hObject,handles)

% display the current image. 


% --- Executes during object creation, after setting all properties.
function scan_through_data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scan_through_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Molo_line4.
function Molo_line4_Callback(hObject, eventdata, handles)
% hObject    handle to Molo_line4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Molo_line4
handles = update_Datavisualization(handles);


% --- Executes on button press in Molo_line3.
function Molo_line3_Callback(hObject, eventdata, handles)
% hObject    handle to Molo_line3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = update_Datavisualization(handles);

% Hint: get(hObject,'Value') returns toggle state of Molo_line3


% --- Executes on button press in Molo_line1.
function Molo_line1_Callback(hObject, eventdata, handles)
% hObject    handle to Molo_line1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = update_Datavisualization(handles);
% Hint: get(hObject,'Value') returns toggle state of Molo_line1




% --------------------------------------------------------------------

function Load_Experiment_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Experiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        handles.path = uigetdir(pwd);
        addpath(handles.path);

        handles.filenames = dir([handles.path,'/Images/*.tif']);


        % get the first tif file in the directory
        handles.filenumbers = get_file_numbers(handles.filenames);
        handles.Selected_MoloSpots = true(3,length(confirmedMoloSpots(1).x_coord));
    try 
          
        
        handles.confirmedMoloSpots = confirmedMoloSpots;
        set(handles.MoloLocationsConfirmed,'BackgroundColor',[0 1 0]);
    catch
        msgbox('Import failed, please try again!')
    
    end


% --- Executes on button press in Norm_Lower.
function Norm_Lower_Callback(hObject, eventdata, handles)
% hObject    handle to Norm_Lower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[x,y] = ginput(2)

% to convert it to indices
handles.Norm_Lower_pos = round(x);

% im only interested in the x values...

% draw a rectangle with the selection

handles = update_Datavisualization(handles);

guidata(hObject,handles)



% --- Executes on button press in Norm_Upper.
function Norm_Upper_Callback(hObject, eventdata, handles)
% hObject    handle to Norm_Upper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[x,y] = ginput(2)

handles.Norm_Upper_pos = round(x);



handles = update_Datavisualization(handles);

guidata(hObject,handles)






function mu_molar_strept_ref_Callback(hObject, eventdata, handles)
% hObject    handle to mu_molar_strept_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mu_molar_strept_ref as text
%        str2double(get(hObject,'String')) returns contents of mu_molar_strept_ref as a double


% --- Executes during object creation, after setting all properties.
function mu_molar_strept_ref_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mu_molar_strept_ref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Cancel_Norm_Selection.
function Cancel_Norm_Selection_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel_Norm_Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'Norm_Upper_pos')
   
    handles = rmfield(handles,'Norm_Upper_pos')
    
end

if isfield(handles,'Norm_Lower_pos')
   
    handles = rmfield(handles,'Norm_Lower_pos')
    
end

if isfield(handles,'Norm_Lower_ind_confirmed')
   
    handles = rmfield(handles,'Norm_Lower_ind_confirmed')
    
end

if isfield(handles,'Norm_Upper_ind_confirmed')
   
    handles = rmfield(handles,'Norm_Upper_ind_confirmed')
    
end

handles = update_Datavisualization(handles);

guidata(hObject,handles)







% --- Executes on button press in Confirm_Norm_Selection.
function Confirm_Norm_Selection_Callback(hObject, eventdata, handles)
% hObject    handle to Confirm_Norm_Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



handles.Norm_Lower_ind_confirmed = find(handles.Norm_Lower_pos(1) <= handles.time & handles.time <= handles.Norm_Lower_pos(2));

handles.Norm_Upper_ind_confirmed = find(handles.Norm_Upper_pos(1) <= handles.time & handles.time <= handles.Norm_Upper_pos(2));
handles.Norm_conc = str2num(get(handles.mu_molar_strept_ref,'String'));

% add the field chemical_integrity to the molo struct!
handles.molo = calc_chemical_integrities_and_normalize_signal(handles.Norm_Lower_ind_confirmed,handles.Norm_Upper_ind_confirmed,handles.molo,handles.Norm_conc);

handles.axes_data_display = 'norm_signal';
set(handles.Axes_Control,'Value',3);
handles = update_Datavisualization(handles);

guidata(hObject,handles)


% --- Executes on selection change in Algorithm_select.
function Algorithm_select_Callback(hObject, eventdata, handles)
% hObject    handle to Algorithm_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 
      select_value = get(handles.Algorithm_select,'Value');
      
      
      % here I should implement the data structure for the handling of the data of the different algorithm.
          % these variables store the processed data of the different
    % algorithms
      
      switch handles.algorithm
          
          case 'std_5_times'
                
              handles.molo_algo_data.std_5_times = handles.molo;
                
          case 'iter_sig_area_inc_3std'
              
              handles.molo_algo_data.iter_sig_area_inc_3std = handles.molo;
              
          case 'maximum_vs_background'
              
              handles.molo_algo_data.maximum_vs_background = handles.molo;

      end
      
      handles.molo = struct;
          

      switch select_value
          
          case 1

            handles.molo = handles.molo_algo_data.std_5_times;
              
            handles.algorithm =  'std_5_times';
              
          case 2
            
            handles.molo = handles.molo_algo_data.iter_sig_area_inc_3std;
            
            handles.algorithm = 'iter_sig_area_inc_3std';
         
            
          case 3
            
            handles.molo = handles.molo_algo_data.maximum_vs_background;
            handles.algorithm = 'maximum_vs_background';
     
            

      end

      try
        handles = update_Datavisualization(handles);
      catch
        msgbox('Please process the data with this algorithm first.') 
      end
      
      
guidata(hObject,handles)
       
        
        
        
% Hints: contents = cellstr(get(hObject,'String')) returns Algorithm_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Algorithm_select


% --- Executes during object creation, after setting all properties.
function Algorithm_select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Algorithm_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Axes_Control.
function Axes_Control_Callback(hObject, eventdata, handles)
% hObject    handle to Axes_Control (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Axes_Control contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Axes_Control
select_value = get(handles.Axes_Control,'Value');

      switch select_value
          
          case 1
           
            handles.axes_data_display =  'raw_data';
              
          case 2
            
            handles.axes_data_display = 'sqrt_signal';
            
          case 3
              
            handles.axes_data_display = 'norm_signal';
      end
      
       handles = update_Datavisualization(handles);
      
      
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function Axes_Control_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Axes_Control (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Save_all_data.
function Save_all_data_Callback(hObject, eventdata, handles)
% hObject    handle to Save_all_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

save_data(handles)


function save_data(handles)
% this function saves all the data in the current GUI to the folder
% evaluation.


% --- Executes on mouse press over axes background.
function axes5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see
% GUIDATA)
dcm_obj = datacursormode;
set(dcm_obj,'DisplayStyle','datatip',...
    'SnapToDataVertex','off','Enable','on')


% Wait while the user does this.
waitforbuttonpress

c_info = getCursorInfo(dcm_obj);
% Make selected line wider
set(c_info.Target,'LineWidth',4)
datacursormode off;
hilf = strsplit(get(c_info.Target,'UserData'),',')

row = str2num(hilf{1})
class(row)
coulumn = str2num(hilf{2})
handles.confirmedMoloSpots(2).x_coord


% highlight the selected mologram
axes(handles.axes4);
hold on;
viscircles([handles.confirmedMoloSpots(row).x_coord(coulumn) handles.confirmedMoloSpots(row).y_coord(coulumn)], 10,'EdgeColor','g','LineWidth',1,'DrawBackgroundCircle',false);
hold off;
