function AutocorrelationFeatures_Zhang = extract_Regularity_GaitSymmetryIndex_Acc___NonMobiliseD(Acc,Settings)
%function AutocorrelationFeatures_Zhang = extract_Regularity_GaitSymmetryIndex_Acc___NonMobiliseD(Acc,Settings)

%% Calculation of Regularity measures based on Autocorrelation signal - ACCELEROMETRY (VT and AP)
% * Ref 1) "Gait Symmetry Assessment with a Low Back 3D Accelerometer in Post-Stroke Patients"
% Authors: Zhang W1, Smuck M2,3, Legault C4, Ith MA5,6, Muaremi A7, Aminian K8.
% 2019, Journal "Sensors". https://www.ncbi.nlm.nih.gov/pubmed/30282947
%

%% INPUTS
% Acc: Acceleration signal (VT, ML, AP)
% fs: sampling frequency
% Settings:
%          - Fc_LowPassFilter = 20*fs/100;                                  % cut-off frequency used for low-pass filters: frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz
%          - Fc_HighPassFilter = 0.1*fs/100;                                % cut-off frequency used for high-pass filters: frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz
%          - Fc_HighPassFilter_AutoCorr = 0.8*fs/100;                       % cut-off frequency used for high-pass filters for autocorrelation unbiased: : frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz

%% OUTPUTS
% AutocorrelationFeatures_Zhang.
%         - GaitSymmetryIndex_Autocorr = gait symmetry index (as established in the paper);

%% Remarks
% *** Comments located on the right side
% *** Author: Encarna Micó Amigo & Chris Buckley, Contact: Maria.Mico-Amigo@newcastle.ac.uk / Christopher.Buckley2@newcastle.ac.uk

%% History
% 2019/3rd/October functionized - Encarna Micó Amigo & Chris Buckley


%% SETTINGS
if nargin < 3                                                               % if the settings are not predefined:
    Settings.fs = 100;
    fs = Settings.fs;
    Settings.Fc_LowPassFilter = 20*fs/100;                                  % cut-off frequency used for low-pass filters: frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz
    Settings.Fc_HighPassFilter = 0.1*fs/100;                                % cut-off frequency used for high-pass filters: frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz
    Settings.Fc_HighPassFilter_AutoCorr = 0.8*fs/100;                       % cut-off frequency used for high-pass filters for autocorrelation unbiased: : frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz
end

%% CALCULATION OF AUTOCORRELATION-BASED FEATURES
Acc(:,4) = sqrt(sum(Acc(:,1:3)'.^2)');                                      % Resultant or combined signal

% Initialization
GaitSymmetryIndex_Autocorr = [];

% Stride time and regularity from auto correlation
[Autocorr4x4,Lags] = xcov(Acc,'biased');                                    % auto-covariance of Moe-Nilssen. "Biased": attenuated signal
Autocorr4x4 = Autocorr4x4(Lags >= 0,[1 6 11 16]);                           % we get positive lags signal (Lags>=0), we select channels 1, 6, 11 and 16 because the function has as an output the correlation of each of the signals with each of the signals, thus, to get the "auto"correlation, we select particular axes of the final matrix
Autocorr4x4_Norm = Autocorr4x4./Autocorr4x4(1,:);
% Set the size of the signals, take up to the first 400 samples
if size(Autocorr4x4_Norm,1) < 400                                           % 400: maximal range of signal (according to the paper)
    Range = 1:size(Autocorr4x4_Norm,1);
else
    Range = 1:400;
end

% All negative part of the signal should be 0
Autocorr4x4_1stSection = Autocorr4x4_Norm(Range,:);
Autocorr4x4_1stSection(Autocorr4x4_1stSection < 0) = 0;

% Get signals based on axes
AutocorrSum = sum(Autocorr4x4_1stSection(:,1:3),2); %Cstride    % sum the first axes-signals of autocorrelation
AutocorrSquared = sqrt(sum(Autocorr4x4_1stSection(:,1:3),2)); %Cstep   % square of the sum

% Identify the samples at which there is the maximas over signals
[TStrideValue, TStrideSample] = max(AutocorrSum(10:end,1));     % we search 10 samples later, to avoid getting the first peak at lag = 0
TStride = TStrideSample +10-1;
GaitSymmetryIndex_Autocorr = AutocorrSquared(ceil(0.5*TStride),1)./sqrt(3);


%% OUTPUTS

AutocorrelationFeatures_Zhang.GaitSymmetryIndex_Autocorr = GaitSymmetryIndex_Autocorr;


