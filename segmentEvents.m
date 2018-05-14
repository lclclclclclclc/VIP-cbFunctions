function segmentEvents(segMarker, segName, restName, EVENTSfn)
    %%% Segments Events_TTL and Events_TS from entire recording session
    %%% into two sets of TTLs and TSs: those containing the behavMarker, and
    %%% everything before and after that does not contain the behavMarker.
    %%% The first pair is saved as behavEVENTS.mat, and the second as
    %%% stimEVENTS.mat.
   
    all = load(EVENTSfn);
    trialStartTTL = 1;
    trialEndTTL = 0;
   

    segFirstTrialInd = find(all.Events_TTL==segMarker, 1, 'first');
    segLastTrialInd  = find(all.Events_TTL==segMarker, 1, 'last');

    segStart = find(all.Events_TTL(1:segFirstTrialInd) == trialStartTTL, 1, 'last');
    segEnd   = find(all.Events_TTL(segLastTrialInd:end) == trialEndTTL, 1, 'first')...
                    + segLastTrialInd - 1;
                
    clear Events_TTL Events_TS
    segEVENTSname = strcat(segName, 'EVENTS.mat');
    % segTTLname = strcat(segName, 'Events_TTL');
    % segTSname  = strcat(segName, 'Events_TS');          
    Events_TTL = all.Events_TTL(segStart:segEnd);
    Events_TS  = all.Events_TS(segStart:segEnd);
    save(segEVENTSname, 'Events_TTL', 'Events_TS');
    
    clear Events_TTL Events_TS
    restEVENTSname = strcat(restName, 'EVENTS.mat');
    % restTTLname = strcat(restName, 'Events_TTL');
    % restTSname  = strcat(restName, 'Events_TS');
    restInds = [[1:segStart], [segEnd:length(all.Events_TTL)]];
    Events_TTL = all.Events_TTL(restInds);
    Events_TS = all.Events_TS(restInds);
    save(restEVENTSname, 'Events_TTL', 'Events_TS');
    
end