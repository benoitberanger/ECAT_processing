clear
clc

main_dir = fullfile(pwd,'nifti');

e = exam(main_dir,'ECAT');

e.addSerie('LIKERT(A|B)$','likert')
e.addVolume('likert','^f','f',3)

e.addSerie('3DT1','anat',1)
e.addVolume('anat','^s.*nii','s',1)

e.getSerie.addJson('json$','j')

dir_func = e.getSerie('likert') .toJob;
dir_anat = e.getSerie('anat').toJob(0);

par.fake = 0;
par.redo = 0;
par.verbose = 2;

par.MNI = 0; % Normalization is NOT done by meica.py


%%

job_meica_afni(dir_func, dir_anat, par);


%% fetch MEICA volumes

e.addSerie('meica','meica',1)
e.getSerie('likert').addVolume('^run\d+_medn.nii','medn',1)


%% segement

par.run = 1;
par.display = 0;

%anat segment
fanat = e.getSerie('anat').getVolume('^s').toJob;

par.GM   = [0 0 1 0]; % Unmodulated / modulated / native_space dartel / import
par.WM   = [0 0 1 0];
j_segment = job_do_segment(fanat,par);
fy    = e.getSerie('anat').addVolume('^y' ,'y' );
fanat = e.getSerie('anat').addVolume('^ms','ms');

%apply normalize on anat
j_apply_normalise=job_apply_normalize(fy,fanat,par);
e.getSerie('anat').addVolume('^wms','wms',1)


%% apply normalization on fmri MEICA volume

e.getSerie('likert').getVolume('medn').unzip
medn_data = e.getSerie('likert').getVolume('medn').toJob;

job_apply_normalize(fy,medn_data,par);
warped_data = e.getSerie('likert').addVolume('^wrun','wrun');


%% Smooth

par.smooth   = [5 5 5];
par.prefix   = 's';
job_smooth(warped_data,par)
smoothed_data = e.getSerie('likert').addVolume('^swrun','swrun');


%%

e.explore

save('e_likert','e')
