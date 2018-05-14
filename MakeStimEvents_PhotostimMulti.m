function MakeStimEvents_PhotostimMulti(EVENTSfn, Bpodfn)

    %%load in files
multi = load(EVENTSfn);
load(Bpodfn); %SessionData
ttls = multi.Events_TTL;
tss = multi.Events_TS;

    %% start by finding bursts
burstStartTTL = 4;

burstStartInds = find(ttls == burstStartTTL); 
burstsTS = tss(burstStartInds);
%%
% nBursts = SessionData.nTrials;
%burst happens at SessionData.RawEvents.Trial{1,4}.States.DeliverStimulus(1)
%              or SessionData.RawEvents.Trial{1,35}.Events.Tup(burstStartTTL)
% burstsTS = nan(1,nBursts);
% for i = 1:nBursts
%     burstLatency = SessionData.RawEvents.Trial{1,i}.Events.Tup(burstStartTTL);
%     burstsBpodTS(i) = SessionData.TrialStartTimestamp(i) + burstLatency;
% end
    
if numel(burstsTS) ~= numel(SessionData.TrialTypes)
    warning('Number of bursts does not match number of trials');
end
 %% classify burst types   
trials10Hz = find(SessionData.TrialTypes == 1);
trials20Hz = find(SessionData.TrialTypes == 2);
trials40Hz = find(SessionData.TrialTypes == 3);
trials80Hz = find(SessionData.TrialTypes == 4);

bursts10Hz = makeEntry(trials10Hz, burstsTS); %
bursts20Hz = makeEntry(trials20Hz, burstsTS); %
bursts40Hz = makeEntry(trials40Hz, burstsTS); %
bursts80Hz = makeEntry(trials80Hz, burstsTS); %

%%
TrialStartTimes = zeros(1, SessionData.nTrials);
save('burstEvents.mat', 'TrialStartTimes', 'burstsTS', ...
    'bursts10Hz', 'bursts20Hz', 'bursts40Hz', 'bursts80Hz');
end


function entry = makeEntry(entryInds, stimsTS)
    entry = nan(1,length(stimsTS));
    entry(entryInds) = stimsTS(entryInds);
end