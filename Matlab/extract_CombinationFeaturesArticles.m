function FEATURES = extract_CombinationFeaturesArticles(Signal_Detr_LPFilt,Settings,FEATURES)
%FEATURES = extract_CombinationFeaturesArticles(Signal_Detr_LPFilt,Settings,iBout,iJunk,FEATURES)

%% FUNCTION INFO
for Close_Function_Info = 1
    
    % EXPLANATION:
    % *** Calculation of basic features of signal: MEAN - STD - MAX -
    % MEDIAN - SKEWNESS - KURTOSIS - INTERQUARTILE RANGE - PERCENTILE OF SIGN BELOW PERCENTILE (25,75) - SQUARE SUM OF SIGNAL BELOW PERCENTILE (25,75) - SPECTRUM BELOW 5 HZ (SUM - MAX FREQ - NUM PEAKS)
    % *** Other features proposed by:
    % Lonini. 2018. Wearable sensors for Parkinson�s disease which data are worth collecting for training symptom detection models
    % Sejdic. 2014. A comprehensive assessment of gait accelerometry signals in time, frequency and time-frequency domains
    % Arora.  2015. Detecting and monitoring the symptoms of Parkinson's disease using smartphones: A pilot study
    % Barth.  2011. Biometric and mobile gait analysis for early diagnosis and therapy monitoring in Parkinson's disease
    
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
    % FEATURES.(all list of features)
        
    % REMARKS:
    % *** Comments located on the right side, based on Chris Buckley's PhD thesis
    % *** Author: Encarna Mic� Amigo, Contact: Maria.Mico-Amigo@newcastle.ac.uk / encarna.mico@gmail.com
    %             Alma Cantu
    
    % HISTORY:
    % 2019/6th/September functionized - Encarna Mic� Amigo
    % 2020/7th/May adapted for Beat PD challenge - Encarna Mic� Amigo
end


%% [1] MEAN - STD - MAX - MEDIAN - SKEWNESS - KURTOSIS - INTERQUARTILE RANGE - PERCENTILES (25,75) - SUM - SPECTRUM BELOW 5Hz (SUM, MAX FREQ, PEAKS)

