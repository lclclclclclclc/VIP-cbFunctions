function MakeStimEvents_Photostims(sessionpath,varargin)
%MAKESTIMEVENTS2   Create stimulus events structure.
%   MAKESTIMEVENTS2(SESSIONPATH) constructs and saves stimulus events
%   structure ('StimEvents') for the stimulation session in the folder
%   SESSIONPATH. Stimulation pulses are detected as TTLs recorded by the
%   data acquisition system (e.g. Neuralynx) and their number is verified
%   by the log file of the stimulation control software. Note however, that
%   the recorded TTLs are exclusive source of stimulus information. Note
%   also, that the Neuralynx Event file should first be converted to Matlab
%   .mat file before MAKESTIMEVENTS2 can run.
%
%   Stimulus time stamps (e.g. pulse onset and offset, burst onset and
%   offset, protocol start and end), time intervals (e.g. inter-burst
%   interval, burst duration, pulse duration), stimulation-related
%   statistics (e.g. frequency) are extracted/calculated from the recorded
%   TTL time stamps and event strings. The data are loaded in a structure
%   and saved under the name 'StimEvents.mat'.
%
%   By using the MAKESTIMEVENTS2(SESSIONPATH,PARAMETER1,VALUE1,...) syntax, 
%   the TTLs actually used during the recording as well as the name of
%   stimulus protocol file can be specified (default values provided):

%       'PulseNttl', 16384 - TTL signalling pulse onset and offset time
%           (TTL split between stimulation device and data acquisition
%           system)
%
%   See also PARSETTLS.

%   Edit log: BH 4/2/13
%% default arguments
prs = inputParser;
addRequired(prs,'sessionpath',@ischar)  % pathname for session
addParameter(prs,'pulseTTL',2,@isnumeric)   % TTL signalling pulse onset and offset time
addParameter(prs,'burstTTL',4,@isnumeric)   % TTL signalling pulse onset and offset time
addParameter(prs, 'zeroTTL', 0, @isnumeric)
parse(prs,sessionpath,varargin{:})
g = prs.Results;

%% Check session path
if ~isdir(sessionpath)
    error('Session path is not valid.');
end
cd(sessionpath)

%% Load Events
if ~exist('1HzEVENTS.mat', 'file')
    disp('1HzEVENTS.mat not found.  Generating with segmentBehavMulti1Hz.m');
    segmentBehavMulti1Hz; %make this a function  
end

pE = load('1HzEVENTS.mat', 'Events_*'); %Events_TTL and Events_TS
bE = load('multiEVENTS.mat', 'Events_*'); %Events_TTL and Events_TS
%% Define interestingThings
    % pulseTTL and burstTTL are already defined as 2 and 4, respectively
%% Find pulse only interestingThings (1Hz)
pOn = pE.Events_TS(pE.Events_TTL==g.pulseTTL);
pOff = pOn + 0.005;
pPrevOffset = [NaN pOff(1:end-1)];
pIPI = pOn - pPrevOffset;

pNum = numel(pOn);
%% Find burst only interestingThings (multi)
bOn = bE.Events_TS(bE.Events_TTL==g.burstTTL);
bOff = bOn + 0.005;
bPrevOffset = [NaN bOff(1:end-1)];
bIBI = bOn - bPrevOffset;

bNum = numel(bOn);
if mod(bNum, 4) ~= 0 %scary way to assign burst frequencies
    warning("Partial Photostim_multi detected.  Fix the makeStimEvents_Photostims script.")
end
bFreq = repmat([10 20 40 80], [1,bNum/4]);

%% Preallocate stimulus events
numStims = pNum + bNum;
SE = struct(...
    'TrialStart', zeros(1, numStims),...
    'PulseOn', nan(1,numStims),...
    'PulseOff', nan(1,numStims),...
    'PulseIPI', nan(1,numStims),...
    'PulsePrevOffset', nan(1,numStims),...
    'BurstOn', nan(1,numStims),...
    'BurstOff', nan(1,numStims),...
    'BurstIBI', nan(1,numStims),...
    'BurstPrevOffset', nan(1,numStims),...
    'StimOn',   nan(1,numStims), ...
    'StimOff',  nan(1,numStims),...
    'StimType', nan(1,numStims),...
    'BurstFreq',nan(1,numStims)...
    );

%% Combine pulse and burst events

%StimOn
[StimOn, stimSort] = sort([pOn bOn]); %stimSort starts from [all pulses] [all bursts]
SE.StimOn = StimOn;

%StimOff
pbOff = [pOff bOff];
SE.StimOff = pbOff(stimSort);

%StimType
pType = ones(1,pNum); % 1 is pulse
bType = ones(1,bNum) * 2; % 2 is burst
pbTypes = [pType bType];
SE.StimType = pbTypes(stimSort);

%% Fill out rest of SE
pInds = find(SE.StimType == 1);
bInds = find(SE.StimType == 2);

%PulseOn
SE.PulseOn(pInds) = pOn;
%PulseOff
SE.PulseOff(pInds) = pOff;
%PulsePrevOffset
SE.PulsePrevOffset(pInds) = pPrevOffset;
%PulseIPI
SE.PulseIPI(pInds) = pIPI;
%BurstOn
SE.BurstOn(bInds) = bOn;
%BurstOff
SE.BurstOff(bInds) = bOff;
%BurstPrevOffset
SE.BurstPrevOffset(bInds) = bPrevOffset;
%BurstIBI
SE.BurstIBI(bInds) = bIBI;
%BurstFreq
SE.BurstFreq(bInds) = bFreq;

%% Save 'StimEvents'
save([sessionpath, filesep 'StimEvents.mat'],'-struct','SE')