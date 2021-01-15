%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jared Day 4/19/2107
%
% Sensors Lab 10- Temperature Controller
%
% This program will use a constructed closed-loop temperature controller
% (LM335)circuit to control a heater. The program will acquire temperature
% at 1 second intervales once the user selects the START button on the GUI.
% The temperature volates from the temp sensor wll then be converted into
% celcius and then compared upper and lower set point temperatures and also
% compared to see if the circuit is giving reasonable values. The latter is
% an instance of error handling, i.e. if the temperature is initially out
% of range it is likely that the circuit needs to be adjusted or fixed. 
%
% The heater will turn on if the temperature is below the user defined 
% threshold it will turn the heater on and similarly if the temperature is 
% above the user defined temperature threshold the heater will turn off. 
% The user will also define a Tset value that will be used in junction with
% the Tthresh defined value accordingly. The user will then defined by
% selection on a push botton sequence box the desired output channel used
% that will send a logical high to the heater to be turned on if the
% correct conditions occur.
%
% Also, the MATLAB code below will display the temperature
% values on a graph, and in a display box. Futhermore, the user will have
% the options to start and stop the program, select input channels, and
% write the data to excel. The code below will also use general and
% specfic error handling techniques and pop up with a message box if an
% error occurs. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





function varargout = Lab10Sensors(varargin)
% LAB10SENSORS MATLAB code for Lab10Sensors.fig
%      LAB10SENSORS, by itself, creates a new LAB10SENSORS or raises the existing
%      singleton*.
%
%      H = LAB10SENSORS returns the handle to a new LAB10SENSORS or the handle to
%      the existing singleton*.
%
%      LAB10SENSORS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LAB10SENSORS.M with the given input arguments.
%
%      LAB10SENSORS('Property','Value',...) creates a new LAB10SENSORS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Lab10Sensors_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Lab10Sensors_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Lab10Sensors

% Last Modified by GUIDE v2.5 25-Apr-2017 11:56:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Lab10Sensors_OpeningFcn, ...
                   'gui_OutputFcn',  @Lab10Sensors_OutputFcn, ...
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


% --- Executes just before Lab10Sensors is made visible.
function Lab10Sensors_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Lab10Sensors (see VARARGIN)

global s out Temp lh elh flag flag2

flag = 0;
flag2 = 0;

set(handles.inpnl,'SelectedObject',handles.selectin);
set(handles.outpnl,'SelectedObject',handles.pre);

% Creating the session called 's.'
s = daq.createSession('ni');
out = daq.createSession('ni');

% Getting the devices connected to the computer, labeling it 'd.'
daq.getDevices;

% initializing a continous background data collection rate of 1000 per
% second.
s.IsContinuous = true;
s.Rate = 100;
out.IsContinuous = true;
out.Rate = 100;

% adding two analog input channels from NIDaq board spots ai0 and ai1.
%s.addAnalogInputChannel('Dev1','ai0','Voltage');

inpnl_SelectionChangeFcn(hObject, eventdata, handles);
outpnl_SelectionChangeFcn(hObject, eventdata, handles);


% adding 1 listeners to acquire the data and calling the plot function. 
% plotData1(event.TimeStamps, event.Data, handles));
lh = s.addlistener('DataAvailable',@(src, event)Calculate(event.TimeStamps, event.Data, handles));
elh = s.addlistener('ErrorOccurred',@(src, event)OOPS(event.Error));

Temp = zeros(1,2);

% Choose default command line output for Lab10Sensors
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);



% UIWAIT makes Lab10Sensors wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Lab10Sensors_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Start.
function Start_Callback(~, ~, handles) %#ok<DEFNU>
% hObject    handle to Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global s 

% This will start the data collection when "Start" button is pressed.
% First defining channel strings to compare to.
ch0 = 'Channel 0';
ch1 = 'Channel 1';

inch0 = 'Channel 0';
inch1 = 'Channel 1';
inch2 = 'Channel 2';
inch3 = 'Channel 3';
inch4 = 'Channel 4';
inch5 = 'Channel 5';
inch6 = 'Channel 6';
inch7 = 'Channel 7';

