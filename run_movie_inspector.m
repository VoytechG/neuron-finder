%% load data to workspssace if not loaded
run("loadExtractionResults.m")

%% compute events with custom params

% peakFinderParams = PeakFinderParams();
% peakFinderParams.stdToSignalRatioMult = p.annotation.numStdsForThresh;
% peakFinderParams.minTimeBtwEvents = p.annotation.minTimeBtwEvents;

try 
    load(paths.peak_finder_params);
catch E
    peakFinderParams.stdToSignalRatioMult = 1.5;
    peakFinderParams.minTimeBtwEvents = 4;
end

eventsForFrameInspector = getPeaks(p, double(traces), ...
    peakFinderParams.stdToSignalRatioMult, ...
    peakFinderParams.minTimeBtwEvents);

%% Get spatial fitler properties
if ~checkIfExistsInWorkspace('areas')
    [areas, centroids, cvxHulls, cvxAreas, outlines] = ...
        getFilterProps(filters);
end

%% Display frame veiwer
initialFrame = 100;
eventsForFrames = getEventsForFrames(eventsForFrameInspector, movie);

% crop limits set at the mean min and max brightness values
cropLimits = [-0.045, 0.075];

figure('units', 'normalized', 'outerposition', [0 0 1 1])
displayEventsOnFrame(movie, eventsForFrames, outlines, centroids, ...
    initialFrame, p, traces, peakFinderParams, cropLimits, false, paths);

%% Functions
function eventsForFrames = getEventsForFrames(events, movie)
    eventsForFrames = cell(1, size(movie, 3));

    for filterIndex = 1:length(events)
        filterEvents = events{filterIndex};

        for j = 1:length(filterEvents)
            frameNumber = events{filterIndex}(j);

            if isempty(eventsForFrames{frameNumber})
                eventsForFrames{frameNumber} = {};
            end

            eventsForFrames{frameNumber}{end + 1} = filterIndex;
        end

    end

end

