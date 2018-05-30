function taggingVIP(I,issave)
%TAGGING   Cluster quality and tagging index.
%   TAGGING calculates cluster quality measures, tagging index and spike
%   shape correlation between spontaneous and light-evoked action
%   potentials for all cells in CellBase (see also CellBase documentation).
%   It calls LRATIO, NBISSTIM and SPIKESHAPECORR.
%
%   TAGGING(I) runs only for the cell IDs in I. I can also be an index set
%   to CELLIDLIST.
%
%   TAGGING(I,IS) accepts a second, logical input argument determining
%   whether to save the results of the analysis. Default beahvior is not
%   saving.
%
%   See also LRATIO, NBISSTIM and SPIKESHAPECORR.

%   Balazs Hangya, Cold Spring Harbor Laboratory
%   1 Bungtown Road, Cold Spring Harbor
%   balazs.cshl@gmail.com
%   05-Oct-2012

% Pass the control to the user in case of error
dbstop if error

% Input argument check
narginchk(1,2)
if nargin < 2
    issave = false;
end
skipclusterquality = false;

% Directories
global DATAPATH
fs = filesep;
resdir = [DATAPATH 'NB' fs 'tagging_new' fs];
xlsname = [resdir fs 'tagging.xls'];   % write results to excel file

% Load CellBase
loadcb

% Input argument check
nmc = length(CELLIDLIST);    
if nargin < 1
    I = 1:nmc;
else
    if isnumeric(I)
        I = CELLIDLIST(I);   % index set to CELLIDLIST
    elseif ischar(I)
        I = {I};   % only one cellID passed
    elseif iscellstr(I)
        % list of cell IDs
    else
        error('tagging:inputArg','Unsupported format for cell IDs.')
    end
end

% Call 'Lratio', 'nbisstim', 'spikeshapecorr'
feature_names1 = {'Peak','Energy'}; %originally Amplitude and Energy
feature_names2 = {'WavePC1','Energy'};
for k = 1:length(I)
    cellid = I{k};
    disp([num2str(k) '   ' cellid])
    try
        
        % Determine whether there was a stimulation session
        if logical(exist(cellid2fnames(cellid,'StimEvents'),'file'))
            isstim = 1;
        else
            disp(['No ''StimEvents'' file for ' cellid])
            isstim = 0;
        end
        
        % Cluster quality
        if ~skipclusterquality
            [ID_amp, Lr_amp] = LRatioVIP(cellid,'feature_names', feature_names1);
            [ID_PC, Lr_PC, valid_channels] = LRatioVIP(cellid,'feature_names', feature_names2); %#ok<NASGU>
        else   % if cluster quality was already calculated, it can be skipped
            [ID_amp, Lr_amp] = deal(NaN);
            [ID_PC, Lr_PC, valid_channels] = deal(NaN); %#ok<NASGU>
        end
        
        if isstim
            
            % Add 'PulseOn' event if missing
            ST = loadcb(cellid,'STIMSPIKES');
            if isequal(findcellstr(ST.events(:,1),'PulseOn'),0)
                prealignSpikes(I(k),'FUNdefineEventsEpochs',...
                    @defineEventsEpochs_photostims,'filetype','stim',...
                    'ifsave',1,'ifappend',1)
            end
            
            % Tagging index
            [Hindex, D_KL] = nbisstimVIP(cellid);
            
            % Spike shape correlation
            R = spikeshapecorrVIP(cellid);
            
            %TO
            Insert{1,1}=cellid;
            Insert{1,2}=Hindex;
            insertdata(Insert,'type','prop','name','Hindex','overwrite',true)
            Insert{1,1}=cellid;
            Insert{1,2}=D_KL;
            insertdata(Insert,'type','prop','name','D_KL','overwrite',true)
            Insert{1,1}=cellid;
            Insert{1,2}=R;
            insertdata(Insert,'type','prop','name','R_WF','overwrite',true)   
            Insert{1,2}=Lr_PC;
            insertdata(Insert,'type','prop','name','Lr_PC','overwrite',true) 
            Insert{1,2}=ID_PC;
            insertdata(Insert,'type','prop','name','ID_PC','overwrite',true) 
        
        else
            Hindex = NaN;
            D_KL = NaN;
            R = NaN;
            Lr_PC;
            ID_PC;
        end
                
        if issave        
            % Save
            save([resdir 'TAGGING_' regexprep(cellid,'\.','_') '.mat'],...
                'Lr_amp','ID_amp','Lr_PC','ID_PC','valid_channels',...
                'Hindex','D_KL','R_WF')
            
            % Write to Excel
            Lr_amp_xls = formatforExcel(Lr_amp);   % convert special numbers to strings
            ID_amp_xls = formatforExcel(ID_amp);
            Lr_PC_xls = formatforExcel(Lr_PC);
            ID_PC_xls = formatforExcel(ID_PC);
            Hindex_xls = formatforExcel(Hindex);
            D_KL_xls = formatforExcel(D_KL);
            R_xls = formatforExcel(R);
                        
            xlswrite(xlsname,I(k),'sheet1',['A' num2str(k)])
            xlswrite(xlsname,Lr_amp_xls,'sheet1',['B' num2str(k)])
            xlswrite(xlsname,ID_amp_xls,'sheet1',['C' num2str(k)])
            xlswrite(xlsname,Lr_PC_xls,'sheet1',['D' num2str(k)])
            xlswrite(xlsname,ID_PC_xls,'sheet1',['E' num2str(k)])
            xlswrite(xlsname,Hindex_xls,'sheet1',['F' num2str(k)])
            xlswrite(xlsname,D_KL_xls,'sheet1',['G' num2str(k)])
            xlswrite(xlsname,R_xls,'sheet1',['H' num2str(k)])
        end
        
    catch ME
        disp(['Something went wrong for cell ' num2str(k) '.'])
        disp(ME.message)
    end
end