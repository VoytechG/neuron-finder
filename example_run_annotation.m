%% load extraction results and set params
clear

p.frameRate = 5;
p.annotation.areaThresh = 0; 
p.annotation.numStdsForThresh = 3;
p.annotation.minTimeBtwEvents = 10;

mov_path = 'C:\Users\wojci\Desktop\UCL 4th\AB Spikes\example_code_original\example_code\preprocessed\preprocessedMovie.h5';
extraction_results_path = 'C:\Users\wojci\Desktop\UCL 4th\AB Spikes\example_code_original\example_code\extracted\resultsPCAICA.mat';
save_path = 'C:\Users\wojci\Desktop\UCL 4th\AB Spikes\example_code_original\example_code\sorted\annotationResult';

movie = loadMovie(mov_path);
load(extraction_results_path);


%% find events and run GUI

% get event times
events = getPeaks(p, double(traces));

% run cellChecker (this might take some time to load)
valid = cellChecker(p, movie, traces, filters, events);


%% save 

if sum(valid == -1) == 0
    disp('Annotation complete, saving results')
    filters = filters(:,:,valid == 1);
    traces = traces(valid == 1,:);
    save(save_path,'valid','filters','traces')
else
    disp('Annotation is not complete, saving intermediate annotation results')
    save([save_path,'_intermediate'],'valid','filters','traces')
end