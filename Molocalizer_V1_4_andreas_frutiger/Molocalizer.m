function varargout = Molocalizer(varargin)

% Copyright (c) 2015, Andreas Frutiger
% All rights reserved.

% MOLOCALIZER MATLAB code for Molocalizer.fig
%      MOLOCALIZER, by itself, creates a new MOLOCALIZER or raises the existing
%      singleton*.
%ptionsMOLOCALIZER or the handle to
%      the existing singleton*.
%
%      MOLOCALIZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOLOCALIZER.M with the given input arguments.
%
%      MOLOCALIZER('Property','Value',...) creates a new MOLOCALIZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Molocalizer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Molocalizer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Molocalizer

% Last Modified by GUIDE v2.5 17-Jan-2016 10:34:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Molocalizer_OpeningFcn, ...
                   'gui_OutputFcn',  @Molocalizer_OutputFcn, ...
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

% --- Executes just before Molocalizer is made visible.
function Molocalizer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Molocalizer (see VARARGIN)

% Choose default command line output for Molocalizer
handles.output = hObject;
addpath(genpath(pwd));

% cell array that stores the content of the Console

handles = initialize_handles_structure(handles);

if  isappdata(0,'confirmedMoloSpots')
    
    set(handles.molo_loc_confirmed,'BackgroundColor',[0 1 0]);
    handles.confirmedMoloSpots = getappdata(0,'confirmedMoloSpots');
    handles.number_of_mololines = getappdata(0,'number_of_mololines');
    rmappdata(0,'confirmedMoloSpots');
    rmappdata(0,'number_of_mololines');

else
    set(handles.molo_loc_confirmed,'BackgroundColor',[1 0 0]);
end



% Update handles structure
guidata(hObject, handles);

function handles = initialize_handles_structure(handles)

    handles.Consolecontent = {};
    % stores which standard algorithm processes the data.
    handles.algorithm = 'iter_sig_area_inc_3std';
  
    
    % these variables store the processed data of the different
    % algorithms, they are equal to handles.molo!!! and have all the
    % fields!
    handles.molo_algo_data.std_5_times = struct();
    handles.molo_algo_data.iter_sig_area_inc_3std = struct();
    handles.molo_algo_data.maximum_vs_background = struct();
    
    handles.dynamic_plotting = false;
    handles.molo = struct;
    handles.time = [];
    handles.Injection_times = []; % vector that stores the injection time values.
    
    handles.Processed_image_button_clicked = false;
    
    handles.axes_data_display =  'raw_data';
    set(handles.Stop_dynamic_plotting,'UserData',false);
    
    set(handles.molo_loc_confirmed,'BackgroundColor',[1 0 0]);
    
    switch handles.algorithm
          
          case 'std_5_times'
                
              set(handles.Algorithm_select,'Value',1);
                
          case 'iter_sig_area_inc_3std'
              
            set(handles.Algorithm_select,'Value',2);
              
          case 'maximum_vs_background'
              
            set(handles.Algorithm_select,'Value',3);

     end
    
    
    
    
    
    
    
   


% --- Outputs from this function are returned to the command line.
function varargout = Molocalizer_OutputFcn(hObject, eventdata, handles) 
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

% UIWAIT makes Molocalizer wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% get the path where the images are and also all the images in this
% directory


% clear the handles structure from all elements that are non-UI elements.
names = fieldnames(handles);    
for i=1:length(names)

    name = names{i};

    if (isa(getfield(handles,name),'matlab.ui.Figure') || isa(getfield(handles,name),'matlab.ui.container.Menu') || isa(getfield(handles,name),'matlab.ui.container.ContextMenu') ...    
        || isa(getfield(handles,name),'matlab.ui.container.Panel') || isa(getfield(handles,name),'matlab.graphics.axis.Axes') || isa(getfield(handles,name),'matlab.ui.control.UIControl'))
   
       
    else
        
        rmfield(handles,name);
        
    end
    
end

% save the last user location and load the path data
try 
    load('last_path.mat')
    expr = '\w*\\\w*'
    hilf = regexp(last_path,expr)
    hilf = hilf(end)
    last_path = last_path(1:hilf-1)
    handles.path = uigetdir(last_path);
    last_path = handles.path
    save('last_path.mat','last_path');
