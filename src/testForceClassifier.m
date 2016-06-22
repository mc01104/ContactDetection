function varargout = testForceClassifier(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testForceClassifier_OpeningFcn, ...
                   'gui_OutputFcn',  @testForceClassifier_OutputFcn, ...
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


% --- Executes just before testForceClassifier is made visible.
function testForceClassifier_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testForceClassifier (see VARARGIN)

% Choose default command line output for testForceClassifier
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global data;
data = struct('Filenames', ' ',...
              'Index', 1,...
              'PauseButtonPressed', false, ...
              'DirName', '', ...
              'Training', '', ...
              'TrainIndex', 1, ...
              'Labels', [], ...
              'isLabelled', false);
global model;

% UIWAIT makes testForceClassifier wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function directoryName = LoadData()
directoryName = uigetdir('.', 'Choose image sequence');
global data;
data.Filenames = dir(strcat(directoryName,'\*.png'));
data.DirName = directoryName;

% --- Outputs from this function are returned to the command line.
function varargout = testForceClassifier_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Train.
function Train_Callback(hObject, eventdata, handles)
% hObject    handle to Train (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data;
data.PauseButtonPressed = true;

% randomly permute data and pick jsut 20 images for manual labeling
ind = randperm(length(data.Filenames));
dataShuffled = data.Filenames(ind);
data.Training = dataShuffled(1:20);

% iterate over the chosen images and ask the user to label
msgbox(sprintf('Please label the following %d sample images', length(data.Training)));
LabelData(handles);
msgbox('Labelling completed');

date_str = sprintf('%d_%d_%d_%d_%d_%d', floor(datevec(now)));

input_data = data.Training;
output_data_num = data.Labels;

output_data = cell(length(output_data_num), 1);
for i = 1:length(output_data_num)
   switch(output_data_num(i))
       case 0
           output_data{i} = 'semi';
       case 1
           output_data{i} = 'contact';
       case -1
           output_data{i} = 'free';
   end
end
save(strcat(date_str, '-training_data'), 'input_data', 'output_data');

% Train classifier
global model;

% model = fitcecoc(input_data, output_data);
% msgbox('Training completed');
% save(model);

function LabelData(handles)
global data;
numOfSamples = length(data.Training);

for i = 1:numOfSamples
    data.isLabelled = false;
    RenderGUI(handles, data.Training(i).name);
    while ~data.isLabelled
        pause(0.1);
    end
end


% --- Executes on button press in RunClassifier.
function RunClassifier_Callback(hObject, eventdata, handles)
% hObject    handle to RunClassifier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ContactLabel.
function ContactLabel_Callback(hObject, eventdata, handles)
% hObject    handle to ContactLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data;
data.Labels(data.TrainIndex) = 1;
data.isLabelled = true;
data.TrainIndex = data.TrainIndex + 1;


% --- Executes on button press in SemiContactLabel.
function SemiContactLabel_Callback(hObject, eventdata, handles)
% hObject    handle to SemiContactLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data;
data.Labels(data.TrainIndex) = 0;
data.isLabelled = true;
data.TrainIndex = data.TrainIndex + 1;

% --- Executes on button press in FreeLabel.
function FreeLabel_Callback(hObject, eventdata, handles)
% hObject    handle to FreeLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data;
data.Labels(data.TrainIndex) = -1;
data.isLabelled = true;
data.TrainIndex = data.TrainIndex + 1;

% --- Executes on button press in NextButton.
function NextButton_Callback(hObject, eventdata, handles)
% hObject    handle to NextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data;
if data.Index < length(data.Filenames)
    data.Index = data.Index + 1;
end
RenderGUI(handles);

% --- Executes on button press in PreviousButton.
function PreviousButton_Callback(hObject, eventdata, handles)
% hObject    handle to PreviousButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data;
if data.Index > 1
    data.Index = data.Index - 1;
end
RenderGUI(handles);

% --- Executes on button press in PlayButton.
function PlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data;
data.pauseButtonPressed = false;
while ~data.pauseButtonPressed && data.Index < length(data.Filenames)
    data.Index = data.Index + 1;
    RenderGUI(handles);
    pause(0.1);
end

% --- Executes on button press in PauseButton.
function PauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to PauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data;
data.pauseButtonPressed = 1;

% --- Executes on button press in LoadButton.
function LoadButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LoadData();
global data;
msgbox(sprintf('Loaded %d images', length(data.Filenames)));
RenderGUI(handles);

function RenderGUI(handles, image)
global data;
if nargin > 1
    tmpName = strcat(data.DirName, '\', image);
else
    tmpName = strcat(data.DirName, '\', data.Filenames(data.Index).name);
end
tmpImage = imread(tmpName);
axes(handles.ImageViewer);
imshow(tmpImage, 'Parent', handles.ImageViewer);

tmp_gray = rgb2gray(tmpImage);

% Logarithm transformation
% tmp_gray = log(1 + double(tmp_gray));
% tmp_gray = mat2gray(tmp_gray);

% Histogram Equalization
% tmp_gray = histeq(tmp_gray);

C = corner(tmp_gray);
if ~isempty(C)
    C = postprocess_corner_detection(C);
end
hold( handles.ImageViewer, 'on');
plot(C(:, 1), C(:, 2), 'g*');
hold(handles.ImageViewer, 'off');

R = double(tmpImage(:, :, 1));
G = double(tmpImage(:, :, 2));
B = double(tmpImage(:, :, 3));

% convert to opponent space
O1 = (R-G)./sqrt(2); % red-green
O2 = (R+G-2*B)./sqrt(6); % yello-blue
O3 = (R+G+B)./sqrt(3);
axes(handles.Histogram);
histogram(O2, 100);
axis([-100 100 0 8000]);
axes(handles.Histogram2);
histogram(O1, 100);
axis([-100 100 0 8000]);


% --- Executes on button press in Rewind.
function Rewind_Callback(hObject, eventdata, handles)
% hObject    handle to Rewind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data;
data.Index = 1;
RenderGUI(handles);


function C = postprocess_corner_detection(C)
ind = [];
for i = 1:size(C, 1)
    if C(i, 1) < 100 || C(i, 2) < 40 || C(i, 1) > 200 || C(i, 2) > 200     
        ind = [ind i];
    end
end

C(ind, :) = [];
