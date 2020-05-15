run("loadExtractionResults.m")
annotations = annotationsPrev;

%% Get spatial fitler properties
if ~checkIfExistsInWorkspace('areas')
    [areas, centroids, cvxHulls, cvxAreas, outlines, filtersBinary] = ...
        getFilterProps(filters);
end

no_frames = size(movie, 3);
no_filters = size(filters, 3);

eventsForFilters = cell(1, no_filters);
eventsInFrames = cell(1, no_frames);
filterCentroids = centroids;

for i = 1:no_filters

    if annotations.filters(i) == AnnotationLabel.Valid
        matchings = annotations.matchings{i};
        no_events = size(matchings, 2);

        for j = 1:no_events

            if matchings(j) == AnnotationLabel.Valid
                matchingFrame = events{i}(j);
                eventsForFilters{i}(end + 1) = matchingFrame;
                eventsInFrames{matchingFrame}(end + 1) = i;
            end

        end

    end

    filterCentroids(i, 1) = round(filterCentroids(i, 1));
    filterCentroids(i, 2) = round(filterCentroids(i, 2));
end

filtersBinary = logical(filtersBinary);

save dataPackedForGeneration.mat filtersBinary eventsInFrames eventsForFilters filterCentroids
