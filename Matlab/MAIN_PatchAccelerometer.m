%% MAIN INFORMATION
for Close_MainInfo = 1
    % Project's name: Assessing Tremor from Patch Accelerometer
    % PI: Assist. Prof. Dr. Sadeque Reza Khan: sadeque.khan@hw.ac.uk
    % Matlab pipeline main author: Assist. Prof. Dr. Encarna Micó Amigo: M.Mico_Amigo@hw.ac.uk
    % Affiliation: School of Engineering & Physical Sciences, Heriot-Watt University
    % Start Date (Matlab): January 2024

    % GENERAL DESCRIPTION:
    % Objective: Extracting features from accelation and gyroscope signals to allow identification of tremor induced on healthy participants
    % Protocol: Superised context, induced vs. non-induced tremor, sensor located on the hand
    % Populations: team, healthy participants
    % Data's type:
    % a) Triaxial acceleration & triaxial angular velocity & mangetometer
    % b) 6 participants, volunteers
    % c) Two status: induced vs. non-induced tremor, while walking and just resting hand
    % * Acceleration channels: VT,ML,AP
    % * Gyroscope channels: Yaw(around VT axis),Pitch(around ML axis),Roll(around AP axis)
end


%% [0] PREPARATION & ACTIVATION & SETTINGS
for Close_Prepare_Settings = 1
    % 0.1 Initialize variables and plots
    for Close_Initialize_Variables_Plots = 1
        tic                                                                 % starts calculating time for computation
        clear variables                                                     % clean all the variables
        Tools.Keepvars = {'Tools'};
        clearvars('-except', Tools.Keepvars{:});
        close all                                                           % close all plots
        clc                                                                 % clean Command Window, but it does not clean variables or closes plots
        format compact                                                      % sets a compact format
        %format long                                                        % sets a long format
        set(groot,'defaultAxesColorOrder',[0 0 1;0 0.5 0;1 0 0;0 0.75 0.75;0.75 0 0.75;0.75 0.75 0;0.25 0.25 0.25]) % hold function is adapted (see hold function current folder) such that the color order index is not reset (new plot starts with blue again)%
        Letters = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','AA','AB','AC','AD','AE','AF','AG','AH','AI','AJ','AK','AL','AM','AN','AO','AP','AQ','AR','AS','AT','AU','AV','AW','AX','AY','AZ','BA','BB','BC','BD','BE','BF','BG','BH','BI','BJ','BK','BL','BM','BN','BO','BP','BQ','BR','BS','BT','BU','BV','BW','BX','BY','BZ','CA','CB','CC','CD','CE','CF','CG','CH','CI','CJ','CK','CL','CM','CN','CO','CP','CQ','CR','CS','CT','CU','CV','CW','CX','CY','CZ','DA','DB','DC','DD','DE','DF','DG','DH','DI','DJ','DK','DL','DM','DN','DO','DP','DQ','DR','DS','DT','DU','DV','DW','DX','DZ','EA','EB','EC','ED','EE','EF','EG','EH','EI','EJ','EK','EL','EM','EN','EO','EP','EQ','ER','ES','ET','EU','EV','EW','EX','EZ','FA','FB','FC','FD','FE','FF','FG','FH','FI','FJ','FK','FL','FM','FN','FO','FP','FQ','FR','FS','FT','FU','FV','FW','FX','FZ','GA','GB','GC','GD','GE','GF','GG','GH','GI','GJ','GK','GL','GM','GN','GO','GP','GQ','GR','GS','GT','GU','GV','GW','GX','GZ','HA','HB','HC','HD','HE','HF','HG','HH','HI','HJ','HK','HL','HM','HN','HO','HP','HQ','HR','HS','HT','HU','HV','HW','HX','HZ'};
        Numbers = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60','61','62','63','64','65','66','67','68','69','70','71','72','73','74','75','76','77','78','79','80','81','82','83','84','85','86','87','88','89','90','91','92','93','94','95','96','97','98','99','100','101','102','103','104','105','106','107','108','109','110','111','112','113','114','115','116','117','118','119','120','121','122','123','124','125','126','127','128','129','130','131','132','133','134','135','136','137','138','139','140','141','142','143','144','145','146','147','148','149','150','151','152','153','154','155','156','157','158','159','160','161','162','163','164','165','166','167','168','169','170','171','172','173','174','175','176','177','178','179','180','181','182','183','184','185','186','187','188','189','190','191','192','193','194','195','196','197','198','199','200','201','202','203','204','205','206','207','208','209','210','211','212','213','214','215','216','217','218','219','220','221','222','223'};
    end

    % 0.2 Define directory
    for Close_Define_Directory = 1
        DirectoryPath_Data = ('C:\Users\mm2229\OneDrive - Heriot-Watt University\Datasets - First tremor assessment');
        DirectoryPath_Matlab = ('C:\Users\mm2229\OneDrive - Heriot-Watt University\Matlab\PD HWU');
        cd(DirectoryPath_Data);
        addpath(genpath(DirectoryPath_Matlab));                             % add that folder plus all subfolders to the path.
    end

    % 0.3 Define settings & Activate analyses
    for Close_ActivateAnalyses = 1
        do.CollectData = 0;                                                 % [1] READ RAW DATA - csv      ---> Matlab: from the provided documents, the data is read and structured in a Matlab format struct
        do.ExtractFeatures = 0;                                             % [2] EXTRACT FEATURES         ---> Signals are analysed and features are extracted
        do.CreateMatrix = 1;                                                % [3] CREATE A MATRIX          ---> The structure of all features extracted and original data are combined to create a single matrix
    end
    % 0.4 Settings for features extraction
    for Close_SetSettings = 1
        Settings = struct;                                                  % preparation of a structure for general settings
        % Signals Processing
        Settings.windowLength = 1.6; %[s]                                   % window used for activity classification
        Settings.SigLevel = 0.05;                                           % alpha value for ttest, scalar between 0 and 1. Default = 0.05
        Settings.Fs = 208; %[Hz]                                            % approximate sampling frequency deduced from the data
        Settings.Fc_LowPassFilter = 10;    %20                              % cut-off frequency used for low-pass filters: frequencies scale according to the sampling rate
        Settings.Fc_HighPassFilter_AutoCorr = 1; %0.8                       % cut-off frequency used for high-pass filters for autocorrelation unbiased
        Settings.N_Harm = 20;                                               % number of harmonics used for harmonic ratio, index of harmonicity and phase fluctuation
        Settings.HanningWindow_Size = 1000; %[samples = /200s]              % 5 s = 1000 samples of Hanning Window used to extract spectral component
        Settings.MaxRangeFrequencyPSD = 10;                                 % maximal range of frequencies to find frequency of the peak power spectral density (PSD)
        Settings.MinRangeFrequencyPSD = 1;                                  % miniaml range of frequencies to find frequency of the peak power spectral density (PSD)
        Settings.JunkSize = 3; % 4,5,7,10 [s]                               % durations of windows in seconds to extract features from signals
        % Data Structure
        Settings.analyseBinaryTremor = 1;                                   % =1: analyse NonTremor (Stationary, Writing, Drawing) vs. Tremor (Stationary_Tremor, Writing_Tremor, Drawing_Tremor); 0: analyse each protocol individually as described bellow
        Settings.ProtocolsAll_Names = ...
            {'Stationary','Writing','Drawing','Stationary_Tremor','Writing_Tremor','Drawing_Tremor'}; % protocols to address at the current analysis
        Settings.ProtocolsBinary_Names = ...
            {'NonTremor','Tremor'};
        Settings.Protocols_Codes = [0,1,2,3,4,5];                           % associated codes to the protocols labeled in the input data
    end
    for Close_PlotSettings = 1
        PlotSettings.SpectralFeatures = 0;                                  % activate plots to help understanding the calculation of power spectral density of signals
    end
    clear Close_ActivateAnalyses Close_Define_Directory Close_PlotSettings Close_SetSettings
