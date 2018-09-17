clear
clc

load e_likert_stim.mat

model_name = 'model_1';


%% Prepare paths and regexp

par.display=0;
par.run=1;
par.verbose = 2;


%% dirs & files


dirFonc = e.getSerie('likert').toJob;
dirStats = e.mkdir(model_name);
onsetFile = e.getSerie('likert').getStim('SPMready').toJob;


%% Specify

par.TR=1.6;
par.rp = 1;
par.file_reg  = '^swrun.*nii'; %le nom generique du volume pour les fonctionel
job_first_level_specify(dirFonc,dirStats,onsetFile,par);


%% Estimate

fspm = e.addModel(model_name,model_name);
save('e_likert_model.mat','e') % work on this one

job_first_level_estimate(fspm,par);


%% Contrast : definition

trash        = [1 0 0 0 0];
Likert       = [0 1 0 0 0];
Picture__NEU = [0 0 1 0 0];
Picture__ISO = [0 0 0 1 0];
Picture__ERO = [0 0 0 0 1];


contrast.names = {
    
'trash'
'Likert'
'Picture__NEU'
'Picture__ISO'
'Picture__ERO'

'Picture__NEU - trash'
'Picture__ISO - trash'
'Picture__ERO - trash'

'Picture__NEU - Likert'
'Picture__ISO - Likert'
'Picture__ERO - Likert'

'Picture__ISO - Picture__NEU'
'Picture__ISO - Picture__ERO'

'Picture__NEU - Picture__ISO'
'Picture__NEU - Picture__ERO'

'Picture__ERO - Picture__ISO'
'Picture__ERO - Picture__NEU'

}';

contrast.values = {
    
trash
Likert
Picture__NEU
Picture__ISO
Picture__ERO

Picture__NEU - trash
Picture__ISO - trash
Picture__ERO - trash

Picture__NEU - Likert
Picture__ISO - Likert
Picture__ERO - Likert

Picture__ISO - Picture__NEU
Picture__ISO - Picture__ERO

Picture__NEU - Picture__ISO
Picture__NEU - Picture__ERO

Picture__ERO - Picture__ISO
Picture__ERO - Picture__NEU

}';

contrast.types = cat(1,repmat({'T'},[1 length(contrast.names)]));

%% Contrast : write

par.run = 1;
par.display = 0;
par.sessrep = 'repl';
par.delete_previous = 1;

job_first_level_contrast(fspm,contrast,par);

%% Display

e.getModel(model_name).show
