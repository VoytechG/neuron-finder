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

    %% Load peakFinderParams
    try
        load(paths.peak_finder_params);
    catch E
        ME = MException('Peak finder params not found. Please save them with video inspector first.');
        throw(ME);
    end

    % get event times
    if ~checkIfExistsInWorkspace("eventsComputed")
        fprintf("Getting event times... ");

        events = getPeaks(p, double(traces), ...
                peakFinderParams.stdToSignalRatioMult, ...
                peakFinderParams.minTimeBtwEvents, ...
                peakFinderParams.minPeakProminence);

            % skip removing low wuality filters, this can be done by human correction
            % events = removeLowQualityFilters(p, events);

            eventsComputed = true;
            fprintf("Done.\n");
        else
            fprintf("Peaks already in the workspace, skipping the computation.\n");
        end

        %% Load annotation results from previous session
        generatedAnnotationsPath = paths.generateAnnotationsSavePath(peakFinderParams);

        if ~checkIfExistsInWorkspace("annotationsPath") ||~strcmp(annotationsPath, generatedAnnotationsPath)
            annotationsPath = generatedAnnotationsPath;
            annotationsPrev = loadannotations(annotationsPath);
        end

        %% Helper functions
        function annotationsPrev = loadannotations(path)

            if (~checkIfExistsInWorkspace("annotationsLoaded") || annotationsLoaded ~= path)

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

                annotationsLoaded = path;

            else
                fprintf("Annotation results already in the workspace, skipping the reload\n");
                annotationsPrev = [];
            end

        end