catch
    handles.path = uigetdir(pwd);
    last_path = handles.path;
    save('last_path.mat','last_path');
end



addpath(handles.path)
addpath(genpath(handles.path));
splitted_path = strsplit(handles.path,'\');
handles.experiment_name = splitted_path{end};
set(handles.Loaded_Experiment,'String',strcat('Name: ',handles.experiment_name));

handles.filenames = dir([handles.path,'/Images/*.tif']);

% get the first tif file in the directory
handles.filenumbers = get_file_numbers(handles.filenames);
handles.current_image = imread(handles.filenames(end).name);

mkdir(strcat(handles.path,'/Evaluation'));
mkdir(strcat(handles.path,'/Evaluation/Cut_Images'));
mkdir(strcat(handles.path,'/Evaluation/mat_files'));
mkdir(strcat(handles.path,'/Evaluation/csv_files'));
mkdir(strcat(handles.path,'/Evaluation/Plots'));



% Here I need to call the other GUI

data_to_pass_to_other_GUI = struct;

data_to_pass_to_other_GUI.path = handles.path;
data_to_pass_to_other_GUI.filenames = handles.filenames;
data_to_pass_to_other_GUI.current_image = handles.current_image;
setappdata(0,'data_to_pass_to_other_GUI',data_to_pass_to_other_GUI);

molo_select_GUI();








guidata(hObject, handles);

%% ------ From here the mololocations are confirmed. 

% --- Executes on button press in Process_all_images.
function Process_all_images_Callback(hObject, eventdata, handles)
% hObject    handle to Process_all_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% check here whether the mololocations are confirmed or not... 

handles.filenames = dir([handles.path,'/Images/*.tif']);

% when images are being added matlab has to update the path structure -->
% makes execution very slow
if get(handles.Images_being_added,'Value')
    rehash; % very important otherwise the image is not found.
    addpath(genpath(handles.path));
end

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

handles = update_Datavisualization(handles);

% this is to tell the function Start_Dynamic_Plotting
% that this function here was executed. 
handles.Processed_image_button_clicked  = true;

guidata(hObject, handles);

% --- Executes on button press in Process_new_images.
function Process_new_images_Callback(hObject, eventdata, handles)
% hObject    handle to Process_new_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    old_filenames = handles.filenames; 
    handles.filenames = dir([handles.path,'/Images/*.tif']);
    % when images are being added matlab has to update the path structure -->
    % makes execution very slow
    if get(handles.Images_being_added,'Value')
        rehash; % very important otherwise the image is not found.
        addpath(genpath(handles.path));
    end

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

guidata(hObject, handles);


function handles = calculate_injection_times(handles)
% this function calculates the injection times, if the file Injection log
% exists, the injection times are stored in the the file Injection
% Log_processed

% Check if the injection time file exists:

if exist([handles.path '/Evaluation/Injection_log.txt'],'file')

    % read the values from the file
    
    a = importdata([handles.path '/Evaluation/Injection_log.txt'],';');

    handles.Injection_times = zeros(1,length(a));

    % calculate the injection time from handles.iniTime
    
    for i=1:length(a)

        hilf = strsplit(a{i},';');

        handles.Injection_times(i) = datenum(hilf(2),'dd-mmm-yyyy HH:MM:SS')*60*60*24;

    end

    handles.Injection_times = handles.Injection_times - handles.iniTime
    

    % save the calculated injection times to the file processed injection
    % times (in save_data)

    % update axes5 with lines marking the injection times
    
end





% --- Executes on button press in Start_Dynamic_Plotting.
function Start_Dynamic_Plotting_Callback(hObject, eventdata, handles)
% hObject    handle to Start_Dynamic_Plotting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the file list from the directory:
set(handles.Stop_dynamic_plotting,'UserData',true);

handles = update_Datavisualization(handles);

while get(handles.Stop_dynamic_plotting,'UserData')
    
    old_filenames = handles.filenames; 
    handles.filenames = dir([handles.path,'/Images/*.tif']);
    % when images are being added matlab has to update the path structure -->
    % makes execution very slow
    if get(handles.Images_being_added,'Value')
        rehash; % very important otherwise the image is not found.
        addpath(genpath(handles.path));
    end
    
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
        % the raspipi camera has a different field for the DateTime, it is
        % called: FileModDate, the format is also different: 'dd-mmm-yyyy HH:MM:SS'
        handles.iniTime = datenum(hilf2.DateTime,'dd.mmm.yyyy HH:MM:SS')*60*60*24;

        
    end
    
    % check whether there is a new file in the folder, otherwise do not do
     
    % this needs to loop through all new filenames and only append,
    % then everything should be fine.
    if not(get(handles.Stop_dynamic_plotting,'UserData'))
        
        h = waitbar(0,'Images are processed...');
        
    end
    
    steps = Endfileindex-Startfileindex;
    
    for i = Startfileindex:Endfileindex


            hilf = handles.filenames(i).name;
            
            
            % when images are being added matlab has to update the path structure -->
            % makes execution very slow
            if get(handles.Images_being_added,'Value')
                rehash; % very important otherwise the image is not found.
                addpath(genpath(handles.path));
            end
            
            handles.current_image = imread(strcat('/Images/',hilf));
            hilf2 = imfinfo(hilf);

            % this entire paragraph is for updating the file numbers

            first_split = strsplit(hilf,'_');
            hilf = (first_split{end});
            hilf = strsplit(hilf,'.');

            handles.cut_molocircles = cut_Molo_circles(handles.confirmedMoloSpots,handles.current_image);
            
            % the next two lines are only for 
            cut_molocircles = handles.cut_molocircles;
            % save(strcat(handles.path,'/Evaluation/Cut_Images/moloimages_',num2str(i),'.mat'),'cut_molocircles')
            
            
            options.Algorithm = handles.algorithm;
            
            if not(get(handles.Stop_dynamic_plotting,'UserData'))
            
                waitbar(i / steps);

            end
            [signals, backgrounds] = process_molocircles(handles.cut_molocircles,options);
        


            % this is dangerous, two different indices mechanisms...
            for j = 1:size(signals,1)

                for k = 1:size(signals,2)
                    
                    % these structures are not initialized yet...
                    handles.molo(j,k).signal(i) = signals(j,k);
                    handles.molo(j,k).background(i) = backgrounds(j,k);
                    
                end
            end

            handles.filenumbers(i) = str2num(hilf{1});
            handles.time(i) = datenum(hilf2.DateTime,'dd.mmm.yyyy HH:MM:SS')*60*60*24 - handles.iniTime;
        


    end
    
    % if the normalization was already performed for another algorithm then update also the
    % normalized signals. 
    if isfield(handles,'chemical_integrities_loaded')
       
       
        
       if isfield(handles.molo_algo_data.(handles.algorithm)(1,1),'molo_offset')
           
            for j = 1:size(handles.molo_algo_data.(handles.algorithm),1)

                 for k = 1:size(handles.molo_algo_data.(handles.algorithm),2)

                    handles.molo(j,k).molo_offset = handles.molo_algo_data.(handles.algorithm)(j,k).molo_offset
                    handles.molo(j,k).chemical_integrities = handles.molo_algo_data.(handles.algorithm)(j,k).chemical_integrities
                    
                 end

            end
            
           
           handles.Norm_Conc
           
           handles.molo = calc_sqrt_signals(handles.molo);
           handles.molo = calc_normalized_signal_dim_less(handles.molo);
           handles.molo = calc_normalized_signal(handles.molo,handles.Norm_Conc);
           
       end
       
    end
    
    
    
    if isfield(handles,'Norm_Lower_ind_confirmed')
        
        handles.molo = calc_offset(handles.Norm_Lower_ind_confirmed,handles.molo);
        handles.molo = calc_sqrt_signals(handles.molo);
        handles.molo = calc_chemical_integrities(handles.Norm_Upper_ind_confirmed,handles.molo);
        handles.molo = calc_normalized_signal_dim_less(handles.molo);
        handles.molo = calc_normalized_signal(handles.molo,handles.Norm_Conc);
    end
    
    % here I have to check whether the chemical integrities have been
    % loaded for this algorithm.
    
    

    if not(get(handles.Stop_dynamic_plotting,'UserData'))
        close(h)
    end
    
    
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

for j = 1:handles.number_of_mololines
    
    for i =1:size(handles.molo,2)
        
        % only draw the molographic lines that are selected by the
        % checkbox.
        if not(get(handles.Molo_line1,'Value')) && j ==1
           
            continue;
            
        end
        
        if not(get(handles.Molo_line3,'Value')) && j ==2
           
            continue;
            
        end
        
        if not(get(handles.Molo_line4,'Value')) && j ==3
           
            continue;
            
        end
        

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

limits = ylim;
if isfield(handles,'Norm_Lower_pos')
    
    % if the user has selected the lower normalization area, then visualize
    % it with a blue box of transparency 50.
 
    patch([handles.Norm_Lower_pos(1) handles.Norm_Lower_pos(1) handles.Norm_Lower_pos(2) handles.Norm_Lower_pos(2)],[limits(1) limits(2) limits(2) limits(1)],'blue','FaceAlpha',.3,'EdgeColor','None')
    

end

if isfield(handles,'Norm_Upper_pos')
    
    % if the user has selected the lower normalization area, then visualize
    % it with a blue box of transparency 50.
    patch([handles.Norm_Upper_pos(1) handles.Norm_Upper_pos(1) handles.Norm_Upper_pos(2) handles.Norm_Upper_pos(2)],[limits(1) limits(2) limits(2) limits(1)],'blue','FaceAlpha',.3,'EdgeColor','None')
    

end



% draw the injection time points as vertical lines

if length(handles.Injection_times) > 0
   
    for i = 1:length(handles.Injection_times)
        
        patch([handles.Injection_times(i) handles.Injection_times(i) handles.Injection_times(i) handles.Injection_times(i)],[limits(1) limits(2) limits(2) limits(1)],'blue','EdgeColor','blue')
    
        
    end 
    
end

hold off


function handles = update_Datavisualization(handles)
% this function updates the Data Visualization Panel.

handles = calculate_injection_times(handles);
handles = update_Axes_Molosignals(handles);


set(handles.current_time_display,'String',strcat('Time [s]:  ', num2str(handles.current_time)));
set(handles.Image_number_display,'String',strcat('Image number:  ',num2str(round(get(handles.scan_through_data,'Value')))));
set(handles.Loaded_Experiment,'String',strcat('Name:  ',handles.experiment_name));

axes(handles.axes4)

imagesc(handles.current_image);



if strcmp(get(handles.Show_selected_Molograms,'Checked'),'on')
    
    hold on;
    for i = 1:handles.number_of_mololines
        
        for j = 1:length(handles.confirmedMoloSpots(i).x_coord)
    
    
            viscircles([handles.confirmedMoloSpots(i).x_coord(j) handles.confirmedMoloSpots(i).y_coord(j)], 10,'EdgeColor','w','LineWidth',1,'DrawBackgroundCircle',false);
            
        end
        
    end
    hold off;
    
end

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
    
   set(handles.Start_Dynamic_Plotting,'BackgroundColor',[0 1 0]) 

else
    
    set(handles.Start_Dynamic_Plotting,'BackgroundColor',[0.94 0.94 0.94]) 
end

% update the algorithm listbox

switch handles.algorithm
          
          case 'std_5_times'
                
              set(handles.Algorithm_select,'Value',1);
                
          case 'iter_sig_area_inc_3std'
              
            set(handles.Algorithm_select,'Value',2);
              
          case 'maximum_vs_background'
              
            set(handles.Algorithm_select,'Value',3);

 end

% update the data display listbox



      switch handles.axes_data_display
          
          case 'raw_data'
              
            set(handles.Axes_Control,'Value',1);
              
          case 'sqrt_signal'
              
            set(handles.Axes_Control,'Value',2);
            
          case 'norm_signal'
            
            set(handles.Axes_Control,'Value',3);
              
      end
      
% update the molo locations confirmed panel.

if  isfield(handles,'confirmedMoloSpots')
    
   set(handles.molo_loc_confirmed,'BackgroundColor',[0 1 0]);
else
   set(handles.molo_loc_confirmed,'BackgroundColor',[1 0 0]);
end

% update the molo storage variables for the different algorithms.

    % This stores the data of the different algorithms in different
    % variables.
    

    switch handles.algorithm
          
          case 'std_5_times'
                
              handles.molo_algo_data.std_5_times = handles.molo;
                
          case 'iter_sig_area_inc_3std'
              
              handles.molo_algo_data.iter_sig_area_inc_3std = handles.molo;
              
          case 'maximum_vs_background'
              
              handles.molo_algo_data.maximum_vs_background = handles.molo;

    end




function Log_input_Callback(hObject, eventdata, handles)
% hObject    handle to Log_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


hilf1 = imfinfo(handles.filenames(1).name);

handles.iniTime = datenum(hilf1.DateTime,'dd.mmm.yyyy HH:MM:SS')*60*60*24;

% get the filename of the current image 
hilf2 = imfinfo(handles.filenames(round(get(handles.scan_through_data,'Value'))).name);

           
% I need to sort the console content...

handles.Consolecontent = [strcat(get(hObject,'String'),' , ',num2str(datenum(hilf2.DateTime)),', Time [s]: ', num2str(datenum(hilf2.DateTime,'dd.mmm.yyyy HH:MM:SS')*60*60*24 - handles.iniTime)) handles.Consolecontent ];

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


save_datalog(handles);







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

axes(handles.axes5);
hold on

line_pos = handles.time(round(get(hObject,'Value')));
line([line_pos line_pos],ylim);

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
   
    handles = rmfield(handles,'Norm_Upper_pos');
    
end

if isfield(handles,'Norm_Lower_pos')
   
    handles = rmfield(handles,'Norm_Lower_pos');
    
end

if isfield(handles,'Norm_Lower_ind_confirmed')
   
    handles = rmfield(handles,'Norm_Lower_ind_confirmed');
    
end

if isfield(handles,'Norm_Upper_ind_confirmed')
   
    handles = rmfield(handles,'Norm_Upper_ind_confirmed');
    
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
handles.Norm_Conc = str2num(get(handles.mu_molar_strept_ref,'String'));

handles.molo = calc_offset(handles.Norm_Lower_ind_confirmed,handles.molo);
handles.molo = calc_sqrt_signals(handles.molo);
handles.molo = calc_chemical_integrities(handles.Norm_Upper_ind_confirmed,handles.molo);
handles.molo = calc_normalized_signal_dim_less(handles.molo);
handles.molo = calc_normalized_signal(handles.molo,handles.Norm_Conc);



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

      handles.molo = struct;
          

      switch select_value
          
          case 1

           handles.molo = handles.molo_algo_data.std_5_times
           handles.algorithm =  'std_5_times';
              
          case 2
            
            handles.molo = handles.molo_algo_data.iter_sig_area_inc_3std
            handles.algorithm = 'iter_sig_area_inc_3std';
         
            
          case 3
            
            handles.molo = handles.molo_algo_data.maximum_vs_background
            handles.molo
            handles.algorithm = 'maximum_vs_background';
     
            

      end

      try
        handles = update_Datavisualization(handles);
      catch
          
        % msgbox('Please process the data with this algorithm first.') 
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

% Here I only save the actual data and not the graphical user interface
% variables. 
    set(handles.Save_all_data,'BackgroundColor',[1 1 0]);
    names = fieldnames(handles);
    
    data_to_export = struct;
    
    
    for i=1:length(names)
       
        name = names{i};
        
        
        if (isa(getfield(handles,name),'matlab.ui.Figure') || isa(getfield(handles,name),'matlab.ui.container.Menu') || isa(getfield(handles,name),'matlab.ui.container.ContextMenu') ...    
            || isa(getfield(handles,name),'matlab.ui.container.Panel') || isa(getfield(handles,name),'matlab.graphics.axis.Axes') || isa(getfield(handles,name),'matlab.ui.control.UIControl'))
            
            getfield(handles,name);
        
        else
            
            data_to_export.(name) = handles.(name);
            
        end
        
        
    end
    
save(strcat(handles.path,'/Evaluation/Experimental_data_for_reload_of_experiment.mat'),'data_to_export');
    
algorithms = fieldnames(handles.molo_algo_data);


styles = 'rgb';
% iterate through the all the processing algorithms, if there is no data
% for an algorithm nothing is exported.


for i = 1:length(algorithms)
    
    % check whether the algorithm has been processed, I only check whether
    % the signal is here 
    if isfield(handles.molo_algo_data.(algorithms{i})(1,1),'signal')
        
        
   
        
        export_signals(handles,algorithms{i});
        export_background_signals(handles,algorithms{i});
        
        % the following fields are only exported if the normalization has been
        % performed, otherwise they are not there.

        if isfield(handles,'Norm_Lower_ind_confirmed') || isfield(handles,'chemical_integrities_loaded')

            export_norm_signals(handles,algorithms{i});
            export_sqrt_signals(handles,algorithms{i});
            export_chemical_integrities(handles,algorithms{i});
         
        end
        
    end
    
    
    
end

% save the chemical integrities to the folder


save_datalog(handles);

save_processed_log_in(handles); % saves the processed injection log
 
set(handles.Save_all_data,'BackgroundColor',[0 1 0]);
 
 
 
% save the entire experiment here.






% --- Executes on mouse press over axes background.
function axes5_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see
% GUIDATA)
dcm_obj = datacursormode;
set(dcm_obj,'DisplayStyle','datatip',...
    'SnapToDataVertex','off','Enable','on')