% getting the string from the user selection for the input channel.
inchannel = get(handles.inpnl, 'SelectedObject');
inch = get(inchannel, 'String');

% See commenting below as it is the same.

if (strcmp(inch, inch0) || strcmp(inch, inch1) || strcmp(inch, inch2) || strcmp(inch, inch3) || strcmp(inch, inch4) || strcmp(inch, inch5) || strcmp(inch, inch6) || strcmp(inch, inch7))
    % do nothing
else
    msgbox('Please select an Input Channel');
end
   
% Then getting the string values from the radio button group Ouput Channel.
% Then do some error handling. If the user hasnt selected either channel 0
% or channel 1 then prompt user to select one with a msg box. This program
% will not start until an output channel is selected. 
    outchannel = get(handles.outpnl, 'SelectedObject');
    outch = get(outchannel, 'String');
     if (strcmp(outch, ch0) || strcmp(outch,ch1))
         s.startBackground
     else
         msgbox('Please select an Output Channel');
     end

% --- Executes on button press in STOP.
function STOP_Callback(~, ~, ~) %#ok<DEFNU>
% hObject    handle to STOP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% This will stop the data collection when the "STOP" button is pushed. 
global s 
s.stop 


function Tthresh_Callback(~, ~, ~) %#ok<DEFNU>
% hObject    handle to Tthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tthresh as text
%        str2double(get(hObject,'String')) returns contents of Tthresh as a double


% --- Executes during object creation, after setting all properties.
function Tthresh_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to Tthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function plotData1(time, T, handles)


% Plotting the Temp and Pressure Voltages.
% Pressure voltages plot. 
plot(handles.axes1, time, T, 'LineWidth', 2, 'Color', 'b');
ylim(handles.axes1, [(0.8*min(T)) (1.2*max(T))]);
xlabel(handles.axes1, 'Time (s)','FontSize',12,'FontWeight','bold','Color','w');
ylabel(handles.axes1, 'Temperature (°C)','FontSize',12,'FontWeight','bold','Color','w');
title(handles.axes1, 'Temperature Controller', 'FontSize', 20, 'FontWeight', 'bold');


% Here I am sending continious values to the static text box on the GUI.
% I send values for each Temperature.
set(handles.CurrentTemp, 'String', num2str(T, '%.1f'));

function [T] = Calculate(time, data, handles)

global s out Temp t

% This is used for kelvin to celcius conversion.
T0 = 273.15;

% This is the incoming Temperature voltages.
TV = data(:,1);

% Converting from voltages to kelvin. 
TK = TV/0.01;

% Converting from kelvin to celcius.
T = TK-T0;

% creating an array of the data
% T1 = [T];
% Temp = vertcat(Temp, T1);
avgt = mean(T);

% Getting the value of the Temperature threshold from the user on the GUI
% edit text box. Then converting that string to a number. 
TempThresh = get(handles.Tthresh, 'string');
deltaT = str2double(TempThresh);
DTCHCK = isnan(deltaT);

if any(DTCHCK)
    % reset to the value 5
    TempThresh = '5';
    
    % i probably dont need to do a str2double here but I will anyways 
    % for consistancy.
    deltaT = str2double(TempThresh);
    
    % Send message box and stop.
    msgbox('Please enter a number');
    s.stop
else
    % Do nothing.
end

% Here I am getting the value of the set temperature which is user defined 
% by the edit text box on the GUI. Then converting that string to a number.
% I am also setting up some error handling techniques using 'try' and 'catch'.
% We will try to convert Tempset to a num if it fails do the catch
% statement.

Tempset = get(handles.Tset, 'string');
Tset = str2double(Tempset);
TSCHCK = isnan(Tset);

if any(TSCHCK)
    % reset number to 25
    Tempset = '25';
    Tset = str2double(Tempset);
    % send error box.
    msgbox('Please enter a number');
    % stop session.
    s.stop
else
    % Do nothing.
end


