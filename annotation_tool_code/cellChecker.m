% p - parameters used for whole-pipeline calculations
% movie - 500x500x11998: the source movie
% filters - 500x500x600: ICA filters
% traces - 600x11998: ICA filter reponses for each frame
% events - 1x600 cell: 600 ICAs entries, list of peaks for each

function annotations = cellChecker(p, movie, traces, filters, events, ...
        annotationsPrev, peakFinderParams, paths, startIndex)

    % set params
    % number of filters
    nFilters = size(filters, 3);
    currentIdx = startIndex;

    persistent eventMontages
    eventMontages = cell(length(events), 1);

    %% preallocate annotations space
    if (isempty(annotationsPrev))
        annotations = Annotations(nFilters);
    else
        annotations = annotationsPrev;
    end

    %% get necessary data
    persistent areas;
    persistent centroids;
    persistent outlines;
    persistent binaryThrsFilters;

    if isempty(areas)
        [areas, centroids, ~, ~, outlines, binaryThrsFilters] = getFilterProps(filters);
    end

    %% exclude cells that are too small or have no events

    tooSmall = areas <= p.annotation.areaThresh;
    numberOfEvents = cellfun(@(x) isempty(x), events);
    skipCell = numberOfEvents | tooSmall;

    %% Go through each cell

    h = figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    finished = false;
    lastDir = 1;
    i = 0;
    startFlag = 1;
    loopCounter = 0;

    modificationsSaved = true;

    while ~finished

        loopCounter = loopCounter + 1;

        % set indices
        if i ~= currentIdx
            i = currentIdx;
            eventIdx = 1;
            [~, eventOrder] = sort(traces(i, events{i}), 'descend');
        end

        if ~skipCell(i)

            no_events = size(events{i}, 2);

            %% plot data
            filter = filters(:, :, i);
            %plot filter
            figure(h)
            subplot(2, 4, 1);
            imagesc(filter);
            xlim([1, size(filters, 2)])
            ylim([1, size(filters, 1)])
            axis off
            title('Spatial Filter')

            % plot average transient
            subplot(2, 4, 2);
            hold on
            % get cutouts around events
            transMat = [];

            for e = 1:no_events

                if events{i}(e) > 20 && events{i}(e) < size(traces, 2) - 30
                    thisTrans = traces(i, events{i}(e) - 20:events{i}(e) + 30);
                    transMat = cat(1, transMat, thisTrans);

                end

            end

            if ~isempty(transMat)
                plot(-20:1:30, transMat', 'k')
                plot(-20:1:30, mean(transMat, 1), 'r', 'LineWidth', 2)
                set(gca, 'xlim', [-20 30], 'ylim', [min(transMat(:)) max(transMat(:))], 'ytick', [])
                set(gca, 'XTick', [-20, 30])
                set(gca, 'XTickLabel', [0 50] / p.frameRate)
                xlabel('Time (s)')
            end

            clear e transMat
            title('Mean Transient')

            % Plot whole trace
            subplot(2, 4, [5 6]);
            plot(traces(i, :), 'k')

            if ~isempty(events{i})
                hold on
                plot(events{i}, traces(i, events{i}), 'r*');
                hold off
            end

            % if ~isempty(events{i})
            %     hold on
            %     for eventIndex = 1:no_events
            %         ann = annotations.matchings{i}(eventIndex);
            %         if ann == AnnotationLabel.Valid
            %             peakColor = 'g*';
            %         elseif ann == AnnotationLabel.Invalid
            %             peakColor = 'r*';
            %         else
            %             peakColor = 'b*';
            %         end
            %         plot(events{i}(eventIndex),traces(i,events{i}(eventIndex)), peakColor);
            %     end
            %     hold off
            % end
            set(gca, 'ylim', [min(traces(i, :)) max(traces(i, :))])
            set(gca, 'YTick', [])
            title('Full Activity Trace')
            set(gca, 'XTick', [0, size(traces, 2)])
            set(gca, 'XTickLabel', [0 size(traces, 2) / (p.frameRate * 60)])
            xlabel('Time (min)')

            % plot event montage
            subplot(2, 4, [3 4 7 8]);

            if isempty(eventMontages{i})
                title('Loading snapshots...')
                eventMontages{i} = ...
                    getEventMontage(events{i}, traces(i, :), movie, ...
                    centroids(i, :), filters(:, :, i), binaryThrsFilters(:, :, i));
            end

            montage = eventMontages{i};
            imagesc(montage)
            title(['Snapshots of ' num2str(length(events{i})) ' events']);
            axis off

            if (~annotations.isMatchingsArrayAllocated(i))
                numberOfMatchings = length(events{i});
                annotations.allocateMatchingsArrayIfNotAllocated(i, numberOfMatchings);
            end

            numberOfImageTilesDisplayed = no_events + 1;
            gridA = ceil(sqrt(numberOfImageTilesDisplayed));

            setPatchForMouseMove(gridA, size(montage), no_events);

            filterAnnotation = annotations.filters(i);
            desc = filterAnnotation.description;
            color = filterAnnotation.color;

            pr = @sprintf;
            saveMessages = {
            'Modifications not saved (press S to save)', ...
                'Annotations saved'
            };
            headerMessages = {
            pr('Press h for instructions'), ...
                pr('Candidate %d of %d ', currentIdx - sum(skipCell(1:currentIdx)), sum(~skipCell)), ...
                pr('%s', saveMessages{modificationsSaved + 1}), ...
                pr('%s', desc)
            };
            % header = '';
            % for message = headerMmessages
            %     header = header + message;
            % end
            suptitle(headerMessages);

            %% define button actions
            if startFlag
                % showInstructions
                startFlag = 0;
            end

            figure(h);
            set(h, 'CurrentCharacter', 'k');
            keyWasPressed = 1;

            while (waitforbuttonpress() ~= keyWasPressed)
            end

            reply = get(h, 'CurrentCharacter');

            if strcmpi(reply, 'm')% event movie
                playEventMovie(movie, i, traces(i, :), events{i}(eventOrder(eventIdx)), centroids, outlines, skipCell)
            elseif strcmpi(reply, 'y')% valid
                annotations.filters(i) = AnnotationLabel.Valid;
                annotations.matchings{i}(:) = AnnotationLabel.Valid;
                modificationsSaved = false;
                lastDir = 1;
            elseif strcmpi(reply, 'n')% invalid
                annotations.filters(i) = AnnotationLabel.Invalid;
                annotations.matchings{i}(:) = AnnotationLabel.Invalid;
                modificationsSaved = false;
                lastDir = 1;
                % elseif strcmpi(reply, 'c')% contaminated
                %     annotations.filters(i) = AnnotationLabel.Contaminated;
                %     modificationsSaved = false;
                %     lastDir = 1;
            elseif strcmpi(reply, 'f') || strcmpi(reply, '.')% forward
                currentIdx = currentIdx + 1;
                lastDir = 1;
            elseif strcmpi(reply, 'b') || strcmpi(reply, ',')% backward
                currentIdx = currentIdx - 1;
                lastDir = -1;
            elseif strcmpi(reply, 'q')% quit
                finished = 1;
                saveAnnotations();
            elseif strcmpi(reply, 'h')% display instructions
                showInstructions
            elseif strcmpi(reply, 's')
                saveAnnotations();

                %             elseif strcmpi(reply,'d')
                %                 drawPolygon(filter, polygon)

            end

        else
            %         annotations(i)=0;
            currentIdx = currentIdx + lastDir;
        end

        % when reaching end, show finishing dialog, if cells were skipped go back to 1
        if currentIdx > nFilters
            currentIdx = 1;

            if sum(annotations.filters == -1) == 0
                finishingDialog
                finished = 1;
            end

        elseif currentIdx < 1
            currentIdx = nFilters;
        end

    end

    close(h)

    function showInstructions
        d = dialog('Position', [600 300 800 400], 'Name', 'Instructions');

        txt = uicontrol('Parent', d, ...
            'Style', 'text', ...
            'FontSize', 14, ...
            'Position', [100 100 200 200], ...
            'String', {'Annotation Keys', '', 'y = yes', 'n = no', 's = save'});

        txt = uicontrol('Parent', d, ...
            'Style', 'text', ...
            'FontSize', 14, ...
            'Position', [500 100 200 200], ...
            'String', {'Navigation Keys', '', 'f || . = forward', 'b || , = back', 'm = show event movie', 'q = quit'});

        btn = uicontrol('Parent', d, ...
            'KeyPressFcn', 'delete(gcf)', ...
            'FontSize', 14, ...
            'Position', [300 50 200 70], ...
            'String', 'Resume', ...
            'Callback', 'delete(gcf)');
    end

    function finished = finishingDialog
        d = dialog('Position', [300 300 400 200], 'Name', 'The End');
        finished = 0;
        txt = uicontrol('Parent', d, ...
            'Style', 'text', ...
            'FontSize', 14, ...
            'Position', [50 50 300 100], ...
            'String', 'You are done!');
        btn = uicontrol('Parent', d, ...
            'Position', [150 20 100 20], ...
            'String', 'Ok', ...
            'Callback', 'delete(gcf)');
    end

    function setPatchForMouseMove(squareGridLength, imgDim, no_events)

        selectionFramePatch = patch('XData', [0], 'YData', [0], ...
            'EdgeColor', 'green', 'FaceColor', 'none', 'LineWidth', 2);
        set(gcf, 'WindowButtonMotionFcn', @movePatch);

        markingCirclePatches = generateMarkingSelectionPatches(no_events);
        set(gcf, 'WindowButtonDownFcn', @clickOnPatch)

        function movePatch(~, ~)

            % TODO remove the title changer
            % title(gca, ['(X,Y) = (', num2str(mouseX), ', ',num2str(mouseY), ')']);

            markerIndexUnderCursor = getRectangleMarkerIndexUnderCursor(...
                squareGridLength, imgDim, no_events);

            matchingIndex = markerIndexUnderCursor - 1;
            eventIdx = matchingIndex;

            [selectionBoxX, selectionBoxY] = selectionBoxFromMarkerIndex(...
                markerIndexUnderCursor, imgDim, squareGridLength);

            selectionFramePatch.XData = selectionBoxX;
            selectionFramePatch.YData = selectionBoxY;

        end

        function clickOnPatch(~, ~)
            markerIndexUnderCursor = getRectangleMarkerIndexUnderCursor(...
                squareGridLength, imgDim, no_events);

            matchingIndex = markerIndexUnderCursor - 1;

            m = annotations.matchings{i}(matchingIndex);

            if ismember(m, [AnnotationLabel.Invalid, AnnotationLabel.NotAnnotated])
                m = AnnotationLabel.Valid;
                annotations.filters(i) = m;
            else
                m = AnnotationLabel.Invalid;
            end

            annotations.matchings{i}(matchingIndex) = m;
            markingCirclePatches{markerIndexUnderCursor}.FaceColor = m.color;

            modificationsSaved = false;
        end

        function selectionPatches = generateMarkingSelectionPatches(no_events)
            selectionPatches = {};

            [~, ~, markerHeight, markerWidth] = ...
                getRectangleMarkerPositionAndDimensions(2, imgDim, squareGridLength);

            radius = min(markerHeight, markerWidth) / 15;

            for j = 1:no_events

                [circle_x, circle_y] = getCircleCoordinates(radius);
                filterAnnotation = annotations.matchings{i}(j);

                selectionColor = filterAnnotation.color;
                rectangleMarkerIndexOfEvent = j + 1;

                [markerPosX, markerPosY, ~, ~] = ...
                    getRectangleMarkerPositionAndDimensions(...
                    rectangleMarkerIndexOfEvent, imgDim, squareGridLength ...
                    );

                padding = radius * 1.5;
                posX = markerPosX + markerWidth - padding;
                posY = markerPosY + padding;

                newSelectionPatch = patch(...
                    'XData', posX + circle_x, ...
                    'YData', posY + circle_y, ...
                    'EdgeColor', 'black', ...
                    'FaceColor', selectionColor, ...
                    'LineWidth', 1.5);

                selectionPatches{rectangleMarkerIndexOfEvent} = newSelectionPatch;
            end

        end

        function [mouseX, mouseY] = getMouseXYInGca()
            C = get(gca, 'CurrentPoint');
            mouseX = C(1, 1);
            mouseY = C(1, 2);
        end

        function [X, Y] = getCircleCoordinates(radius)

            if nargin < 1
                radius = 1;
            end

            t = linspace(0, 2 * pi);
            r = radius;
            X = r * cos(t);
            Y = r * sin(t);
        end

        function markerIndexUnderCursor = ...
                getRectangleMarkerIndexUnderCursor(squareGridLength, imgDim, no_events)

            [mouseX, mouseY] = getMouseXYInGca();

            imgHeight = imgDim(1);
            imgWidth = imgDim(2);

            mouseX_rel = limitValue(mouseX, 0, imgWidth) / imgWidth;
            mouseY_rel = limitValue(mouseY, 0, imgHeight) / imgHeight;

            grid_x = min(floor(mouseX_rel * squareGridLength), squareGridLength - 1);
            grid_y = min(floor(mouseY_rel * squareGridLength), squareGridLength - 1);

            numberOfImageTilesDisplayed = no_events + 1;
            markerIndexUnderCursor = squareGridLength * grid_x + grid_y + 1;
            markerIndexUnderCursor = ...
                limitValue(markerIndexUnderCursor, 2, numberOfImageTilesDisplayed);
        end

        function [selectionBoxX, selectionBoxY] = ...
                selectionBoxFromMarkerIndex(markerIndex, imgDim, squareGridLength)

            [markerPosX, markerPosY, markerHeight, markerWidth] = ...
                getRectangleMarkerPositionAndDimensions(markerIndex, imgDim, squareGridLength);

            xs = [0, 0, 1, 1] * markerWidth;
            ys = [0, 1, 1, 0] * markerHeight;
            empiricallyDeterminedOffset = 0.5;

            selectionBoxX = xs + markerPosX + empiricallyDeterminedOffset;
            selectionBoxY = ys + markerPosY + empiricallyDeterminedOffset;
        end

        function [markerPosX, markerPosY, markerHeight, markerWidth] = ...
                getRectangleMarkerPositionAndDimensions(markerIndex, imgDim, squareGridLength)

            imgHeight = imgDim(1);
            imgWidth = imgDim(2);

            markerHeight = imgHeight / squareGridLength;
            markerWidth = imgWidth / squareGridLength;

            markerPosX = floor((markerIndex - 1) / squareGridLength) * markerWidth;
            markerPosY = (mod(markerIndex - 1, squareGridLength)) * markerHeight;
        end

    end

    function saveAnnotations()

        savePath = paths.generateAnnotationsSavePath(peakFinderParams);
        annotations.save(savePath);
        modificationsSaved = true;

    end

end