end


%% [1] COLLECT DATA
for Close_CollectData = 1
    if do.CollectData
        cd(DirectoryPath_Data)
        Subjects_Names = dir(DirectoryPath_Data);
        Subjects_isdir = ~ismember({Subjects_Names.name}, {'.', '..','desktop.ini'}); % Matlab often creates additional components in the list "." and ".." to avoid
        Subjects_Names = Subjects_Names(Subjects_isdir);
        Subjects_Size = size(Subjects_Names,1);
        for iSubject = 1:Subjects_Size
            Subject_NameSelected = Subjects_Names(iSubject,1).name;
            PatchAccData.(['Subject' num2str(iSubject)]).Name = Subject_NameSelected;
            Subject_Folder = [DirectoryPath_Data '\' Subject_NameSelected];
            cd(Subject_Folder)
            Files = dir(Subject_Folder);
            Files_isdir = ~ismember({Files.name}, {'.', '..'});
            Files = Files(Files_isdir);
            Files_Size = size(Files,1);
            for iFile = 1:Files_Size
                File_NameComplete = Files(iFile,1).name;
                if ~contains(File_NameComplete,'_')
                    continue
                end
                File_Format = getNameFromOriginalFileInBetweenLines(File_NameComplete,'_','last','last','.');
                if ~strcmp(File_Format,'labeled')
                    continue
                end
                File_Sensor = getNameFromOriginalFileInBetweenLines(File_NameComplete,'_',2,3,'_');                    
                File_Input = xlsread(File_NameComplete);
                PatchRawData.(['Subject' num2str(iSubject)]).(File_Sensor) = File_Input; % Raw dataset (time stamp, X,Y,ML)
                clear File_NameComplete File_Format File_Sensor File_Input
            end %iFile
            clear iFile Subject_Name Subject_Folder Files Files_isdir Files_Size
        end % iSubject
        clear iSubject Subjects_Names Subjects_isdir Subjects_Size Subject_Folder Subject_NameSelected
        cd(DirectoryPath_Matlab)
        save('PatchRawData','PatchRawData')
    end % if do.Collect_Data
    clear Close_CollectData
end % Close_CollectData


%% [2] CALCULATE FEATURES
for Close_ExtractFeatures = 1
    if do.ExtractFeatures
        if ~exist('PatchRawData', 'var')
            cd(DirectoryPath_Matlab)
            load PatchRawData
        end
        if Settings.analyseBinaryTremor                                     % =1: analyse NonTremor (Stationary, Writing, Drawing) vs. Tremor (Stationary_Tremor, Writing_Tremor, Drawing_Tremor); 0: analyse each protocol individually as described bellow
            Protocols_Names = Settings.ProtocolsBinary_Names;
        else
            Protocols_Names = Settings.ProtocolsAll_Names;
        end
        Protocols_Size = size(Protocols_Names,2);
        Subjects_Names = fieldnames(PatchRawData);
        Subjects_Size = size(Subjects_Names,1);
        for iSubject = 1:Subjects_Size
            Subject_NameSelected = Subjects_Names{iSubject};
            for iProtocol = 1:Protocols_Size
                Protocol_NameSelected = Protocols_Names{iProtocol};
                Protocol_CodeSelected = Settings.Protocols_Codes(1,iProtocol);
                PatchFeatures.Acceleration.(Subject_NameSelected).(Protocol_NameSelected) = extractFeatures(PatchRawData.(Subject_NameSelected).Acceleration,Protocol_NameSelected,Protocol_CodeSelected,Settings,PlotSettings);
                PatchFeatures.Gyroscope.(Subject_NameSelected).(Protocol_NameSelected) = extractFeatures(PatchRawData.(Subject_NameSelected).Gyroscope,Protocol_NameSelected,Protocol_CodeSelected,Settings,PlotSettings);
            end % iProtocol
            clear iProtocol
        end % iSubject
        clear iSubject Subjects_Names Subjects_Size Protocols_Names Protocols_Size
        cd(DirectoryPath_Matlab)
        save('PatchFeatures','PatchFeatures')
    end % if do.ExtractFeatures
    clear Close_ExtractFeatures
end


%% [3] GENERATE MATRIX
for Close_CreateMatrix = 1
    if do.CreateMatrix
        if ~exist('PatchFeatures', 'var')
            cd(DirectoryPath_Matlab)
            load PatchFeatures
        end
        Sensors_Names = {'Acceleration','Gyroscope'};%,'Magnetometer'};
        Sensors_Size = size(Sensors_Names,2);
        PatchTable.Acceleration = []; PatchTable.Gyroscope = []; PatchTable.Magnetometer = [];
        for iSensor = 1:Sensors_Size
            Subjects_Name = fieldnames(PatchFeatures.(Sensors_Names{iSensor}));
            Subjects_Size = size(Subjects_Name,1);
            for iSubject = 1:Subjects_Size
                Protocols_Name = fieldnames(PatchFeatures.(Sensors_Names{iSensor}).(Subjects_Name{iSubject}));
                Protocols_Size = size(Protocols_Name,1);
                for iProtocol = 1:Protocols_Size
                    TableLoop = struct2table(PatchFeatures.(Sensors_Names{iSensor}).(Subjects_Name{iSubject}).(Protocols_Name{iProtocol}));
                    ProtocolName_Info = convertCharsToStrings(Protocols_Name{iProtocol});
                    TableProtocol = addvars(TableLoop,ProtocolName_Info,'NewVariableNames','Protocol','Before','DominantFreq_VT');
                    ProtocolCode_Info = Settings.Protocols_Codes(iProtocol);
                    TableProtocol = addvars(TableProtocol,ProtocolCode_Info,'NewVariableNames','ProtocolCode','Before','Protocol');
                    SubjectName_Info = Subjects_Name{iSubject};
                    SubjectName_Info = getNameFromOriginalFileInBetweenLines(SubjectName_Info,'t','last',0);
                    SubjectName_Info = str2num(SubjectName_Info);
                    TableInfo = addvars(TableProtocol,SubjectName_Info,'NewVariableNames','Subject','Before','ProtocolCode');
                    PatchTable.(Sensors_Names{iSensor}) = [PatchTable.(Sensors_Names{iSensor}); TableInfo];
                    clear TableLoop ProtocolName_Info TableProtocol ProtocolCode_Info SubjectName_Info TableInfo
                end % iProtocol
                clear iProtocol
            end % iSubject
            clear iSubject Protocols_Name Protocols_Size
            cd(DirectoryPath_Matlab)
            %PatchTable.(Sensors_Names{iSensor}) = rows2vars(PatchTable.(Sensors_Names{iSensor}));
            PatchTableName = ['PatchTable_' Sensors_Names{iSensor} '.csv'];
            writetable(PatchTable.(Sensors_Names{iSensor}),PatchTableName) % Save and transfor into .csv format
        end % iSensor
        clear iSensor Subjects_Name Subjects_Size Sensors_Names Sensors_Size
        cd(DirectoryPath_Matlab)
        save('PatchTable','PatchTable')
    end % if do.GenerateMatrix
    clear Close_CreateMatrix
end


