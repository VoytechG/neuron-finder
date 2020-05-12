%   close all
%% load data to workspssace if not loaded
run("loadExtractionResults.m")

%% set paramsq
p.frameRate = 5;
p.annotation.areaThresh = 0; 
p.annotation.numStdsForThresh = 3;
p.annotation.minTimeBtwEvents = 10;

%% run cellChecker  
% (this might take some time to load)
fprintf("Running cell checker. \n");
annotations = cellChecker(...
    p, movie, traces, filters, events, annotationsPrev, peakFinderParams, paths);
fprintf("Done.\nCell checker exited.\n")