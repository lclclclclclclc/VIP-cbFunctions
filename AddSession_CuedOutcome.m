%% READ THE HELP!!!!
%cellbase is actually quite well documented.
%cellbase provides tons of function and helper functions, which can be
%easily overlooked. It is worth spending some time at least scrolling over
%the function reference and reading function headers once in a while


%%filesystem orientation
sessionDir = 'VIP-Ai32-NNx-6/20180413a';
CuedEventsFN = 'CuedEvents.mat'; % proto-TrialEvents struct supplied to MakeTrialEvents

dataDir = getpref('cellbase', 'datapath');
fullDir = [dataDir '/' sessionDir];
%% find new cells
cells = findallcells(sessionDir);

%extract subject and session name
[subject, session] = cellid2tags(cells{1});

%% Load TTLs (segment if needed)
returndir = pwd;
cd(fullDir);
    if ~exist('behavEVENTS.mat', 'file')
        disp('behavEVENTS.mat not found.  Generating with segmentBehavMulti1Hz.m');
        segmentBehavMulti1Hz; %make this a function  
    end
    load('behavEVENTS.mat', 'Events_*'); %Events_TTL and Events_TS
    
%% Handle behavior (CuedOutcome) data
    % Load the input struct for TrialEvents
    if ~exist(CuedEventsFN, 'file')
        filePickerMsg = strcat('Locate the CuedEvents file for session ', session);
        [fn, path] = uigetfile('*.mat', filePickerMsg, 'MultiSelect', 'off')
        CuedEventsFN = strcat(fn, path); % redefine CuedEventsFN with ui location
    end

    load(CuedEventsFN, 'CuedEvents'); %struct named CuedEvents
cd(returndir);

% Align to recording data and save trial events file
    % this will save a TrialEvents.mat in session folder
    % with THE ADDITIONAL FIELD ***TrialStart*** containing the trial start
    % timestamps from the recording system for each trial

MakeTrialEvents(cells{1}, CuedEvents, Events_TTL, Events_TS, 'nameTrialStart', 'TrialStartTimes');
% okay to do with only cells{1} because all from same session

% Prealign spikes
prealignSpikes(cells,'FUNdefineEventsEpochs',@defineEventsEpochs_CuedOutcome,'filetype','behav','events',[],'epochs',[],'writing_behavior','overwrite','ifsave',1);

%% Handle stim (Photostim_1Hz, Photostim_multi) data

% Write StimEvents.mat
MakeStimEvents_Photostims(fullDir);

% Prealign spikes
prealignSpikes(cells,'FUNdefineEventsEpochs',@defineEventsEpochs_Photostims,'filetype','stim','events',[],'epochs',[],'writing_behavior','overwrite','ifsave',1);


%% Create the single trial PSTH arrays
% This is something I create for every cell to save me calculation time and
% redunant calls later. But there is no general function for it. See my
% branch?
% CreateSingleTrialPSTH(cells)

% %% user demo
% clear all
% 
% loadcb
% % CELLIDLIST
% 
% %or listtag('cells')
% 
% cellid = CELLIDLIST{1};
% TE = loadcb(cellid,'TrialEvents');
% SE = loadcb(cellid,'EVENTSPIKES');

% %% plot/get psth functions
% % viewcell2b
% % apsth
% % ultimate_psth
% 
% %viewcell2b logic
% % --> gets stimes (EVENTSPIKES)
% % --> calls stimes2binraster
% % --> calls binraster2psth or binraster2apsth (adaptive)
% % --> plot_raster2a + plot_timecourse
% 
% %(bug: 'Partitions','all' (default) does not work because it makes too
% %strong assumptions about first TE field in partition_trials.m)
% %note: partition corresponds to field in TE file. has to be a double or int
% %bug with legends in plot_timcourse.m
% %slow (because of inefficiently plotting rasters! (with uistack))
% tic
% viewcell2b(cellid,'TriggerName','StimulusOnset','SortEvent','StimulusOffset','eventtype','behav','ShowEvents',{{'StimulusOffset'}},'window',[-1,1],'Partitions','#CorrectChoice');
% toc
% 
% % ultimate_psth logic
% % used not for plotting, but for returning psth values
% % --> gets stimes (EVENTSPIKES)
% % --> calls stimes2binraster
% % --> calls binraster2psth or binraster2apsth or binraster2dapsth (adaptive)
% % --> calls psth_stats
% tic
% [psth, spsth, spsth_se, tags, spt, stats] = ultimate_psth(cellid,'trial','StimulusOnset',[-1,1],'parts','#CorrectChoice','display',true);
% toc
% figure,plot(spsth')
% 
% % useful figure export function
% %writefigs(gcf,path_to_fig) %writes to pdf and will append if pdf exists

%% what Paul and I do
% calculate single trial psth and save for different alignments
% calculate trial average psth for conditions from there
% faster but lots of customized functions

% %% Add cells to Cell Base / Compute the analysis
% addcell(cells); %will compute added analyses
% %cf addnewcells() addnewsessions() 
% 
% %% calculate analyses
% % results go in ANALYSES and TheMatrix
% % suited for any analysis which assigns a number/category to each cell
% % you can additionally specify input to functions, which outputs to use etc
% addanalysis(@myanalysis,'property_names',{'myvalue','mypvalue'})
% addanalysis(@meanrate,'property_names',{'rate'})
% 
% %some functions to deal with analyses
% delanalysis(@myanalysis)
% 
% findanalysis(@myanalysis)
% findprop('mypvalue')
% 
% getvalue('mypvalue')