% Wait while the user does this. Here must be a bug somewhere but to find
% it is difficult. 

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
viscircles([handles.confirmedMoloSpots(row).x_coord(coulumn) handles.confirmedMoloSpots(row).y_coord(coulumn)], 15,'EdgeColor','g','LineWidth',3,'DrawBackgroundCircle',false);

hold off;


%% Load


% --------------------------------------------------------------------

function Load_Experiment_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Experiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% this should load a file called load experiment, which contains the entire
% handles structure. 

        hilf_path = uigetdir(pwd);
        addpath(hilf_path);
        
        load(strcat(hilf_path,'/Evaluation/Experimental_data_for_reload_of_experiment.mat'));
        
       
        
        names = fieldnames(data_to_export)
   
    
    
        for i=1:length(names)

            name = names{i};

                handles.(name) = data_to_export.(name);

        end
        
        iniTime = handles.iniTime
        
        handles.path = hilf_path; % because the path was reloaded from the mat file
        
        set(handles.scan_through_data,'Min',1);
        set(handles.scan_through_data,'Max',length(handles.filenames));
        set(handles.scan_through_data,'Value',length(handles.filenames));
        sliderStep = [1, 1] / (length(handles.filenames)-1)
        set(handles.scan_through_data, 'SliderStep',sliderStep);
        handles = update_Datavisualization(handles);

