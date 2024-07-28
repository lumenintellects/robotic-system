function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 28-Jul-2024 13:22:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialize occupancy grid
global occupancyGrid;
occupancyGrid = zeros(5, 10); % 5x10 grid

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_forward.
function pushbutton_forward_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_forward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global motorLeftHandle motorRightHandle simClient
    simClient.setJointTargetVelocity(motorLeftHandle, 0.5); % Set speed as required
    simClient.setJointTargetVelocity(motorRightHandle, 0.5);

% --- Executes on button press in pushbutton_reverse.
function pushbutton_reverse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reverse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global motorLeftHandle motorRightHandle simClient
    simClient.setJointTargetVelocity(motorLeftHandle, -0.5); % Set speed as required
    simClient.setJointTargetVelocity(motorRightHandle, -0.5);

% --- Executes on button press in pushbutton_stop.
function pushbutton_stop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global motorLeftHandle motorRightHandle simClient
    simClient.setJointTargetVelocity(motorLeftHandle, 0);
    simClient.setJointTargetVelocity(motorRightHandle, 0);

% --- Executes on button press in pushbutton_right.
function pushbutton_right_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global motorLeftHandle motorRightHandle simClient
    simClient.setJointTargetVelocity(motorLeftHandle, 0.5); % Set speed as required
    simClient.setJointTargetVelocity(motorRightHandle, -0.5);

% --- Executes on button press in pushbutton_left.
function pushbutton_left_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global motorLeftHandle motorRightHandle simClient
    simClient.setJointTargetVelocity(motorLeftHandle, -0.5); % Set speed as required
    simClient.setJointTargetVelocity(motorRightHandle, 0.5);


% --- Executes on button press in pushbutton_connect_create.
function pushbutton_connect_create_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_connect_create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Call the function Connect_CreateWall
    Connect_CreateWall();

% --- Executes on button press in pushbutton_start_streaming.
function pushbutton_start_streaming_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_start_streaming (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    myOccupancyGridFunction(handles);

% --- Executes on button press in pushbutton_stop_streaming.
function pushbutton_stop_streaming_Callback(hObject, eventdata, handles)
    global streamingFlag;
    streamingFlag = false;


% --- Executes on button press in pushbutton_exploration_auto.
function pushbutton_exploration_auto_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_exploration_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    main()

% --- Executes on button press in pushbutton_exploration_manual.
function pushbutton_exploration_manual_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_exploration_manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
