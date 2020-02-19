classdef Annotations < handle
    
    properties (Access = public)
        % filters : [AnnotationLabel]
        filters

        % matchings : {[AnnotationLabel]}  for each filter, for each matching a A   
        matchings
    end

    methods (Access = private)
        function filterIntegerLabels = filterAnnotationLabelsToIntegerLabeles(obj)
            filterIntegerLabels = arrayfun( ...
                @(annotationLabel) annotationLabel.numericalEncoding, obj.filters ...
            );
        end

        function filterAnnotationLabels = filterIntegerLabelsToAnnotationLabels(~, integerLabels)
            filterAnnotationLabels = arrayfun( ...
                @(integerLabel) AnnotationLabel.getLabelByNumberCode(integerLabel), integerLabels ...
            );          
        end

        function matchingsIntegerLabels = matchingsAnnotationLabelsToIntegersLabels(obj) 
            matchingsIntegerLabels = cellfun( ...
                @(filterMatchings) arrayfun( ... 
                    @(matchingAnnotationLabel) matchingAnnotationLabel.numericalEncoding, ...
                    filterMatchings ...
                ), ...
                obj.matchings, "un", 0 ...
            );
        end

        function matchingAnnotationLabels = matchingsIntegerLabelsToAnnotationLabels(~, integerLabels)
            matchingAnnotationLabels = cellfun( ...
                @(filterMatchings) arrayfun( ...
                    @(matchingIntegerLabel) AnnotationLabel.getLabelByNumberCode(matchingIntegerLabel), ...
                    filterMatchings ...
                ), ...
                integerLabels, "un", 0 ...
            );
        end
    end

    methods

        %% constructor

        function obj = Annotations(numberOfFilters)
            
            if nargin > 0 
                filters(1:numberOfFilters) = AnnotationLabel.NotAnnotated;
                matchings = cell(1, numberOfFilters);
            else
                filters = [];
                matchings = {};
            end
            
            obj.filters = filters;
            obj.matchings = matchings;
        end


        %% Filters

        % function annotateFilter(obj, filterIndex, annotationLabel)
        %     obj.filters(filterIndex) = annotationLabel;
        % end

        % function annotationLabel = getFilterAnnotationLabel(obj, filterIndex)
        %     annotationLabel = obj.filters(filterIndex);
        % end

        function len = getFiltersNumber(obj)
            len = length(obj.filters);
        end


        %% Matchings

        function isAllocated = isMatchingsArrayAllocated(obj, filterIndex)
            isAllocated = ~isempty(obj.matchings{filterIndex});
        end

        function allocateMatchingsArrayIfNotAllocated(obj, filterIndex, numberOfMatchings)
            if (isempty(obj.matchings{filterIndex}))
                matchings_new(1:numberOfMatchings) = AnnotationLabel.NotAnnotated;
                obj.matchings{filterIndex} = matchings_new;
            else
                warning( ...
                    sprintf("Matching annotations for the filter no. %d", filterIndex) + ...
                    sprintf("have already been preallocated. Aborting new allocation") ...
                );
            end
        end

        % function annotateMatching(obj, filterIndex, matchingIndex, annotationLabel)
        %     filterMatchings = obj.matchigs{filterIndex};


        %     if (isempty(filterMatchings))
        %         msgID = ExceptionID.notAllocated;
        %         msgtext = sprintf("Memory Matchings for this filter (index no. %d) were not allocated. ", filterIndex) + ...
        %               sprintf("Please specify the number of mathcings ") + ...
        %               sprintf("for this filter (index no. %d) by calling obj.allocateMatchingsArrayIfNotAllocated()", filterIndex);

        %               MException(msgID,msgtext)


        %     elseif (length(filterMatchings) < matchingIndex) 
        %         msgID = ExceptionID.indexOutOfRange;
        %         msgtext = sprintf("Memory Matchings for this filter (index no. %d) were not allocated. ", filterIndex) + ...
        %               sprintf("Before annotating matchings for this filter, please specify the number of mathcings ") + ...
        %               sprintf("for this filter (index no. %d) by calling obj.allocateMatchingsArrayIfNotAllocated()", filterIndex);

        %               MException(msgID,msgtext)

        %     else
        %         obj.matchigs{filterIndex}(matchingIndex) = annotationLabel;  

        %     end
        % end

        % function annotationLabel = getMatchingAnnotation(obj, filterIndex, matchingIndex)
        %     annotationLabel = obj.matchigs{filterIndex}(matchingIndex);
        % end

        function len = getMatchingsLength(obj, filterIndex)
            len = length(obj.matchings{filterIndex});
        end


        %% I/O
    
        function save(obj, savePath)
            fprintf("Saving annotation results... ");

            numberOfAnnotatedFilters = sum(obj.filters ~= AnnotationLabel.NotAnnotated);
            numberOfFilters = length(obj.filters);
            
            annotations.filters = obj.filterAnnotationLabelsToIntegerLabeles();
            annotations.matchings = obj.matchingsAnnotationLabelsToIntegersLabels();
            annotations.noteOnFilters = sprintf( ...
                "Filters: marked %d / %d", ...
                [numberOfAnnotatedFilters, numberOfFilters] ...
            );
            
            %% save
            save(savePath, "annotations");
            fprintf("Done.\n");
        end

        function obj = load(obj, loadPath)
            fprintf("Loading annotations...");

            load(loadPath, "annotations");
            
            obj.filters = obj.filterIntegerLabelsToAnnotationLabels(annotations.filters);
            obj.matchings = obj.matchingsIntegerLabelsToAnnotationLabels(annotations.matchings);

            fprintf("Done.\n");
        end
    end

end


