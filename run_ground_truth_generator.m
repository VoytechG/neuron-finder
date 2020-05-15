%% load data to workspace if not loaded
run("loadExtractionResults.m")

annotations = annotationsPrev;

%% Get spatial fitler properties
if ~checkIfExistsInWorkspace('areas')
    [areas, centroids, cvxHulls, cvxAreas, outlines, filtersBinary] = ...
        getFilterProps(filters);
end

framesToGenerate = 100;

no_filters = size(filters, 3);
no_frames = size(movie, 3);

events_in_frame = cell(1, no_frames);

frameHeight = size(movie, 1);
frameWidth = size(movie, 2);

groundTruth = zeros(frameHeight, frameWidth, framesToGenerate);

for i = 1:no_filters

    filterBinary = filtersBinary(:, :, i);

    if annotations.filters(i) == AnnotationLabel.Valid
        matchings = annotations.matchings{i};
        no_events = size(matchings, 2);

        for j = 1:no_events

            matchingFrame = events{i}(j);

            if matchingFrame <= framesToGenerate && ...
                    matchings(j) == AnnotationLabel.Valid
                groundTruth(:, :, matchingFrame) = ...
                    groundTruth(:, :, matchingFrame) + filterBinary;
            end

        end

    end

end

save(paths.generateGroundTruthSavePath(peakFinderParams), 'groundTruth');
