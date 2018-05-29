function [events,epochs] = defineEventsEpochs_laserstim
%DEFINEEVENTSEPOCHS_LASERSTIM   Define events and epochs for spike extraction.
%   [EVENTS,EPOCHS] = DEFINEEVENTSEPOCHS_LASERSTIM defines events and
%   epochs for spike extraction. 
%
%   EVENTS is a Nx4 cell array with columns corresponding to EventLabel,
%   EventTrigger1, EventTrigger2, Window. EventLabel is the name for
%   referencing the event. EventTrigger1 and EventTrigger2 are names of
%   StimEvent variables (e.g. 'BurstOn'). For fixed windows, the two
%   events are the same; for variable windows, they correspond to the start
%   and end events. Window specifies time offsets relative to the events;
%   e.g. events(1,:) = {'BurstOn', 'BurstOn', 'BurstOn', [-6 6]};
%
%   EPOCH is a Nx4 cell array with columns corresponding to  EpochLabel, 
%   ReferenceEvent, Window, RealWindow. EventLabel is the name for 
%   referencing the epoch. ReferenceEvent should match an EventLabel in 
%   EVENTS (used for calculating the epoch rates). RealWindow is currently
%   not implemented (allocated for later versions).
%
%   DEFINEEVENTSEPOCHS_LASERSTIM defines stimulus events and epochs for
%   photo-stimulation (LASERSTIMPROTOCOL_NI2).
%
%   See also PREALIGNSPIKES and DEFINEEVENTSEPOCHS_DEFAULT.

%   Edit log: BH 7/18/13

% Define events and epochs
%              EventLabel       EventTrigger1    EventTrigger2  Window
i = 1;
events(i,:) = {'BurstOn',       'BurstOn',      'BurstOn',      [-6 6]};   i = i + 1;  
events(i,:) = {'PreBurstIBI',   'BurstPrevOffset', 'BurstOn',   [0 0]};    i = i + 1;  
events(i,:) = {'BurstPeriod',   'BurstOn',      'BurstOff',     [0 0]};    i = i + 1;  

events(i,:) = {'PulseOn',       'PulseOn',      'PulseOn',      [-6 6]};   i = i + 1;  
events(i,:) = {'PrePulseIPI',   'PulsePrevOffset', 'PulseOn',   [0 0]};    i = i + 1;  
events(i,:) = {'PulsePeriod',   'PulseOn',      'PulseOff',     [0 0]};    i = i + 1;  


% Define epochs for rate calculations
%               EpochLabel             ReferenceEvent  FixedWindow          RealWindow
i = 1;
epochs(i,:) = {'BurstBaseline',        'PreBurstIBI',  [NaN NaN],     'NaN'};           i = i + 1;
epochs(i,:) = {'BurstResponse',        'BurstPeriod',  [NaN NaN],     'NaN'};           i = i + 1;

epochs(i,:) = {'PulseBaseline',        'PrePulseIPI',  [NaN NaN],     'NaN'};           i = i + 1;
epochs(i,:) = {'PulseResponse',        'PulsePeriod',  [NaN NaN],     'NaN'};           i = i + 1;