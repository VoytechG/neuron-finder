%% set paths to load/save data
run("filePaths.m");

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
if (~checkIfExistsInWorkspace("eventsComputed"))
    fprintf("Getting event times... ");
    events = getPeaks(p, double(traces));
    % events = removeLowQualityFilters(p, events);
    eventsComputed = true;
    fprintf("Done.\n");
else
    fprintf("Peaks already in the workspace, skipping the computation.\n");
end

%% Load annotation results from previous session
annotationsPrev = loadannotations(paths.annotations);

%% Mark as done for the next session
allExtractionResultsLoaded = true;

%% Helper functions
function annotationsPrev = loadannotations(path)
    if (~checkIfExistsInWorkspace("annotation"))
        if (~isfile(path))
            fprintf("No annotation results found.\n");
            annotationsPrev = [];
        else
            fprintf("Loading annotation results from the previous session... ")
            % load(path, "annotations");
            % annotationsPrev = annotations;
            annotationsPrev = Annotations();
            annotationsPrev.load(path);
            fprintf("Done.\n");
        end
    else
        fprintf("Annotation results already in the workspace, skipping the reload\n");
        annotationsPrev = [];
    end
end




