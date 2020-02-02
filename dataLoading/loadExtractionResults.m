%% Load movie, PCAICA results

if (~checkIfExistsInWorkspace("movieLoaded"))
    fprintf("Loading the movie and PCAICA results... ");
    
    movie = loadMovie(paths.mov);
    load(paths.extraction_results);
    
    movieLoaded = true;
    fprintf("Done.\n");
else
    fprintf("Movie and PCAICA results already in the workspace, skipping loading.\n")
end

%% Find events 

% get event times
if (~checkIfExistsInWorkspace("peaksComputed"))
    fprintf("Getting event times... ");
    events = getPeaks(p, double(traces));
    peaksComputed = true;
    fprintf("Done.\n");
else
    fprintf("Peaks already in the workspace, skipping the computation.\n");
end

%% Load annotation results from previous session
annotationResultsPrev = loadAnnotationResults(paths.annotation_results);

%% Mark as done for the next session
allExtractionResultsLoaded = true;

%% Helper functions
function annotationResultsPrev = loadAnnotationResults(path)
    if (~checkIfExistsInWorkspace("annotationResult"))
        if (~isfile(path))
            fprintf("No annotation results found.\n");
            annotationResultsPrev = [];
        else
            fprintf("Loading annotation results from the previous session... ")
            load(path, "valid");
            annotationResultsPrev = valid;
            fprintf("Done.\n");
        end
    else
        fprintf("Annotation results already in the workspace, skipping the reload\n");
        annotationResultsPrev = [];
    end
end