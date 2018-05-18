%% Use of segment events for general case of behavior with max(TTLs) >= 14,
 % photoStimMulti with 4
 % Assumes EVENTS.mat
 
 behavMarker = 12;
 behavName = 'behav';
 multiMarker = 4;
 multiName = 'multi';
 pulseMarker = 2;
 pulseName = '1Hz';
 
 %%
 %separate photostim events from behavior
 segmentEvents(behavMarker, behavName, 'allStim', 'EVENTS.mat')
 
 %separate photostimMulti from photostim1Hz
 segmentEvents(multiMarker, multiName, pulseName, 'allStimEVENTS.mat')
 
 %% clean up
 clear behavMarker behavName multiMarker multiName pulseMarker pulseName