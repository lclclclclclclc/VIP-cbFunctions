function MakeStimEvents_Photostim1Hz(EVENTSfn, varargin)
%%% creates StimEvents file "pulseEvents.mat for Photostim1Hz events and timestamps.
%%% (Generate these using segmentEvents.mat.)  
%%% Takes stim1HzEVENTS.mat filename and optional Bpod files
%%% (1Hz_Session1,2,3,4,...) simply to check trial numbers
%%% File contains:
%%%             TrialStartTimestamps (all zero)
%%%             pulsesTS (timestamps of pulse onset in recording system
%%%             frame)


pulses = load(EVENTSfn);
ttls = pulses.Events_TTL;
tss = pulses.Events_TS;

pulseStartTTL = 2;

pulseStartInds = find(ttls == pulseStartTTL); 
pulsesTS = tss(pulseStartInds);

%% load in Bpod files (if any)
nBpodFiles = length(varargin);
if nBpodFiles > 0
    nPulses = 0;
    for i = 1:nBpodFiles
        bpodf = load(varargin{i});
        nPulses = nPulses + bpodf.SessionData.nTrials
    end
if numel(pulsesTS) ~= nPulses
    warning('Number of pulses does not match number of trials');
end

else
    nPulses = length(pulsesTS);
end

%%
TrialStartTimes = zeros(1, nPulses);
save('pulseEvents.mat', 'TrialStartTimes', 'pulsesTS');
end


function entry = makeEntry(entryInds, stimsTS)
    entry = nan(1,length(stimsTS));
    entry(entryInds) = stimsTS(entryInds);
end