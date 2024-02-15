function FEATURES = extract_Regularity(Signal_Detr_LPFilt,Settings,FEATURES)
%FEATURES = extract_Regularity(Signal_Detr_LPFilt,iJunk,iBout,Settings,FEATURES)


%% FUNCTION INFO
for Close_Function_Info = 1
    
    % EXPLANATION:
    % Calculation of Regularity measures based on Autocorrelation signal - ACCELEROMETRY (VT and AP), originally estimated for low-back accelerometry
    % * Ref 1) % According to: "Moe-Nilssen, Rolf, and Jorunn L. Helbostad.
    % "Estimation of gait cycle characteristics by trunk accelerometry."
    % Journal of biomechanics 37, no. 1 (2004): 121-126."
    % * Ref 2) Authors: Rispens SM, van Schooten KS, Pijnappels M, Daffertshofer A, Beek PJ, van Dieën JH.
    % "Identification of Fall Risk Predictors in Daily Life Measurements"
    % Neurorehabil Neural Repair. 2015 Jan;29(1):54-61
    % Calculation of Regularity measures based on Autocorrelation signal - ACCELEROMETRY (VT and AP)
    % * Ref 3) "Gait Symmetry Assessment with a Low Back 3D Accelerometer in Post-Stroke Patients"
    % Authors: Zhang W1, Smuck M2,3, Legault C4, Ith MA5,6, Muaremi A7, Aminian K8.
    % 2019, Journal "Sensors". https://www.ncbi.nlm.nih.gov/pubmed/30282947
    
    % INPUTS: (the same as previous function)
    % 1) Signal_Detr_LPFilt: contains the available data following fields:
    % Signal_Detr_LPFilt(:,1) = TimeStamp
    % Signal_Detr_LPFilt(:,2) = VT direction of recorded signal
    % Signal_Detr_LPFilt(:,3) = ML direction of recorded signal
    % Signal_Detr_LPFilt(:,4) = AP direction of recorded signal
    % 2) Settings for frequency analysis
    % Settings.Fs                                                           % sampling frequency
    % Settings.Fc_LowPassFilter = 20*Fs/100;                                % cut-off frequency used for low-pass filters: frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz
    % Settings.Fc_HighPassFilter_AutoCorr = 0.8*Fs/100;                     % cut-off frequency used for high-pass filters for autocorrelation unbiased: : frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz
    
    % OUTPUTS:
    % FEATURES.DominantCycle_Autocorr.(NameChannels{iChannel}){iJunkSize}   % dominant cycle of autocorrelation signals
    %         .AmplitudeAutocorr_Step                                       % regularity of steps based on autocorrelation signal;
    %         .AmplitudeAutocorr_Stride                                     % regularity of strides based on autocorrelation signal;
    %         .Symmetry_RatioAd1Ad2                                         % asymmetry of step-stride (ratio) based on autocorrelation signal;
    %         .Symmetry_DiffAd1Ad2                                          % asymmetry of step-stride (difference) based on autocorrelation signal;
    %         .CorssCorrelationSum_VTML / _VTAP / _MLAP                     % cross-correlation between different directional signals: sumatory of absolute value
    %         .CorssCorrelationPeak_VTML / _VTAP / _MLAP                    % cross-correlation between different directional signals: peak        
    %         .DominantCycle_VTML / _VTAP / _MLAP                           % cross-correlation between different directional signals: dominant cycle   
    
    % REMARKS:
    % *** Comments located on the right side
    % *** Author: Encarna Micó Amigo, Contact: Maria.Mico-Amigo@newcastle.ac.uk / encarna.mico@gmail.com
    %             Chris Buckley, Contact: Christopher.Buckley2@newcastle.ac.uk
    
    % HISTORY:
    % 2019/6th/September functionized - Encarna Micó Amigo
    % 2020/27th/February adapted for Beat PD challenge - Encarna Micó Amigo
end


%% [1] DOMINANT CYCLE AUTOCORRELATION
NameChannels = {'VT','ML','AP','Magnitude'};
Channels_Size = size(Signal_Detr_LPFilt,2);
for iChannel = 1:Channels_Size
    DominantCycleInfo = getDominantCycle(Signal_Detr_LPFilt(:,iChannel),Settings.Fs,Settings.Fc_HighPassFilter_AutoCorr);
    FEATURES.(['DominantFreq' '_' NameChannels{iChannel}]) = DominantCycleInfo.DominantFrequency;
end
clear iChannel Channels_Size
    

%% [2] PURE CORRELATION - AUTOCORRELATION                                   % [Lonini, Palmerini]

SigVT = Signal_Detr_LPFilt(:,1);
SigML = Signal_Detr_LPFilt(:,2);
SigAP = Signal_Detr_LPFilt(:,3);
Corr_VTML = xcorr(SigVT,SigML);
Corr_VTAP = xcorr(SigVT,SigAP);
Corr_MLAP = xcorr(SigML,SigAP);

% Cross-correlation sum (XY,XZ,YZ)	
FEATURES.CorssCorrelationSum_VTML = sum(abs(Corr_VTML));
FEATURES.CorssCorrelationSum_VTAP = sum(abs(Corr_VTAP));
FEATURES.CorssCorrelationSum_MLAP = sum(abs(Corr_MLAP));

% Cross-correlation peak (XY,XZ,YZ)
[FEATURES.CorssCorrelationPeak_VTML,FEATURES.CorssCorrelationLag_VTML] = max(Corr_VTML);
[FEATURES.CorssCorrelationPeak_VTAP,FEATURES.CorssCorrelationLag_VTAP] = max(Corr_VTAP);
[FEATURES.CorssCorrelationPeak_MLAP,FEATURES.CorssCorrelationLag_MLAP] = max(Corr_MLAP);

% Dominant Cycle of Cross-correlations
DomCycle_VTML = getDominantCycle(Corr_VTML,Settings.Fs,Settings.Fc_HighPassFilter_AutoCorr);
DomCycle_VTAP = getDominantCycle(Corr_VTAP,Settings.Fs,Settings.Fc_HighPassFilter_AutoCorr);
DomCycle_MLAP = getDominantCycle(Corr_MLAP,Settings.Fs,Settings.Fc_HighPassFilter_AutoCorr);

[FEATURES.DominantFreq_CorrVTML] = DomCycle_VTML.DominantFrequency;
[FEATURES.DominantFreq_CorrVTAP] = DomCycle_VTAP.DominantFrequency; 
[FEATURES.DominantFreq_CorrMLAP] = DomCycle_MLAP.DominantFrequency;    

