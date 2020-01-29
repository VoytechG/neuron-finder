close all
%% set paths to load/save data
run("filePaths.m");

%% load data to workspace if not loaded
run("loadExtractionResults.m")

%% set params
p.frameRate = 5;
p.annotation.areaThresh = 0; 
p.annotation.numStdsForThresh = 3;
p.annotation.minTimeBtwEvents = 10;

%% run cellChecker  
% (this might take some time to load)
fprintf("Running cell checker... ");
[valid, validf] = cellChecker(p, movie, traces, filters, events, annotationResultsPrev);
fprintf("Done.\nCell checker exited.\n")

%% save 
save_path = paths.annotation_results;
annotationIsComplete = (sum(valid == -1) == 0);

fprintf("Saving annotation results... ");
save(save_path, 'valid', 'annotationIsComplete');
fprintf("Done.\n")