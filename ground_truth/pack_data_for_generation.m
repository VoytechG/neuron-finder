run("loadExtractionResults.m")
annotations = annotationsPrev;

%% Get spatial fitler properties
if ~checkIfExistsInWorkspace('areas')
    [areas, centroids, cvxHulls, cvxAreas, outlines, filtersBinary] = ...
        getFilterProps(filters);
end

validEvents = cell(1, no_filters);

no_filters = size(filters, 3);

for i = 1:no_filters

    if annotations.filters(i) == AnnotationLabel.Valid
        matchings = annotations.matchings{i};
        no_events = size(matchings, 2);

        for j = 1:no_events

            if matchings(j) == AnnotationLabel.Valid
                matchingFrame = events{i}(j);
                validEvents{i}(end + 1) = matchingFrame;
            end

        end

    end

end

filtersBinary = logical(filtersBinary);

save dataPackedForGeneration.mat filtersBinary validEvents