% Calculating both Tmax and Tmin which will be used to either turn off or
% turn on the heater if the temperature is too high or too low
% respectively. 
Tmax = Tset + deltaT;
Tmin = Tset - deltaT;

% Here I want to check to see if the user has defined a reasonable set
% temperature. 
A = (deltaT < 1);
B = (deltaT > 20);

if any(A)
   msgbox('Please use a T thresh value greater than 1');
   s.stop 
elseif any(B)
   msgbox('Please use a T thresh value less than 20');
   s.stop 
else
    % do nothing
end

% Here I am setting up some reasonable parameters for error handling. 
% For instance if the temperature goes below 20 °C then most likely
% something is wrong with the circuit. Similarly if the temperature goes
% above 50°C then something is most likely wrong with the circuit. Thus if
% any of these are true an error handling sequence will occur. 
C = (T < 20 | T > 50);

if any(C) 
    msgbox('The Temperature is out of range. Please fix the issue and retry. :)');
    s.stop
else  
    % do nothing we are all good!
end


% Here I am setting up variables B, and C to check in if else statements
% against a logical true. If a logical true happens then for the B case the
% heater should be turned on, else do nothing. If a logical true happens
% for the case of C then we need to turn the heater off. 
D = (avgt < Tmin);
E = (avgt > Tmax);

% Here I will check if any of the temperature values go above or drop
% below the threshold limits. If the current temp is below the
% threshold the heater will turn on. If the current temp is above the
% threshold then the heater will turn off. If the temp is within the
% threshold then nothing happens and the heater stays off until one of
% the two situations above occurs. :)
    if any(D)
        
        % Put a 5 volts onto the channel.
        outputSingleScan(out,5);
        
        % set the background color of status box to 'red'.
        % and text to ON.
        set(handles.status, 'BackgroundColor','r');
        set(handles.status, 'String', 'ON');
        
        % Still want to plot the data. 
        plotData1(time, T, handles);
    elseif any(E)  
     
        % Else turn the heater off. 
        % Send a 0V signal to the channel. 
        outputSingleScan(out,0);
        
        % change the status box color to 'blue'
        % and the text to off.
        set(handles.status, 'BackgroundColor','c');
        set(handles.status, 'String', 'OFF');
        
        % Still want to plot the data.
        plotData1(time, T, handles);
            
    else
        %If everything is good and the data has been calculated then plot.
        plotData1(time, T, handles);
        %outputSingleScan(out,0);
          
    end
    
    t = now;
    Temp = vertcat(Temp, horzcat(avgt, t));
    
function OOPS(Error)

global s out

% This function will stop the program and data collection
% in the event an error occurs. 
% A message box will pop up with instructions. 
msgbox('An error has occurred. Please make sure the device is plugged in and restart the program.');
disp(getReport(Error))

% I commented this out b/c it might cause a program restarting error.
% delete(lh);
s.stop
out.stop


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global s lh out elh flag flag2

% Below I am using these for error handling. If no channel has been
% selected by the user and they try to close the program an error occurs.
% So I am going to use a semifor flag. If the flag is high a channel has
% been set previously and I wont add a new channel. If the flag is low I
% will add a channel so the clsfcnreq will work.
if ((flag == 0) && (flag2 ==0)) 
s.addAnalogInputChannel('Dev1','ai0','Voltage');
out.addAnalogOutputChannel('Dev1','ao0','Voltage');
elseif flag == 0
    s.addAnalogInputChannel('Dev1','ai0','Voltage');
elseif flag2 ==0
    out.addAnalogOutputChannel('Dev1','ao0','Voltage');
    % do nothing.
end

outputSingleScan(out,0);

% deletes the session and handler if the [x] button is hit on the GUI. 
% It also prevents MATLAB from crashing. 
delete(s);
delete(out);
delete(lh);
delete(elh);

% Hint: delete(hObject) closes the figure
delete(hObject);


function Tset_Callback(~, ~, ~) %#ok<DEFNU>
% hObject    handle to Tset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tset as text
%        str2double(get(hObject,'String')) returns contents of Tset as a double


