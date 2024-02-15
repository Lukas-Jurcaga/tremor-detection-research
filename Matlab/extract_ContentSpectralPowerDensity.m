function FEATURES = extract_ContentSpectralPowerDensity(Signal_Detr_LPFilt,Settings,PlotSettings,FEATURES)
%FEATURES = extract_ContentSpectralPowerDensity(Signal_Detr_LPFilt,Settings,PlotSettings,FEATURES)


%% FUNCTION INFO
for Close_Function_Info = 1
    
    % EXPLANATION:
    % * Ref 1) Authors: Weiss A1, Sharifi S, Plotnik M, van Vugt JP, Giladi N, Hausdorff JM.
    % "Toward automated, at-home assessment of mobility among patients with Parkinson disease, using a body-worn accelerometer."
    % Neurorehabil Neural Repair. 2011 Nov-Dec;25(9):810-8
    % * Ref 2) Authors: Rispens SM, van Schooten KS, Pijnappels M, Daffertshofer A, Beek PJ, van Dieën JH.
    % "Identification of Fall Risk Predictors in Daily Life Measurements"
    % Neurorehabil Neural Repair. 2015 Jan;29(1):54-61
    
    % INPUTS: (the same as previous function)
    % 1) Signal: contains the available data following fields:
    % Signal(:,1) = TimeStamp
    % Signal(:,2) = VT direction of recorded signal
    % Signal(:,3) = ML direction of recorded signal
    % Signal(:,4) = AP direction of recorded signal
    % 2) Settings for frequency analysis
    % Settings.Fs                                                           % sampling frequency
    % Settings.Fc_LowPassFilter = 20*Fs/100;                                % cut-off frequency used for low-pass filters: frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz
    % Settings.N_Harm = 20;                                                 % number of harmonics used for harmonic ratio, index of harmonicity and phase fluctuation
    % Settings.MaxRangeFrequencyPSD = 10*(Settings.Fs)/100;                 % maximal range of frequencies to find frequency of the peak power spectral density (PSD)
    % Settings.MinRangeFrequencyPSD = 0.3*(Settings.Fs)/100;                % miniaml range of frequencies to find frequency of the peak power spectral density (PSD)
    % Settings.HanningWindow_Size = 500; %[samples = /100s]                 % samples of Hanning Window used to extract spectral component
    % 3) PlotSettings
    % PlotSettings.SpectralFatures = 0;                                     % activate plots to help understangind the calculation of power spectral density of signals
    % 4) WalkingBout (info)
    % WalkingBout.start                                                     % start of each walking bout (size = number of walking bouts)
    % WalkingBout.end                                                       % end of each walking bout (size = number of walking bouts)
    
    % OUTPUTS:
    % FEATURES.DominantFreq.(NameChannels{iChannel}){iJunkSize}           % a combination of all extracted spectral features
    % Extracted features:DominantFreq,Amplitude,AmplitudeNorm,Width,Slope,Range,MeanPower,MedianPower,MeanFreq,MedianFreq,WidthNorm,SlopeNorm,RangeNorm,IntegratedPower,HarmonicRatio,IndexHarmonicity
    
    % REMARKS:
    % *** Comments located on the right side
    % *** Author: Encarna Micó Amigo, based on Vrije Universiteit Amsterdam algorithm (original author: Sietse Rispens)
    % Contact: Maria.Mico-Amigo@newcastle.ac.uk / encarna.mico@gmail.com
    
    % HISTORY:
    % 2019/6th/September functionized - Encarna Micó Amigo
    % 2020/27th/February adapted for Beat PD challenge - Encarna Micó Amigo
end


%% SPECTRAL ANALYSIS OVER FULL PROVIDED SIGNAL USING HANNING WINDOWING
HanningWindow_Size = Settings.HanningWindow_Size;
Nfft = HanningWindow_Size*10;
HanningWindow = hanning(floor(HanningWindow_Size));
DominantFreq = [FEATURES.DominantFreq_VT FEATURES.DominantFreq_ML FEATURES.DominantFreq_AP];
FreqWindow = [min(DominantFreq) max(DominantFreq)];
SpectralFeatures_Signal = getFrequencyAnalysis(Signal_Detr_LPFilt,Settings.Fs,Nfft,Settings.N_Harm,Settings,HanningWindow_Size,FreqWindow,PlotSettings);
FeaturesName = fieldnames(SpectralFeatures_Signal);
FeaturesNumMax = size(FeaturesName,1);
NameChannels = {'VT','ML','AP','Magnitude'};

for iFeature = 1:FeaturesNumMax    
    for iChannel = 1:size(SpectralFeatures_Signal.(FeaturesName{iFeature}),2)
        FEATURES.([FeaturesName{iFeature} '_' NameChannels{iChannel}]) = SpectralFeatures_Signal.(FeaturesName{iFeature})(iChannel);
    end
end

