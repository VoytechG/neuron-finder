%% Load movie, PCAICA results,

mov_path = 'C:\Users\wojci\Desktop\UCL 4th\AB Spikes\example_code_original\example_code\preprocessed\preprocessedMovie.h5';
extraction_results_path = 'C:\Users\wojci\Desktop\UCL 4th\AB Spikes\example_code_original\example_code\extracted\resultsPCAICA.mat';
save_path = 'C:\Users\wojci\Desktop\UCL 4th\AB Spikes\example_code_original\example_code\sorted\annotationResult';

if (~checkIfExistsInWorkspace("movieLoaded"))
    fprintf("Loading the movie and PCAICA results... ");
    
    movie = loadMovie(mov_path);
    load(extraction_results_path);
    
    movieLoaded = true;
    fprintf("Done...\n");
else
    fprintf("Movie and PCAICA results already in the workspace, skipping loading.\n")
end


%% find events 

% get event times
if (~checkIfExistsInWorkspace("peaksComputed"))
    fprintf("Getting event times... ");
    events = getPeaks(p, double(traces));
    peaksComputed = true;
    fprintf("Done.\n");
else
    fprintf("Peaks already in the workspace, skipping the computation.\n");
end

function exists = checkIfExistsInWorkspace(varName)
    checkCommand = sprintf('exist(''%s'',''var'') == 1', varName);
    exists = evalin( 'base', checkCommand );
end