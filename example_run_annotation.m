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

%% Markgins
if ~checkIfExistsInWorkspace('markings')
    % TODO Refactor the size
    disp("declaring markings for the first time");
    markings = zeros(600, 100, 'int8') + 2;
    
end

%% run cellChecker  
% (this might take some time to load)
fprintf("Running cell checker... ");
[filterLabels, filterMatchingLabels, markings] = cellChecker(...
    p, movie, traces, filters, events, annotationResultsPrev, markings);
fprintf("Done.\nCell checker exited.\n")

%% save 
save_path = paths.annotation_results;
annotationIsComplete = (sum(valid == -1) == 0);

fprintf("Saving annotation results... ");
save(save_path, 'filterLabels', 'filterMatchingLabel');
fprintf("Done.\n")