guidata(hObject,handles)






function Window_control_Callback(hObject, eventdata, handles)
% hObject    handle to Process_Toolbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function Show_selected_Molograms_Callback(hObject, eventdata, handles)
% hObject    handle to Show_selected_Molograms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject,'Checked'),'on')

    set(hObject,'Checked','Off');

else
    set(hObject,'Checked','on');
end

handles = update_Datavisualization(handles);

guidata(hObject,handles)
   


% --------------------------------------------------------------------
function Quit_Application_Callback(hObject, eventdata, handles)
% hObject    handle to Quit_Application (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear all;
close all;
clc;

function Images_being_added_Callback(hObject, eventdata, handles)
% hObject    handle to Process_Toolbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Zoom_button.
function Zoom_button_Callback(hObject, eventdata, handles)
% hObject    handle to Zoom_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'zoom')
    
    if handles.zoom
        
        handles.zoom = false;
        zoom off
        set(handles.Zoom_button,'BackgroundColor',[0.94 0.94 0.94]);
    else
        
        handles.zoom = true;
        zoom on
        set(handles.Zoom_button,'BackgroundColor',[0 1 0]);
        
    end
    
    
else
    handles.zoom = true;
    zoom on
    set(handles.Zoom_button,'BackgroundColor',[0 1 0]);
    
