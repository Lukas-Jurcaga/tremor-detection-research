function FEATURES = extract_Complex(Signal_Detr_LPFilt,Settings,iBout,iJunk,FEATURES)
%FEATURES = extract_Complex(Signal_Detr_LPFilt,Settings,iBout,iJunk,FEATURES)

%% FUNCTION INFO
for Close_Function_Info = 1
    
    % EXPLANATION:
    
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
    AngleSymbolic = angle(SigChannel);
    FEATURES.(['SymbolicAngle_' NameChannels{iChannel}]){iJunk,iBout} = AngleSymbolic(end); 
    [FEATURES.(['LempelZiv_Complex_' NameChannels{iChannel}]){iJunk,iBout},~,~] = calc_lz_complexity(SigChannel, 'primitive', 0); %Lempel-Ziv measure of binary sequence complexity
    % Detrend Fluctuation Analysis
    DominantCycleInfo = getDominantCycle(Signal_Detr_LPFilt(:,iChannel),Settings.Fs,Settings.Fc_HighPassFilter_AutoCorr);
    if ~isinf(DominantCycleInfo.DominantCycle_Samples)
        D = DominantCycleInfo.DominantCycle_Samples;
    else
        D = 55;
    end
    warning Off;
    [DFA_A,DFA_F] = DFA_fun(SigChannel,D,1);
    FEATURES.(['DetrendFluctuation_' NameChannels{iChannel}]){iJunk,iBout} = DFA_F(1);
    warning On;
    [EnOpSig,TeagOp]=energyop(SigChannel,0);
    FEATURES.(['EnergyOperatorMax_' NameChannels{iChannel}]){iJunk,iBout} = max(EnOpSig);
    FEATURES.(['EnergyOperatorMedian_' NameChannels{iChannel}]){iJunk,iBout} = median(EnOpSig);
    FEATURES.(['EnergyOperatorSum_' NameChannels{iChannel}]){iJunk,iBout} = sum(EnOpSig);
    FEATURES.(['EnergyOperatorKurtosis_' NameChannels{iChannel}]){iJunk,iBout} = kurtosis(EnOpSig);
    FEATURES.(['EnergyOperatorSkewness_' NameChannels{iChannel}]){iJunk,iBout} = skewness(EnOpSig);
    FEATURES.(['TeagerOperatorMax_' NameChannels{iChannel}]){iJunk,iBout} = max(TeagOp);
    FEATURES.(['TeagerOperatorMedian_' NameChannels{iChannel}]){iJunk,iBout} = median(TeagOp);
    FEATURES.(['TeagerOperatorMedian_' NameChannels{iChannel}]){iJunk,iBout} = sum(TeagOp);
    FEATURES.(['TeagerOperatorKurtosis_' NameChannels{iChannel}]){iJunk,iBout} = kurtosis(TeagOp);
    FEATURES.(['TeagerOperatorSkewness_' NameChannels{iChannel}]){iJunk,iBout} = skewness(TeagOp);
end
SigVT = Signal_Detr_LPFilt(:,1);
SigML = Signal_Detr_LPFilt(:,2);
SigAP = Signal_Detr_LPFilt(:,3);
[FEATURES.DistDTW_VTML{iJunk,iBout}] = dtw(SigVT,SigML);
[FEATURES.DistDTW_VTAP{iJunk,iBout}] = dtw(SigVT,SigAP);
[FEATURES.DistDTW_MLAP{iJunk,iBout}] = dtw(SigML,SigAP);

