function O = getFrequencyAnalysis(DetrendData,Fs,Nfft,N_Harm,Settings,HanningWindow_Size,FreqWindow,PlotSettings)

%% Get power spectra density of detrend data
for i=1:size(DetrendData,2)
    w = hanning(floor(HanningWindow_Size));
    [P(:,i),F] = pwelch(DetrendData(1:HanningWindow_Size,i),w,50,HanningWindow_Size*10,Fs); %normalized
end
dF = F(2)-F(1);

% Add sum of power spectra (as a rotation-invariant spectrum)
P = [P,sum(P,2)];
PS = sqrt(P);

for i=1:size(P,2)-1
    % Relative cumulative power and frequencies that correspond to these cumulative powers
    PCum = cumsum(P(:,i))*dF;
    PCumRel = cumsum(P(:,i))/sum(P(:,i));
    PSCumRel = cumsum(PS(:,i))/sum(PS(:,i));
    FCum = F+0.5*dF;

    % Calculate relative power of first twenty harmonics, taking the power of each harmonic with a band of + and - 10% of the first harmonic around it
    PHarm = zeros(N_Harm,1);
    PSHarm = zeros(N_Harm,1);
    for Harm = 1:N_Harm
        FHarmRange = (Harm+FreqWindow);                                     % min dominant freq - max dominant freq
        PHarm(Harm) = diff(interp1(FCum,PCumRel,FHarmRange));
        PSHarm(Harm) = diff(interp1(FCum,PSCumRel,FHarmRange));
    end

    % Index of Harmonicity
    if i == 4
        IndexHarmonicity(i) = sum(PHarm(1:2))/sum(PHarm(1:12));
    else
        IndexHarmonicity(i) = PHarm(1)/sum(PHarm(2:2:12));
    end    

    % Harmonic Ratios
    HarmonicRatio(i) = sum(PSHarm(2:2:end))/sum(PSHarm(1:2:end-1));        
end


%% Measures tested by Weiss et al. 2013

% Original function from Sitse Riespens
[DominantFreq,Amplitude,Width,Slope,Range,MeanPower,MedianPower,MeanFreq,MedianFreq,MomentPSD_2nd,MomentPSD_3rd,SkewnessPSD,KurtosisPSD,SumPSD] = ...
    extractFreqBasedFeautres_AnerWeiss(DetrendData,Nfft,Fs,HanningWindow_Size,Settings,PlotSettings);
% Modified function (from Sitse Riespens).Amplitude is now normalized to the integral of the power spectral density
[~,AmplitudeNorm,WidthNorm,SlopeNorm,RangeNorm,IntegratedPower] = ...
    extractFreqBasedFeautres_AnerWeiss_norm(DetrendData,Nfft,Fs,HanningWindow_Size,Settings,PlotSettings);

%% Outputs

% Gait frequency-based features proposed by Aner Weiss and used by Sietse Rispens
O.Amplitude = Amplitude;
O.AmplitudeNorm = AmplitudeNorm;
O.Width = Width;
O.Slope = Slope;
O.Range = Range;

% Gait frequency-based features proposed by Lonini et al.
O.MomentPSD_2nd = MomentPSD_2nd; %Lonini
O.MomentPSD_3rd = MomentPSD_3rd; %Lonini
O.SkewnessPSD = SkewnessPSD;
O.KurtosisPSD = KurtosisPSD;

% Gait frequency-based features proposed by Qu Wei & Mannini
O.MeanPower = MeanPower;
O.MedianPower = MedianPower;
O.MeanFreq = MeanFreq;
O.MedianFreq = MedianFreq;
O.WidthNorm = WidthNorm;
O.SlopeNorm = SlopeNorm;
O.RangeNorm = RangeNorm;
O.IntegratedPower = IntegratedPower;
O.SumPSD = SumPSD;

% Harmonicity
O.IndexHarmonicity = IndexHarmonicity;
O.HarmonicRatio = HarmonicRatio;
