function AutocorrelationFeatures = extract_Regularity_Acc___NonMobiliseD(Acc,Settings)
%function AutocorrelationFeatures = extract_Regularity_Acc___NonMobiliseD(Acc,Settings)

%% Calculation of Regularity measures based on Autocorrelation signal - ACCELEROMETRY (VT and AP)
% * Ref 1) % According to: "Moe-Nilssen, Rolf, and Jorunn L. Helbostad.
% "Estimation of gait cycle characteristics by trunk accelerometry."
% Journal of biomechanics 37, no. 1 (2004): 121-126."
% * Ref 2) Authors: Rispens SM, van Schooten KS, Pijnappels M, Daffertshofer A, Beek PJ, van Dieën JH.
% "Identification of Fall Risk Predictors in Daily Life Measurements"
% Neurorehabil Neural Repair. 2015 Jan;29(1):54-61
%

%% INPUTS
% Acc: Acceleration signal (VT, ML, AP)
% fs: sampling frequency
% Settings:
%          - Fc_LowPassFilter = 20*fs/100;                                  % cut-off frequency used for low-pass filters: frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz
%          - Fc_HighPassFilter = 0.1*fs/100;                                % cut-off frequency used for high-pass filters: frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz
%          - Fc_HighPassFilter_AutoCorr = 0.8*fs/100;                       % cut-off frequency used for high-pass filters for autocorrelation unbiased: : frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz

%% OUTPUTS
% AutocorrelationFeatures.
%         - StepRegularity = AmplitudeAutocorr_Step;            
%         - StrideRegularity = AmplitudeAutocorr_Stride;        
%         - Symmetry_AutocorrelationRatio = Symmetry_RatioAd1Ad2;
%         - Symmetry_AutocorrelationDiff = Symmetry_DiffAd1Ad2;
%         - fs = 100 Hz; (sampling frequency)

%% Remarks
% *** Comments located on the right side, based on Vrije Universiteit algorithm (original author: Sietse Rispens)
% *** Author: Encarna Micó Amigo, Contact: Maria.Mico-Amigo@newcastle.ac.uk / encarna.mico@gmail.com

%% History
% 2019/3rd/October functionized - Encarna Micó Amigo


%% SETTINGS
if nargin < 3                                                             % if the settings are not predefined:
    Settings.fs = 100;
    fs = Settings.fs;
    Settings.Fc_LowPassFilter = 20*fs/100;                                  % cut-off frequency used for low-pass filters: frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz
    Settings.Fc_HighPassFilter = 0.1*fs/100;                                % cut-off frequency used for high-pass filters: frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz
    Settings.Fc_HighPassFilter_AutoCorr = 0.8*fs/100;                       % cut-off frequency used for high-pass filters for autocorrelation unbiased: : frequencies scale according to the sampling rate, so it must be scaled by 1.28, since most of the Fc are defined in the literature for a Fs of 100 Hz
end

