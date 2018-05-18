function [events,epochs] = defineEventsEpochs_CuedOutcome
%DEFINEEVENTSEPOCHS_DEFAULT   Define events and epochs for spike extraction.
%   [EVENTS,EPOCHS] = DEFINEEVENTSEPOCHS_DEFAULT defines events and epochs
%   for spike extraction. 
%
%   EVENTS is a Nx4 cell array with columns corresponding to EventLabel,
%   EventTrigger1, EventTrigger2, Window. EventLabel is the name for
%   referencing the event. EventTrigger1 and EventTrigger2 are names of
%   TrialEvent variables (e.g. 'LeftPortIn'). For fixed windows, the two
%   events are the same; for variable windows, they correspond to the start
%   and end events. Window specifies time offsets relative to the events;
%   e.g. events(1,:) = {'OdorValveOn','OdorValveOn','OdorValveOn',[-3 3]};
%
%   EPOCH is a Nx4 cell array with columns corresponding to  EpochLabel, 
%   ReferenceEvent, Window, RealWindow. EventLabel is the name for 
%   referencing the epoch. ReferenceEvent should match an EventLabel in 
%   EVENTS (used for calculating the epoch rates). RealWindow is currently
%   not implemented (allocated for later versions).
%
%   See also MAKETRIALEVENTS2_GONOGO and DEFINEEVENTSEPOCHS_PULSEON.

%   Edit log: BH 7/6/12

% Define events and epochs
%              EventLabel       EventTrigger1      EventTrigger2      Window
i = 1;
events(i,:) = {'LickARew', 'AnticipLick_CueA_Reward', 'AnticipLick_CueA_Reward', [-3 3]};    i = i + 1;
events(i,:) = {'noLickARew', 'NoAnticipLick_CueA_Reward', 'NoAnticipLick_CueA_Reward', [-3 3]};    i = i + 1;
events(i,:) = {'Uncued_Reward',      'Uncued_Reward',        'Uncued_Reward',        [-3 3]};    i = i + 1;

% Variable events

% Define epochs for rate calculations
%               EpochLabel      ReferenceEvent     Window             RealWindow
i = 1;

epochs(i,:) = {'Baseline_LickARew', 'LickARew',         [-2.5 -2.0],       'x'};    i = i + 1;
epochs(i,:) = {'Baseline_noLickARew','noLickARew',     [-2.5 -2.0],        'x'};    i = i + 1;
epochs(i,:) = {'Baseline_Uncued_Reward','Uncued_Reward',     [-2.5 -2.0],        'x'};    i = i + 1;
