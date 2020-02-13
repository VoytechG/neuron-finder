close all
%% set paths to load/save data
run("filePaths.m");
%% load data to workspssace if not loaded
run("loadExtractionResults.m")

%% set params
p.frameRate = 5;
p.annotation.areaThresh = 0; 
p.annotation.numStdsForThresh = 3;
p.annotation.minTimeBtwEvents = 10;

%% run cellChecker  
% (this might take some time to load)
fprintf("Running cell checker... ");
annotations = cellChecker(...
    p, movie, traces, filters, events, annotationsPrev);
fprintf("Done.\nCell checker exited.\n")

%% basic statistics metadata on annotations

markedFilters = sum(annotations.filters == 1);
totalFilters = length(annotations.filters );
annotations.noteOnFilters = ...
    sprintf("Filters: marked %d / %d", [markedFilters, totalFilters]);

%% save 
save_path = paths.annotations;

fprintf("Saving annotation results... ");
save(save_path, 'annotations');
fprintf("Done.\n")