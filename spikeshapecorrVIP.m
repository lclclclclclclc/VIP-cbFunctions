function R = spikeshapecorrVIP(cellid)
%SPIKESHAPECORR   Correlation of spontaneous and light-evoked spike shape.
%   R = SPIKESHAPECORR(CELLID) calculates correlation coefficient between
%   the waveform of spontaneous and putative light-evoked spikes. It finds
%   the latency of putative light-evoked spikes as peaks of firing rate
%   after light pulses. The period for putative light-evoked spikes is
%   defined by half-height crossings around the peak (see FINDSTIMPERIOD for
%   details). If there is no detectable activation, 1 and 6 ms are used,
%   which include typical latencies of light-evoked spikes. Spontaneous
%   spikes are extracted from 2 s periods before light bursts. Waveforms
%   are restricted to 750 us (default of DigiLynx censored period). NaN is
%   returned if there are less than 2 evoked and/or spontaneous spikes.
%   Correlation is calculated for the channel with the largest spikes.
%
%   See also FINDSTIMPERIOD, ABS2RELTIMES, EXTRACTSEGSPIKES and
%   EXTRACTSPIKEWAVEFORMS.

%   Balazs Hangya, Cold Spring Harbor Laboratory
%   1 Bungtown Road, Cold Spring Harbor
%   balazs.cshl@gmail.com

% Latency of stimulated spikes
[lim1, lim2] = findStimPeriod(cellid, 'display', true);   % find putative stimulated period
if isnan(lim1) || isnan(lim2)
    lim1 = 0.001;   % no activation detected
    lim2 = 0.006;
end

% Evoked spikes
tsegs_evoked = rel2abstimes(cellid,[lim1 lim2],'stim','PulseOn');   % convert period to epochs relative to pulses
selts_evoked = extractSegSpikes(cellid,tsegs_evoked);   % find putative stimualated spikes
wave_evoked = extractSpikeWaveforms(cellid,selts_evoked,'chans','mean_max', 'data_filetype', 'SGdat');  % get waveforms for the extracted spikes

% Spontaneous spikes
tsegs_spont = rel2abstimes(cellid,[0,2],'trial','TrialStartRel');
selts_spont = extractSegSpikes(cellid,tsegs_spont);     % extract spontaneous spikes
wave_spont = extractSpikeWaveforms(cellid,selts_spont,'chans','mean_max','data_filetype', 'SGdat');    % get waveforms for the extracted spikes

% Correlation
if length(selts_evoked) > 1 && length(selts_spont) > 1   % if there are waveforms to calculate corr. for
    spontInd = ~isnan(wave_spont);
    evokInd = ~isnan(wave_evoked);
    bothInd = spontInd & evokInd;
    pr = corrcoef(wave_spont(bothInd), wave_evoked(bothInd));
    R = pr(1,2);
else
    R = NaN;
end