NameChannels = {'VT','ML','AP','Magnitude'};
for iChannel = 1:size(Signal_Detr_LPFilt,2)
    SigChannel = Signal_Detr_LPFilt(:,iChannel);
    FEATURES.(['Mean_SigComplete_' NameChannels{iChannel}]) = mean(SigChannel);
    FEATURES.(['Std_SigComplete_' NameChannels{iChannel}]) = std(SigChannel);
    FEATURES.(['Max_SigComplete_' NameChannels{iChannel}]) = max(SigChannel); 
    FEATURES.(['Median_SigComplete_' NameChannels{iChannel}]) = median(SigChannel);
    FEATURES.(['Skewness_SigComplete_' NameChannels{iChannel}]) = skewness(SigChannel); %[Sejdic, Lonini]
    FEATURES.(['Kurtosis_SigComplete_' NameChannels{iChannel}]) = kurtosis(SigChannel); %[Sejdic, Lonini]
    FEATURES.(['InterQuartileRange_SigComplete_' NameChannels{iChannel}]) = iqr(SigChannel);
    FEATURES.(['Percentile25_SigComplete_' NameChannels{iChannel}]) = prctile(SigChannel,25);
    FEATURES.(['SumSq25_SigComplete_' NameChannels{iChannel}]) = sum(Signal_Detr_LPFilt(SigChannel < prctile(SigChannel,25),iChannel) .^ 2); % square of the sum of the signal below a certian percentile (25)
    FEATURES.(['Percentile75_SigComplete_' NameChannels{iChannel}]) = prctile(SigChannel,75);
    FEATURES.(['SumSq75_SigComplete_' NameChannels{iChannel}]) = sum(Signal_Detr_LPFilt(SigChannel < prctile(SigChannel,75),iChannel) .^ 2); % square of the sum of the signal below a certian percentile (75)
    
    %% [2] FEATURES FROM ARTICLES 
    
    % Alma Cantu
    % 1. Fast fourier transform
    NFFT = 2 ^ nextpow2(length(SigChannel));
    freqAccel = fft(SigChannel, NFFT) / length(SigChannel);
    f = Settings.Fs / 2 * linspace(0, 1, NFFT / 2 + 1);
    amplitudeSpectrum = 2 * abs(freqAccel(1:NFFT / 2 + 1));
    % 2. Integral of the data spectrum of the magnitude from 0 to 5 Hz
    sum5Hz = sum(amplitudeSpectrum(1:ceil(NFFT*5/(Settings.Fs/2))));        % single sided bandwidth is Settings.Fs / 2, we are interested in 5Hz out of Settings.Fs / 2
    FEATURES.(['SumSpectrum_Below5Hz_' NameChannels{iChannel}]) = sum5Hz; %Sum of the spectrum amplitude (below 5 Hz)
    [maxVal, maxIndx] = max(amplitudeSpectrum);                             
    maxFreq = f(maxIndx);                                                   % peak of the frequency in the spectrum amplitude below 5 Hz
    FEATURES.(['MaxFreqSpectrum_Below5Hz_' NameChannels{iChannel}]) = maxFreq;
    dataLength = ceil(length(f) * (5 / (Settings.Fs / 2)));                 % single sided 0-5Hz data
    dataOfInterest = amplitudeSpectrum(1:dataLength);
    minDistance = ceil(length(f)/Settings.Fs);
    warning Off;                                                            % idling might not have peaks, turn off warning
    [vals, ~] = findpeaks(2*abs(dataOfInterest), 'MINPEAKHEIGHT', 1,'MINPEAKDISTANCE', minDistance, 'SORTSTR', 'descend');
    warning On;    
    FEATURES.(['NumPeaksSpectrum_Below5Hz_' NameChannels{iChannel}]) = length(vals);
    
    % Lonini & Barth
    DominantCycleInfo = getDominantCycle(Signal_Detr_LPFilt(:,iChannel),Settings.Fs,Settings.Fc_HighPassFilter_AutoCorr);
    if ~isinf(DominantCycleInfo.DominantCycle_Samples)
        D = DominantCycleInfo.DominantCycle_Samples;
    else
        D = 55;
    end
    Band = [0.1 10];                                                        % Energy bands (Barth)
    FreqBandLow = [0.5 3];                                                  % Energy bands (Barth)
    FreqBandHigh = [3 8];                                                   % Energy bands (Barth)
    FreqBandBelowDomFr = [0 D]; 
    FreqBandAboveDomFr = [D 50]; 
    FEATURES.(['RelativePower_Below5Hz_' NameChannels{iChannel}]) = Compute_RP(SigChannel,Settings.Fs,Band,FreqBandLow); % Relative Power of signal (within certain rainges of frequencies)
    FEATURES.(['RelativePower_5To10Hz_' NameChannels{iChannel}]) = Compute_RP(SigChannel,Settings.Fs,Band,FreqBandHigh);
    FEATURES.(['RelativePower_BelowDomFr_' NameChannels{iChannel}]) = Compute_RP(SigChannel,Settings.Fs,Band,FreqBandBelowDomFr);
    FEATURES.(['RelativePower_AboveDomFr_' NameChannels{iChannel}]) = Compute_RP(SigChannel,Settings.Fs,Band,FreqBandAboveDomFr);
    
    % Sejdic
    [~, CMean, CSD, CMax] = centroid(SigChannel,Settings.Fs,NFFT);
    FEATURES.(['CentroidSpMean_' NameChannels{iChannel}]) = CMean;
    FEATURES.(['CentroidSpSD_' NameChannels{iChannel}]) = CSD;
    FEATURES.(['CentroidSpMax_' NameChannels{iChannel}]) = CMax;
    
    % Arora
    [pxx_plomb,f_plomb] = plomb(SigChannel,Settings.Fs);
    FEATURES.(['MeanPSD_Plomb_' NameChannels{iChannel}]) = mean(pxx_plomb);         % Arora
    FEATURES.(['MedianPSD_Plom_' NameChannels{iChannel}]) = median(pxx_plomb);      % Arora
    FEATURES.(['MeanFreq_Plom_' NameChannels{iChannel}]) = mean(f_plomb);           % Arora
    FEATURES.(['MedianFreq_Plom_' NameChannels{iChannel}]) = median(f_plomb);       % Arora
    FEATURES.(['SumPSD_Plom_' NameChannels{iChannel}]) = sum(pxx_plomb);            % Mannini/Arora
    FEATURES.(['Moment2ndPSD_Plom_' NameChannels{iChannel}]) = moment(pxx_plomb,2); % Moments of power spectral density (2nd order)
    FEATURES.(['Moment3rdPSD_Plom_' NameChannels{iChannel}]) = moment(pxx_plomb,3); % Moments of power spectral density (3rd order)
    FEATURES.(['SkewnessPSD_Plom_' NameChannels{iChannel}]) = skewness(pxx_plomb);
    FEATURES.(['KurtosisPSD_Plom_' NameChannels{iChannel}]) = kurtosis(pxx_plomb);
    FEATURES.(['ZeroCrossingRate_' NameChannels{iChannel}]) = sum(abs(diff(SigChannel>0)))/length(SigChannel);
    FEATURES.(['ModeSignal_' NameChannels{iChannel}]) = mode(SigChannel);
    Xf = fft(SigChannel); % compute the DFT (using the Fast Fourier Transform)
    FEATURES.(['EnergySignal_' NameChannels{iChannel}]) = sum(abs(Xf).^2) / length(Xf); 
end