% --- Executes during object creation, after setting all properties.
function Tset_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to Tset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function status_Callback(~, ~, ~) %#ok<DEFNU>
% hObject    handle to status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of status as text
%        str2double(get(hObject,'String')) returns contents of status as a double


% --- Executes during object creation, after setting all properties.
function status_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Inchannel.
function Inchannel_Callback(~, ~, ~) %#ok<DEFNU>
% hObject    handle to Inchannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% inchannel = get(handles.inpnl, 'SelectedObject');
% inch = get(inchannel, 'String');



% --- Executes on button press in Outchannel.
function Outchannel_Callback(~, ~, ~) %#ok<DEFNU>
% hObject    handle to Outchannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% outchannel = get(handles.inpnl, 'SelectedObject');
% outch = get(outchannel, 'String');



% --- Executes on button press in excelwrite.
function excelwrite_Callback(~, ~, handles) %#ok<DEFNU>
% hObject    handle to excelwrite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Temp 

fileName = get(handles.Filename, 'String');

% curly brackets for array of strings
titles = {'Temperature (K)', 'Year', 'Month', 'Day','Minute', 'Seconds'};


% deletes pre-allocated zeros from earlier.
%Temp = Temp(2:end,:);
%time = time(2:end,:);


%Temp = vertcat(Temp);

xlswrite(fileName, titles, 1, 'A1');

xlswrite(fileName, Temp(:,1), 1, 'A2');
xlswrite(fileName, datevec(Temp(:,2)), 1, 'B2');
%xlswrite(fileName, time, 1, 'C2');



function Filename_Callback(~, ~, ~) %#ok<DEFNU>
% hObject    handle to Filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Filename as text
%        str2double(get(hObject,'String')) returns contents of Filename as a double


% --- Executes during object creation, after setting all properties.
function Filename_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to Filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% newValue gets the channel they selected (or the button tag).
% --- Executes when selected object is changed in inpnl.
function inpnl_SelectionChangeFcn(~, ~, handles)
% hObject    handle to the selected object in inpnl 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
% --- Executes when selected object is changed in outpnl.
global s flag


inch0 = 'Channel 0';
inch1 = 'Channel 1';
inch2 = 'Channel 2';
inch3 = 'Channel 3';
inch4 = 'Channel 4';
inch5 = 'Channel 5';
inch6 = 'Channel 6';
inch7 = 'Channel 7';

% getting the string from the user selection for the input channel.
inchannel = get(handles.inpnl, 'SelectedObject');
inch = get(inchannel, 'String');


