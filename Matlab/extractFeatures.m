function FEATURES = extractFeatures(RawSignalOriginal,ProtocolName,ProtocolCode,Settings,PlotSettings)
% function FEATURES = extractFeatures(RawSignalOriginal,ProtocolName,ProtocolCode,Settings,PlotSettings)
% FEATURES = extractFeatures_BeatPD(Signal,Settings,PlotSettings)



%% FUNCTION INFO
for Close_FunctionInfo = 1
    % INPUTS:
    % 1) Signal: contains the available data following fields:
    % Signal(:,1) = TimeStamp
    % Signal(:,2) = VT direction of recorded signal
    % Signal(:,3) = ML direction of recorded signal
    % Signal(:,4) = AP direction of recorded signal
    % 2) Settings for frequency analysis
    % Settings.Fs = XXX; sampling frequency [Hz]
    % Settings.N_Harm = 20;                                                 % number of harmonics used for harmonic ratio, index of harmonicity and phase fluctuation
    % Settings.MaxRangeFrequencyPSD = 10*Fs/100;                            % maximal range of frequencies to find frequency of the peak power spectral density (PSD)
    % Settings.MinRangeFrequencyPSD = 0.3*Fs/100;                           % miniaml range of frequencies to find frequency of the peak power spectral density (PSD)
    % Settings.MinNumStrides_Complex = 7;                                   % minimal number of strides in the signal
    % 3) PlotSettings
    % PlotSettings.PhaseFeatures = 0;                                       % activate plots to help understangind the development of the phase analysis algorithms
    % PlotSettings.SpectralFatures = 0;                                     % activate plots to help understangind the calculation of power spectral density of signals
    % 4) WalkingBout (info)
    % WalkingBout.start
    % WalkingBout.end

    % OUTPUTS:
    % FEATURES: properties extracted from the signal

    % REMARKS:
    % *** Comments on the right side
    % *** Author: Encarna Mic� Amigo, based on several algorithms.
    % Original authors: Encarna Mic� Amigo, Chirs Buckley, Michael Dunne-Willows, Silvia Del Din and Sietse Rispens (Vrije Universiteit Amsterdam)
    % Contact: Maria.Mico-Amigo@newcastle.ac.uk / encarna.mico@gmail.com

    % HISTORY
    % 2019/6th/September functionized - Encarna Mic� Amigo
    % 2020/27th/February adapted for Beat PD challenge - Encarna Mic� Amigo
    % 2024/2nd/March adapted for tremor detection - Encarna Mic� Amigo (Heriot-Watt University)
    clear Close_FunctionInfo
end



%% [0] FILTER SIGNAL
if Settings.analyseBinaryTremor
    if strcmp(ProtocolName,'NonTremor')
        RawSignal = RawSignalOriginal(RawSignalOriginal(:,6) < 3,1:3);
    else
        RawSignal = RawSignalOriginal(RawSignalOriginal(:,6) > 2,1:3);
    end
else
    RawSignal = RawSignalOriginal(RawSignalOriginal(:,6) == ProtocolCode,1:3);
end
RawSignal(:,4) = sqrt(abs(sum(RawSignal(:,1:3)'.^2)'));                     % resultant or combined signal: magnitude
Signal_Detr = detrend(RawSignal);



Signal_Detr_LPFilt = WintFilt_low(Signal_Detr, Settings.Fc_LowPassFilter, Settings.Fs);


%% [1] FEATURES EXTRACTION
FEATURES = struct;
% Regularity - Autocorrelation - Gait?
FEATURES = extract_Regularity(Signal_Detr_LPFilt,Settings,FEATURES);
% Spectral Features - Gait?
FEATURES = extract_ContentSpectralPowerDensity(Signal_Detr_LPFilt(:,1:3),Settings,PlotSettings,FEATURES);
% RMS - Jerk - derivates - General?
FEATURES = extract_RMS_FirstDerivative(Signal_Detr_LPFilt,Settings,FEATURES);
% Combination of article features -General?
FEATURES = extract_CombinationFeaturesArticles(Signal_Detr_LPFilt,Settings,FEATURES);


%% [2] ...TO DO

% % Complex features
% FEATURES = extract_Complex(Signal_Detr_LPFilt,Settings,FEATURES);

% % Wavelet calculation from signals
% FEATURES = extract_WaveletTransformation(Signal,Settings,PlotSettings,ActivityBout,FEATURES);

% % Phase features
% [WB_SDMO] = extract_PhaseFeatures_Acc(imu,fs,WB_WBD,WB_SDMO,Settings,PlotSettings);
% [WB_SDMO] = extract_PhaseFeatures_Gyro(imu,fs,WB_WBD,WB_SDMO,Settings,PlotSettings);


%% TO DO ---> WITH DOMINANT CYCLE EXTRACTION

% % Lyapunov exponent
% FEATURES = extract_LyapunovExponent_Acc(Signal,Settings.Fs,ActivityBout,Features,Settings,PlotSettings);
% FEATURES = extract_LyapunovExponent_Gyro(Signal,Settings.Fs,ActivityBout,Features,Settings,PlotSettings);
