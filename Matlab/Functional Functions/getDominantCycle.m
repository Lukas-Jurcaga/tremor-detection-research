function [DominantCycle] = getDominantCycle(signal,Fs,Fc_HighPassFilter_AutoCorr)
% function [DominantCycle] = getDominantCycle(signal,Fs,Fc_HighPassFilter_AutoCorr)
%
% OUTPUTS
% - DominantCycle   .DominantFrequency 
%                   .DominantCycle_Samples
%
% Author's Name: Encarna Micó Amigo
% Contact: Maria.Mico-Amigo@newcastle.ac.uk / encarna.mico@gmail.com
% Objective: Determine the dominant cycle of a non-stationary (e.g. periodic) signal
%
% GENERAL DESCRIPTION
% Calculate autocorrelation signal, and from it, extract dominant cycle
%
% INPUT
% - signal = periodic signal, presenting several cycles
% - Fs = sampling frequency
% - Fc_HighPassFilter_AutoCorr = frequency cut for a high pass filter of the autocorrelation signal
%
% HISTORY
% 2013/1st/May functionized
% 2016/17th/Feb restructured
% 2019/10-12th/Sep edited

%% 1. Calculate autocorrelation signal
autoCovUnbiased = xcov(signal,'unbiased');                                  % autocorrelation of the signals (evaluation of periodicity)--> function xcov unbiased, for a non attenuate signal.
autoCovUnbiased_Positive = autoCovUnbiased(round(size(autoCovUnbiased,1)/2)-10:end,1); % second part of a signal: positive lag. Because autocorrelation is calculated from the shift of the signal to the right and to the left. (Symetrical signal) we take only lag >= 0.
[p,~,mu] = polyfit((1:numel(autoCovUnbiased_Positive))',autoCovUnbiased_Positive,6); % we calculate the trend of signal
f_y = polyval(p,(1:numel(autoCovUnbiased_Positive))',[],mu);                % fit of trend
autoCovUnbiased_Positive_Detr = detrend(autoCovUnbiased_Positive - f_y);    % we remove the trend, non-linear trend, to get a detrended signal
autoCovUnbiased_Positive_Detr_HPFilt = HPFilter(autoCovUnbiased_Positive_Detr,Fs,Fc_HighPassFilter_AutoCorr,2); % High-Pass filtration (to remove the lowest frequencies from the pattern of autocorrelation)
autoCov = autoCovUnbiased_Positive_Detr_HPFilt;                             % we simplify the name
%% 2. Get Fourier Fast Transform from autocorrelation signal                % find frequency components from autocorrelation signal
L = size(autoCov,1);                                                        % length of signal
NFFT = 2^nextpow2(L);                                                       % next power of 2 from length of signal
Y = fft(autoCov,NFFT)/L;                                                    % Fourier Transform
f = Fs/2*linspace(0,1,NFFT/2+1);                                            % frequencies of the signal
Power_Spectrum = 2*abs(Y(1:NFFT/2+1));                                      % single-Sided Amplitude Spectrum
[~, Index_PS_Dominant_frequency] = max(Power_Spectrum);                     % max value of Power Spectrum corresponding to the dominant frequency and index
DominantFrequency = f(Index_PS_Dominant_frequency);                         % define the dominant frequency

%% 3. Define the size (in samples) of the dominant cycle
DominantCycle_Samples = round((1/DominantFrequency)*Fs);                    % define the size in samples of the dominant cycle

%% OUTPUTS
DominantCycle.DominantFrequency = DominantFrequency;
DominantCycle.DominantCycle_Samples = DominantCycle_Samples;