end
    
    

guidata(hObject,handles)
    


% --------------------------------------------------------------------
function custom_axis_limits_Callback(hObject, eventdata, handles)
% hObject    handle to custom_axis_limits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject,'Checked'),'on')

    set(hObject,'Checked','Off');
    xlim(handles.axes5,'auto')
else
    
    set(hObject,'Checked','on');
    prompt = {'Enter x limits:'};
    dlg_title = 'Limit of data axis';
    num_lines = 1;
    defaultans = {'0,2000'};
    limits = inputdlg(prompt,dlg_title,num_lines,defaultans);
    limits = str2double(strsplit(limits{1},','))
    xlim(handles.axes5,[limits(1) limits(2)])

end


handles = update_Datavisualization(handles);

guidata(hObject,handles)


% --------------------------------------------------------------------
function Load_chem_integrities_Callback(hObject, eventdata, handles)
% hObject    handle to Load_chem_integrities (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% load the chemical integrities of all algorithms, the molo_offsets of all
% algorithms as well as the Confirmed_Molospots() --> no that is not good. 

msgbox('Is the current coupling the same as the one used for acquiring the chemical integrities? If not your results will most likely be wrong!!!')

load(strcat(handles.path,'/../Normalization_data/algorithms.mat'));

for i = 1:length(algorithms)
    
    if algorithms_processed(i)
    
        load(strcat(handles.path,'/../Normalization_data/', algorithms{i}, '_chemical_integrities.mat'));
        load(strcat(handles.path,'/../Normalization_data/', algorithms{i}, '_molo_offset.mat'));

        for j = 1:size(chemical_integrity_matrix,1)

             for k = 1:size(chemical_integrity_matrix,2)

                handles.molo_algo_data.(algorithms{i})(j,k).chemical_integrities = chemical_integrity_matrix(j,k);
                handles.molo_algo_data.(algorithms{i})(j,k).molo_offset =  molo_offset_matrix(j,k);

             end

        end
        
    end
 
end

load(strcat(handles.path,'/../Normalization_data/Norm_conc.mat'));
handles.Norm_Conc = Norm_Conc;

handles.chemical_integrities_loaded = true;
set(handles.chem_int,'BackgroundColor',[0 1 0])

guidata(hObject,handles)


% --- Executes on button press in Exp_chem_integrities.
function Exp_chem_integrities_Callback(hObject, eventdata, handles)
% hObject    handle to Exp_chem_integrities (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mkdir(strcat(handles.path,'/../Normalization_data'));

algorithms = fieldnames(handles.molo_algo_data);



for i = 1:length(algorithms)
    
    % check whether the algorithm has been processed, I only check whether
    % the signal is here 
    if isfield(handles.molo_algo_data.(algorithms{i})(1,1),'signal')

        % the following fields are only exported if the normalization has been
        % performed, otherwise they are not there.

        if isfield(handles,'Norm_Lower_ind_confirmed')
            
            algorithms_processed(i) = true;
            
            chemical_integrity_matrix = zeros(size(handles.molo_algo_data.(algorithms{i})));
            molo_offset_matrix = zeros(size(handles.molo_algo_data.(algorithms{i})));
    
    
            for j = 1:size(handles.molo_algo_data.(algorithms{i}),1)

                 for k = 1:size(handles.molo_algo_data.(algorithms{i}),2)

                    chemical_integrity_matrix(j,k) = handles.molo_algo_data.(algorithms{i})(j,k).chemical_integrities;
                    molo_offset_matrix(j,k) = handles.molo_algo_data.(algorithms{i})(j,k).molo_offset;
                 end

            end
            
            save(strcat(handles.path,'/../Normalization_data/', algorithms{i}, '_chemical_integrities.mat'),'chemical_integrity_matrix');
            save(strcat(handles.path,'/../Normalization_data/', algorithms{i}, '_molo_offset.mat'),'molo_offset_matrix');

        else
           
            algorithms_processed(i) = false;
            
        end
        
    else
       
        algorithms_processed(i) = false;
        
    end
    
    
    
end

save(strcat(handles.path,'/../Normalization_data/algorithms.mat'),'algorithms','algorithms_processed');

Norm_Conc = handles.Norm_Conc;

save(strcat(handles.path,'/../Normalization_data/Norm_conc.mat'),'Norm_Conc');


% --------------------------------------------------------------------
function Logging_Callback(hObject, eventdata, handles)
% hObject    handle to Logging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Start_Injection_logging_Callback(hObject, eventdata, handles)
% hObject    handle to Start_Injection_logging (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This function calls the injection logging script in order to log the data
% from the autosampler.

% run an external matlab script in an external matlab session in the background
a = sprintf('matlab  -r -nosplash -nodesktop "addpath(genpath(pwd));log_injection(''%s'')" &',handles.path);

unix(a)