% Below is the switch case statement for the analog input channel
% selection. when the user selects a channel that channel will be added to
% the session and all other channel selections will be blanked out. If you
% want to change your channel selection the program must restart.
switch inch
    case inch0
        s.addAnalogInputChannel('Dev1','ai0','Voltage');
        set(handles.inch1, 'Enable', 'Off');
        set(handles.inch2, 'Enable', 'Off');
        set(handles.inch3, 'Enable', 'Off');
        set(handles.inch4, 'Enable', 'Off');
        set(handles.inch5, 'Enable', 'Off');
        set(handles.inch6, 'Enable', 'Off');
        set(handles.inch7, 'Enable', 'Off');
        set(handles.selectin, 'Enable', 'Off');
        flag = 1;
    case inch1
        s.addAnalogInputChannel('Dev1','ai1','Voltage');
        set(handles.inch0, 'Enable', 'Off');
        set(handles.inch2, 'Enable', 'Off');
        set(handles.inch3, 'Enable', 'Off');
        set(handles.inch4, 'Enable', 'Off');
        set(handles.inch5, 'Enable', 'Off');
        set(handles.inch6, 'Enable', 'Off');
        set(handles.inch7, 'Enable', 'Off');
        set(handles.selectin, 'Enable', 'Off');
        flag = 1;
    case inch2
        s.addAnalogInputChannel('Dev1','ai2','Voltage');
        set(handles.inch0, 'Enable', 'Off');
        set(handles.inch1, 'Enable', 'Off');
        set(handles.inch3, 'Enable', 'Off');
        set(handles.inch4, 'Enable', 'Off');
        set(handles.inch5, 'Enable', 'Off');
        set(handles.inch6, 'Enable', 'Off');
        set(handles.inch7, 'Enable', 'Off');
        set(handles.selectin, 'Enable', 'Off');
        flag = 1;
    case inch3
        s.addAnalogInputChannel('Dev1','ai3','Voltage');
        set(handles.inch0, 'Enable', 'Off');
        set(handles.inch1, 'Enable', 'Off');
        set(handles.inch2, 'Enable', 'Off');
        set(handles.inch4, 'Enable', 'Off');
        set(handles.inch5, 'Enable', 'Off');
        set(handles.inch6, 'Enable', 'Off');
        set(handles.inch7, 'Enable', 'Off');
        set(handles.selectin, 'Enable', 'Off');
        flag = 1;
    case inch4
        s.addAnalogInputChannel('Dev1','ai4','Voltage');
        set(handles.inch0, 'Enable', 'Off');
        set(handles.inch1, 'Enable', 'Off');
        set(handles.inch2, 'Enable', 'Off');
        set(handles.inch3, 'Enable', 'Off');
        set(handles.inch5, 'Enable', 'Off');
        set(handles.inch6, 'Enable', 'Off');
        set(handles.inch7, 'Enable', 'Off');
        set(handles.selectin, 'Enable', 'Off');
        flag = 1;
    case inch5
        s.addAnalogInputChannel('Dev1','ai5','Voltage');
        set(handles.inch0, 'Enable', 'Off');
        set(handles.inch1, 'Enable', 'Off');
        set(handles.inch2, 'Enable', 'Off');
        set(handles.inch3, 'Enable', 'Off');
    	set(handles.inch4, 'Enable', 'Off');
        set(handles.inch6, 'Enable', 'Off');
        set(handles.inch7, 'Enable', 'Off');
        set(handles.selectin, 'Enable', 'Off');
        flag = 1;
    case inch6
        s.addAnalogInputChannel('Dev1','ai6','Voltage');
        set(handles.inch0, 'Enable', 'Off');
        set(handles.inch1, 'Enable', 'Off');
        set(handles.inch2, 'Enable', 'Off');
        set(handles.inch3, 'Enable', 'Off');
        set(handles.inch4, 'Enable', 'Off');
        set(handles.inch6, 'Enable', 'Off');
        set(handles.inch7, 'Enable', 'Off');
        set(handles.selectin, 'Enable', 'Off');
        flag = 1;
    case inch7
        s.addAnalogInputChannel('Dev1','ai7','Voltage');
        set(handles.inch0, 'Enable', 'Off');
        set(handles.inch1, 'Enable', 'Off');
        set(handles.inch2, 'Enable', 'Off');
        set(handles.inch3, 'Enable', 'Off');
        set(handles.inch4, 'Enable', 'Off');
        set(handles.inch5, 'Enable', 'Off');
        set(handles.inch6, 'Enable', 'Off');
        set(handles.selectin, 'Enable', 'Off');
        flag = 1;
end


function outpnl_SelectionChangeFcn(~, ~, handles) 
% hObject    handle to the selected object in outpnl 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

global out flag2

% Declaring strings to compare in the switch case statement below.
ch0 = 'Channel 0';
ch1 = 'Channel 1';

% getting the string from the user selection for the output channel.
outchannel = get(handles.outpnl, 'SelectedObject');
outch = get(outchannel, 'String');


% if channel 0 is selected add that analog channel, disable other channel
% selections, else if channel 1 is selected add that analog channel and
% disable the other channel selections. A similar method will be used fort
% the input channel selection.
switch outch
    case ch0
    out.addAnalogOutputChannel('Dev1','ao0','Voltage');
    set(handles.ouch1, 'Enable', 'Off');
    set(handles.pre, 'Enable', 'Off');
    flag2 = 1;
    case ch1
    out.addAnalogOutputChannel('Dev1','ao1','Voltage');
    set(handles.ouch0, 'Enable', 'Off');
    set(handles.pre, 'Enable', 'Off');
    flag2 = 1;
    
end