function displayEventsOnFrame(movie, eventsForFrames, outlines, ...
        centroids, frameIndex, p, traces, peakFinderParams, cropLimits, ...
        paramsModified, paths)
    numberOfFrames = size(movie, 3);

    outlinePatches = {};
    cursorPatch = 0;

    colors.peakColor = "0 0 0 0.5";
    colors.nonPeakColor = Color.red;

    createPlot();

    function createPlot()

        % I = movie(:, :, frameIndex);
        % I(I < cropLimits(1)) = cropLimits(1);
        % I(I > cropLimits(2)) = cropLimits(2);
        % I = adapthisteq(I,'Distribution','rayleigh', 'nBins', 1024 * 8);
        % imagesc(I);

        imagesc(movie(:, :, frameIndex), cropLimits);
        colormap parula
        % colormap gray
        setTitle();

        % set (gcf, 'WindowButtonMotionFcn', @onMouseMove);
        set(gcf, 'KeyPressFcn', @onKeyPress);

        outlinePatches = {};

        % On top of peaks in this frame, we also display peaks found before and after
        % this frame. We look back and forth only within the bounds of the minTimeBtwEvents
        % parameter. This is because we inspect only a local maximum. If peak appeared before
        % or after within these bounds, but not in this frame, it means this local scope has
        % a valid maximum. If no peak is shown, it means that in this local neighbourhood no
        % peak at all was detected.
        earliestPossibleFrameOfLocalPeakDetection = ...
            max(1, frameIndex - peakFinderParams.minTimeBtwEvents + 1);

        latestPossibleFrameOfLocalPeakDetection = ...
            min(frameIndex + peakFinderParams.minTimeBtwEvents - 1, numberOfFrames);

        a = earliestPossibleFrameOfLocalPeakDetection;
        b = latestPossibleFrameOfLocalPeakDetection;

        patchIndex = 0;

        for dispFrameIndex = a:b
            numberOfEventsInFrame = length(eventsForFrames{dispFrameIndex});

            for eventIndex = 1:numberOfEventsInFrame
                filterIndex = eventsForFrames{dispFrameIndex}{eventIndex};
                frameDistanceToPeakFrame = dispFrameIndex - frameIndex;
                filterPatch = drawEventOutlinePatch( ...
                    filterIndex, frameDistanceToPeakFrame, outlines, colors);

                patchIndex = patchIndex + 1;
                outlinePatches{patchIndex} = filterPatch;

            end

        end

    end

    

    function setTitle()

        if paramsModified
            save_msg = sprintf('<P> save values for use in cell checker (modifications unsaved)');
        else
            save_msg = sprintf('<P> save values for use in cell checker');
        end

        title(gca, {
        sprintf('Frame %d \n', frameIndex), ...
            sprintf('<A-S> std constant : %.2f', peakFinderParams.stdToSignalRatioMult), ...
            sprintf('<Z-X> min dist btw events : %d', peakFinderParams.minTimeBtwEvents), ...
            save_msg, ...
            newline
        });
    end

    function onKeyPress(~, event)
        % disp(event);
        keyPressed = event.Key;
        % disp(keyPressed);

        if strcmp(keyPressed, 'rightarrow')
            newFrameIndex = limitValue(frameIndex + 1, 1, numberOfFrames);
            displayEventsOnFrame(movie, eventsForFrames, ...
                outlines, centroids, newFrameIndex, p, traces, ...
                peakFinderParams, cropLimits, paramsModified, paths);

        elseif strcmp(keyPressed, 'leftarrow')
            newFrameIndex = limitValue(frameIndex - 1, 1, numberOfFrames);
            displayEventsOnFrame(movie, eventsForFrames, ...
                outlines, centroids, newFrameIndex, p, traces, ...
                peakFinderParams, cropLimits, paramsModified, paths);

        elseif strcmp(keyPressed, 'a')
            peakFinderParams.stdToSignalRatioMult = limitValue(...
                peakFinderParams.stdToSignalRatioMult - 0.1, 0.1, 100);
            paramsModified = true;
            recomputePeaksAndRefresh();

        elseif strcmp(keyPressed, 's')
            peakFinderParams.stdToSignalRatioMult = limitValue(...
                peakFinderParams.stdToSignalRatioMult + 0.1, 0.1, 100);
            paramsModified = true;
            recomputePeaksAndRefresh();

        elseif strcmp(keyPressed, 'z')
            peakFinderParams.minTimeBtwEvents = limitValue(...
                peakFinderParams.minTimeBtwEvents - 1, 0, 100);
            paramsModified = true;
            recomputePeaksAndRefresh();

        elseif strcmp(keyPressed, 'x')
            peakFinderParams.minTimeBtwEvents = limitValue(...
                peakFinderParams.minTimeBtwEvents + 1, 0, 100);
            paramsModified = true;
            recomputePeaksAndRefresh();

        elseif strcmp(keyPressed, 'p')
            save(paths.peak_finder_params, 'peakFinderParams');
            paramsModified = false;
            refresh();

        elseif strcmp(keyPressed, 'q')
            close
        end

    end

    function onMouseMove(~, ~)

        [mouseX, mouseY] = getMouseXYInGca();

        bounds = 500;
        moustIsInsideImage = 0 <= mouseX && mouseX < bounds && 0 <= mouseY && mouseY < 500;

        % TODO remove the title changer
        if ~moustIsInsideImage
            % title(gca, "Cursor outisde figure");
            return
            % else
            % title(gca, ['(X,Y) = (', num2str(mouseX), ', ',num2str(mouseY), ')']);
        end

        for patchIndex = 1:length(outlinePatches)
            px = outlinePatches{patchIndex};
            xs = px.XData;
            ys = px.YData;
            inpolygonTest = inpolygon(mouseX, mouseY, xs, ys);
            inpolygonTest = inpolygonTest(1);

            if inpolygonTest
                px.EdgeColor = 'green';
                px.LineWidth = 3;
                % else
                %     body
            end

        end

    end

    function refresh()
        createPlot();
    end

    function recomputePeaksAndRefresh()

        events = getPeaks(p, double(traces), ...
                peakFinderParams.stdToSignalRatioMult, ...
                peakFinderParams.minTimeBtwEvents);

            eventsForFrames = getEventsForFrames(events, movie);

            refresh();

        end

    end


