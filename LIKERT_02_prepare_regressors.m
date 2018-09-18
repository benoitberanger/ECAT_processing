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
    
    % boxcar onsets -------------------------------------------------------
    
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
    
    % parametric modulators -----------------------------------------------
    
    LIKERT = S.BR.Data;
    
    if mod(size(LIKERT,1),2)~=0
        error('beahaviour result is odd : incomplete')
    end
    
    v = (1:size(LIKERT,1))'; % osef
    AIME   = LIKERT(~(mod(v,2)==0),:);
    DESIRE = LIKERT( (mod(v,2)==0),:);
    
    AIME_ISO   =   AIME( ~cellfun( @isempty, regexp(  AIME(:,1),'^ISO') ) , : );
    AIME_ERO   =   AIME( ~cellfun( @isempty, regexp(  AIME(:,1),'^ERO') ) , : );
    
    DESIRE_ISO = DESIRE( ~cellfun( @isempty, regexp(DESIRE(:,1),'^ISO') ) , : );
    DESIRE_ERO = DESIRE( ~cellfun( @isempty, regexp(DESIRE(:,1),'^ERO') ) , : );
    
    pmod(4).name {1} = 'AIME_ISO';
    pmod(4).param{1} = cell2mat(AIME_ISO  (:,end));
    pmod(4).poly {1} = 1;
    
    pmod(4).name {2} = 'DESIRE_ISO';
    pmod(4).param{2} = cell2mat(DESIRE_ISO(:,end));
    pmod(4).poly {2} = 1;
    
    pmod(5).name {1} = 'AIME_ERO';
    pmod(5).param{1} = cell2mat(AIME_ERO  (:,end));
    pmod(5).poly {1} = 1;
    
    pmod(5).name {2} = 'DESIRE_ERO';
    pmod(5).param{2} = cell2mat(DESIRE_ERO(:,end));
    pmod(5).poly {2} = 1;
    
    orth = num2cell(zeros(size(names)));
    
    save([Files(f).path(1:end-4) '_SPMready' '.mat'],'names','onsets','durations','pmod','orth')
    
end

e.getSerie('LIKERTA','name').addStim(fullfile(pwd,'behaviour'), 'MRI_LIKERT_.*A_run\d{2}_SPMready.mat$', 'SPMready')
e.getSerie('LIKERTB','name').addStim(fullfile(pwd,'behaviour'), 'MRI_LIKERT_.*B_run\d{2}_SPMready.mat$', 'SPMready')


%%

save('e_likert_stim','e') % work on this one
