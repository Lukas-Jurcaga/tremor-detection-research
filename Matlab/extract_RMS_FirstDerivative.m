function FEATURES = extract_RMS_FirstDerivative(Signal_Detr_LPFilt,Settings,FEATURES)
%FEATURES = extract_RMS_FirstDerivative(Signal_Detr_LPFilt,Settings,FEATURES)

%% FUNCTION INFO
for Close_Function_Info = 1
    
    % EXPLANATION:
    % *** Calculation of Root-mean-square of signals (pure)
    % * Ref 1) According to: Micó-Amigo ME, Kingma I, Faber GS, Kunikoshi A, van Uem JMT, van Lummel RC, Maetzler W, van Dieën JH.
    % "Is the Assessment of 5 Meters of Gait with a Single Body-Fixed-Sensor Enough to Recognize Idiopathic Parkinson's Disease-Associated Gait?"
    % Ann Biomed Eng 45(5),(2017): 1266-1278"
    % Calculation of Root-mean-square of signals (ratio)
    % * Ref 2) According to: Sekine M, Tamura T, Yoshida M, Suda Y, Kimura Y, Miyoshi H, Kijima Y, Higashi Y, Fujimoto T..
    % "A gait abnormality measure based on root mean square of trunk acceleration."
    % J Neuroeng Rehabil,(2013): https://www.ncbi.nlm.nih.gov/pubmed/24370075
    % *** Calculation of Jerk (acc) or Angular Acc (gyro): 1st derivative of signals
    % * Ref 3) According to: Luca Palmerini, Sabato Mellone, Guido Avanzolini, Franco Valzania, and Lorenzo Chiari.
    % "Quantification of Motor Impairment in Parkinson’s Disease Using an Instrumented Timed Up and Go Test"
    % IEEE TRANSACTIONS ON NEURAL SYSTEMS AND REHABILITATION ENGINEERING, VOL. 21, NO. 4, JULY 2013
    
    % INPUTS: (the same as previous function)
    % 1) Signal_Detr_LPFilt: contains the available data following fields:
    % Signal_Detr_LPFilt(:,1) = TimeStamp
    % Signal_Detr_LPFilt(:,2) = VT direction of recorded signal
    % Signal_Detr_LPFilt(:,3) = ML direction of recorded signal
    % Signal_Detr_LPFilt(:,4) = AP direction of recorded signal
    % 2) Settings for frequency analysis
    % Settings.Fs                                                           % sampling frequency
    % Settings.Fc_LowPassFilter = 20;                                       % cut-off frequency used for low-pass filters: frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz
    % 3) WalkingBout (info)
    % WalkingBout.start                                                     % start of each walking bout (size = number of walking bouts)
    % WalkingBout.end                                                       % end of each walking bout (size = number of walking bouts)
    
    % OUTPUTS:
    % FEATURES.Median_SigComplete.(NameChannels{iChannel}){iJunkSize}       % Median value of complete signal
    %         .Range_SigComplete                                            % Range of complete signal
    %         .RMS_SigComplete                                              % RMS of complete signal
    %         .RMSratio_SigComplete                                         % RMS ratio of complete signal
    %         .FirstDerivativeMean_SigComplete                              % Mean of 1st derivative of complete signal
    %         .FirstDerivativeMax_SigComplete                               % Max of 1st derivative of complete signal
    %         .FirstDerivative_Moment2nd_SigComplete                        % 2nd order moment of 1st derivative
    %         .FirstDerivative_Moment3rd_SigComplete                        % 3rd order moment of 1st derivative
    %         .FirstDerivative_Kurtosis_SigComplete                         % kurtosis of 1st derivative
    %         .FirstDerivative_Skweness_SigComplete                         % skweness of 1st derivative
    %         .FirstDerivativeRatio_SigComplete                             % Normalized Ratio with logarithmic transformation of 1st derivative of complete signal
    %         .FirstDerivativeRange_SigComplete                             % Range of st derivative of complete signal
    %         .FirstDerivativeMin_SigComplete                               % Min of 1st derivative of complete signal
    %         .FirstDerivativeRMS_SigComplete                               % RMS of 1st derivative of complete signal
    %         .FirstDerivativeLogRatio_SigComplete                          % normalized Ratio with logarithmic transformation of 1st derivative of complete signal
    
    % REMARKS:
    % *** Comments located on the right side, based on Chris Buckley's PhD thesis
    % *** Author: Encarna Micó Amigo, Contact: Maria.Mico-Amigo@newcastle.ac.uk / encarna.mico@gmail.com
    %             Chris Buckley, Contact: Christopher.Buckley2@newcastle.ac.uk
    
    % HISTORY:
    % 2019/6th/September functionized - Encarna Micó Amigo
    % 2020/27th/February adapted for Beat PD challenge - Encarna Micó Amigo
end


%% [1] RMS - DERIVATIVE - COMBINATION

NameChannels = {'VT','ML','AP','Magnitude'};
for iChannel = 1:size(Signal_Detr_LPFilt,2)
    SigChannel = Signal_Detr_LPFilt(:,iChannel);
    FEATURES.(['Median_SigComplete_' NameChannels{iChannel}]) = median(SigChannel); %[Patel, Lonini]
    FEATURES.(['Range_SigComplete_' NameChannels{iChannel}]) = max(SigChannel) - min(SigChannel); %[Patel, Lonini] Changed from using range func by LJ
    FEATURES.(['RMS_SigComplete_' NameChannels{iChannel}]) = real(real(rms(SigChannel)));
    FEATURES.(['RMSratio_SigComplete_' NameChannels{iChannel}]) = real(rms(SigChannel)./rms(Signal_Detr_LPFilt(:,4)));
    FirstDerivative = real(diff(SigChannel)*Settings.Fs); %jerk"
    FEATURES.(['FirstDerivativeMean_SigComplete_' NameChannels{iChannel}]) = mean(FirstDerivative); %jerk"
    FEATURES.(['FirstDerivativeMax_SigComplete_' NameChannels{iChannel}]) = max(FirstDerivative); %jerk"
    FEATURES.(['FirstDerivative_Moment2nd_SigComplete_' NameChannels{iChannel}]) = moment(FirstDerivative,2); 
    FEATURES.(['FirstDerivative_Moment3rd_SigComplete_' NameChannels{iChannel}]) = moment(FirstDerivative,3); 
    FEATURES.(['FirstDerivative_Kurtosis_SigComplete_' NameChannels{iChannel}]) = kurtosis(FirstDerivative); 
    FEATURES.(['FirstDerivative_Skweness_SigComplete_' NameChannels{iChannel}]) = skewness(FirstDerivative);
    FEATURES.(['FirstDerivativeRatio_SigComplete_' NameChannels{iChannel}]) = real(mean((diff(SigChannel)*Settings.Fs)./(diff(Signal_Detr_LPFilt(:,4))*Settings.Fs)));
    FEATURES.(['FirstDerivativeRange_SigComplete_' NameChannels{iChannel}]) = real(range(diff(SigChannel)*Settings.Fs));
    FEATURES.(['FirstDerivativeMin_SigComplete_' NameChannels{iChannel}]) = real(min(diff(SigChannel)*Settings.Fs));
    FEATURES.(['FirstDerivativeRMS_SigComplete_' NameChannels{iChannel}]) = real(rms(diff(SigChannel)*Settings.Fs));
    FEATURES.(['FirstDerivativeLogRatio_SigComplete_' NameChannels{iChannel}]) = real(mean(10*log10((diff(SigChannel)*Settings.Fs)./(diff(Signal_Detr_LPFilt(:,1))*Settings.Fs))));
end