%% CALCULATION OF AUTOCORRELATION-BASED FEATURES
Acc(:,4) = sqrt(sum(Acc(:,1:3)'.^2)');                                      % Resultant or combined signal
NameChannels = {'VT','ML','AP','Combined'};

% Initialization
StepRegularity = [];
StrideRegularity = [];
Symmetry_AutocorrelationRatio = [];
Symmetry_AutocorrelationDiff = [];

% Stride time and regularity from auto correlation
[Autocorr4x4,Lags] = xcov(Acc,'unbiased');                                  % auto-covariance of Moe-Nilssen. Consider also to use xcorr instead: The functions xcorr and xcov estimate the cross-correlation and cross-covariance sequences of random processes. The xcov function estimates autocovariance and cross-covariance sequences. This function has the same options and evaluates the same sum as xcorr, but first removes the means of x and y. "Unbiased": non-attenuated signal
Autocorr4x4 = Autocorr4x4(Lags >= 0,[1 6 11 16]);                           % we get positive lags signal (Lags>=0), we select channels 1, 6, 11 and 16 because the function has as an output the correlation of each of the signals with each of the signals, thus, to get the "auto"correlation, we select particular axes of the final matrix
AutocorrSum = sum(Autocorr4x4(:,1:3),2);                                    % this sum is independent of sensor re-orientation, as long as axes are kept orthogonal. Notice that this is different from the autocorrelation of the resultant/combined signal (4th channel of Autocorr4x4)
AutocorrAll_ = [Autocorr4x4,AutocorrSum];

% Window of average step (based on VT acceleration)                         % we defined a window, which will help us focusing on a section of the signal to refine peaks finding
autoCov_half = Autocorr4x4(:,1);                                            % we only select the VT autocorrelation to define the window
autoCov_half_Detr = detrend(autoCov_half);
autoCov_half_Detr_HPFilt = HPFilter(autoCov_half_Detr,fs,Settings.Fc_HighPassFilter_AutoCorr,2);
L = size(autoCov_half_Detr_HPFilt,1);                                       % length of signal
NFFT = 2^nextpow2(L);                                                       % next power of 2 from length of signal
Y = fft(autoCov_half_Detr_HPFilt,NFFT)/L;                                   % Fourier Transform
f = fs/2*linspace(0,1,NFFT/2+1); warning('off');                            % frequencies of the signal
Power_Spectrum = 2*abs(Y(1:NFFT/2+1));                                      % single-Sided Amplitude Spectrum
[~, Index_Dominantfrequency] = max(Power_Spectrum);                         % max value of Power Spectrum corresponding to the dominant frequency and index
Dominantfrequency = f(Index_Dominantfrequency);                             % we identify dominant frequency, to know the main period of the signal
Window = round((1/Dominantfrequency)*fs);                                   % window size will be based on the dominant cycle (step frequency)

% Step & Stride Cycles
RangeStep_Low = ceil(Window*0.5);                                           % we set the lowest range (x-axes) from which we will look for the peak of step
RangeStep_High = ceil(Window*1.5);                                          % we set the highest range (x-axes) within which we will look for peak of step / this will be the lowest range to look for stride peak
RangeStride_High = ceil(Window*2.5);                                        % we set the highest range (x-axes) within which we will look for peak of sride

for iChannel = 1:size(AutocorrAll_,2)-1                                     % we only set our loop for 4 axes: VT, ML, AP and resultant (here, we do not look at the sum of the other 3 autocorrelations)
    AutocorrNorm = AutocorrAll_(:,iChannel)./AutocorrAll_(1,iChannel);      % we normalize the signal to the value at lag = 0 (which supposes to correspond to the maximal similarity of the signal with itself)
    if iChannel == 2 %ML
        [AmplitudeAutocorr_Step_,Index_StepTimeAutocorr] = min(AutocorrNorm(RangeStep_Low:RangeStep_High,1));
        AmplitudeAutocorr_Step(:,iChannel) = abs(AmplitudeAutocorr_Step_);
        [AmplitudeAutocorr_Stride(:,iChannel),Index_StrideTimeAutocorr] = max(AutocorrNorm(RangeStep_High:RangeStride_High,1));
    else %VT, AP, Resultant
        [AmplitudeAutocorr_Step(:,iChannel),Index_StepTimeAutocorr] = max(AutocorrNorm(RangeStep_Low:RangeStep_High,1));
        [AmplitudeAutocorr_Stride(:,iChannel),Index_StrideTimeAutocorr] = max(AutocorrNorm(RangeStep_High:RangeStride_High,1));
    end
    StepTimeSamples(:,iChannel) = Index_StepTimeAutocorr + RangeStep_Low-1;
    StrideTimeSamples(:,iChannel) = Index_StrideTimeAutocorr + RangeStep_High-1;
    if iChannel == 2 %ML
        AutocorrNorm(AutocorrNorm <= 0) = AutocorrNorm(AutocorrNorm <= 0).*-1; % we transform negative part of signal into positive, so the inverted peak corresponding to the step, would give us an absolute value, to calcuate the ratio
    else %VT, AP, Resultant
        Offset = 5;                                                         % offset should be constant among subjects, to be able to compare between them
        AutocorrNorm = AutocorrNorm + Offset;                               % we added an offset, to have all peaks in positive values, so the final ratio would not be biased by the initial sign of the peaks
    end
    Ad1 = AutocorrNorm(StepTimeSamples(:,iChannel),1);
    Ad2 = AutocorrNorm(StrideTimeSamples(:,iChannel),1);
    Symmetry_RatioAd1Ad2(:,iChannel) = Ad1/Ad2;                             % we calculate the ratio between the amplitude of the peaks (step/stride)
    Symmetry_DiffAd1Ad2(:,iChannel) = abs(Ad2-Ad1);                         % we calculate the absolute difference between the amplitude of the peaks (step-stride)
end

%% OUTPUTS

AutocorrelationFeatures.StepRegularity = AmplitudeAutocorr_Step;            
AutocorrelationFeatures.StrideRegularity = AmplitudeAutocorr_Stride;        
AutocorrelationFeatures.Symmetry_AutocorrelationRatio = Symmetry_RatioAd1Ad2;
AutocorrelationFeatures.Symmetry_AutocorrelationDiff = Symmetry_DiffAd1Ad2;



