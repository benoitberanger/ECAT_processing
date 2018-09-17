clear
clc

load e_likert.mat

% e.countSeries


%% Add stim files

e.getSerie('LIKERTA','name').addStim(fullfile(pwd,'behaviour'), 'MRI_LIKERT_.*A_run\d{2}.mat$', 'raw')
e.getSerie('LIKERTB','name').addStim(fullfile(pwd,'behaviour'), 'MRI_LIKERT_.*B_run\d{2}.mat$', 'raw')

% e.explore

Files = e.getSerie('likert').getStim('raw');


for f = 1 : numel(Files)
    S=Files(f).load;
    S=S{1}.S.TaskData;
    DATA = S.RR.Data;

%     to_remove = {'StartTime', 'StopTime', 'Draw'};
%     for rem = 1 : length(to_remove)
%         res = regexp(DATA(:,1),to_remove{rem});
%         res = ~cellfun(@isempty,res);
%         DATA(res,:) = [];
%     end
    
    fusion_orig = {
        { 'PreparationCross' 'BlankScreen' 'Hold' };
        { 'Likert' }
        { 'Picture__NEU' };
        { 'Picture__ISO' };
        { 'Picture__ERO' };
        };
    
    fusion_to = {
        'trash'
        'Likert'
        'Picture__NEU'
        'Picture__ISO' 
        'Picture__ERO'
        };
    
    for n = 1 : numel(fusion_orig)
        for nn = 1 : numel(fusion_orig{n})
            DATA(:,1) = regexprep(DATA(:,1),[fusion_orig{n}{nn} '.*'],fusion_to{n});
        end
    end
    
    events = fusion_to;
    
    names     = cell(size(events));
    onsets    = cell(size(events));
    durations = cell(size(events));
    
    for evt = 1 : length(events)
        NAME = events{evt};
        names{evt,1}  = NAME;
        res = regexp(DATA(:,1),['^' NAME '$']);
        res = ~cellfun(@isempty,res);
        onsets   {evt,1} = cell2mat(DATA(res,2));
        durations{evt,1} = cell2mat(DATA(res,3));
    end
    
    names = regexprep(names,'@','');
    
    save([Files(f).path(1:end-4) '_SPMready' '.mat'],'names','onsets','durations')
    
end

e.getSerie('LIKERTA','name').addStim(fullfile(pwd,'behaviour'), 'MRI_LIKERT_.*A_run\d{2}_SPMready.mat$', 'SPMready')
e.getSerie('LIKERTB','name').addStim(fullfile(pwd,'behaviour'), 'MRI_LIKERT_.*B_run\d{2}_SPMready.mat$', 'SPMready')


%%

save('e_likert_stim','e') % work on this one
