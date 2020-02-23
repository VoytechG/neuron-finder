%% load data to workspssace if not loaded
run("loadExtractionResults.m")


%% compute events with custom params 
peakFinderParams = PeakFinderParams();
peakFinderParams.stdToSignalRatioMult = p.annotation.numStdsForThresh;
peakFinderParams.minTimeBtwEvents = p.annotation.minTimeBtwEvents;

events = getPeaks(p, double(traces), ...
    peakFinderParams.stdToSignalRatioMult, ...
    peakFinderParams.minTimeBtwEvents);


%% Get spatial fitler properties 
if ~checkIfExistsInWorkspace('areas')
    [areas,centroids,cvxHulls,cvxAreas,outlines] = ...
        getFilterProps( filters );
end


%% Display frame veiwer
initialFrame = 1234;
eventsForFrames = getEventsForFrames(events, movie);
displayEventsOnFrame(movie, eventsForFrames, outlines, centroids, ...
     initialFrame, p, traces, peakFinderParams);


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
    centroids, frameIndex, p, traces, peakFinderParams)
    outlinePatches = {};

    createPlot();

    function createPlot() 

        imagesc(movie(:, :, frameIndex))
        % colormap gray
        setTitle();
    
        set (gcf, 'WindowButtonMotionFcn', @onMouseMove);
        set (gcf, 'KeyPressFcn', @onKeyPress);
    
        numberOfEventsInFrame = length(eventsForFrames{frameIndex});

        for eventIndex = 1:numberOfEventsInFrame
            filterIndex = eventsForFrames{frameIndex}{eventIndex};
    
            xs = outlines{filterIndex}(:, 1);
            ys = outlines{filterIndex}(:, 2);
            px = patch('XData', xs, 'YData', ys, ...
                'EdgeColor','red','FaceColor','none','LineWidth', 2);
    
            text('Position', [max(xs) + 2, max(ys) + 2], ...
                'String', sprintf('%d', filterIndex), ...
                'Color', 'red', 'FontSize', 16, 'FontWeight', 'Bold');
            
            outlinePatches{eventIndex} = px;
            
            xs = [centroids(filterIndex, 1), centroids(filterIndex, 1) + 0.1];
            ys = [centroids(filterIndex, 2), centroids(filterIndex, 2) + 0.1];
    
            patch('XData', xs, 'YData', ys, ...
                'EdgeColor','red','FaceColor','red','LineWidth', 2);
        end

    end

    function setTitle()

        % if nargin == 0
        %     peakCalculationPending = 0;
        % end

        % disp("settign title");

        % if peakCalculationPending
        %     topLine = sprintf('Frame %d (peak calculation pending)\n', frameIndex);
        % else
        %     topLine = sprintf('Frame %d \n', frameIndex);
        % end

        title(gca, {
            sprintf('Frame %d \n', frameIndex) , ...
            sprintf('<A-S> std constant : %.2f', peakFinderParams.stdToSignalRatioMult), ...
            sprintf('<Z-X> min dist btw events : %d \n', peakFinderParams.minTimeBtwEvents) ...
        });
    end

    function onKeyPress(~,event)
        % disp(event);
        keyPressed = event.Key;
        % disp(keyPressed);
        
        numberOfFrames = size(movie, 3);

        if strcmp(keyPressed, 'rightarrow')
            newFrameIndex = limitValue(frameIndex + 1, 1, numberOfFrames);
            displayEventsOnFrame(movie, eventsForFrames, ... 
                outlines, centroids, newFrameIndex, p, traces, peakFinderParams);

        elseif strcmp(keyPressed, 'leftarrow')
            newFrameIndex = limitValue(frameIndex - 1, 1, numberOfFrames);
            displayEventsOnFrame(movie, eventsForFrames, ...
                outlines, centroids, newFrameIndex, p, traces, peakFinderParams);
                
        elseif strcmp(keyPressed, 'a')
            peakFinderParams.stdToSignalRatioMult = limitValue( ...
                peakFinderParams.stdToSignalRatioMult - 0.1, 0.1, 100);
            recomputePeaksAndRefresh();

        elseif strcmp(keyPressed, 's')
            peakFinderParams.stdToSignalRatioMult = limitValue( ...
                peakFinderParams.stdToSignalRatioMult + 0.1, 0.1, 100);
            recomputePeaksAndRefresh();
    
        elseif strcmp(keyPressed, 'z')
            peakFinderParams.minTimeBtwEvents = limitValue( ...
                peakFinderParams.minTimeBtwEvents - 1, 0, 100);
            recomputePeaksAndRefresh();
            
        elseif strcmp(keyPressed, 'x')
            peakFinderParams.minTimeBtwEvents = limitValue( ...
                peakFinderParams.minTimeBtwEvents + 1, 0, 100);
            recomputePeaksAndRefresh();

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
            else
                px.EdgeColor = 'red';
                px.LineWidth = 2;
            end
        end
        
    end

    function recomputePeaksAndRefresh() 

        events = getPeaks(p, double(traces), ...
            peakFinderParams.stdToSignalRatioMult, ...
            peakFinderParams.minTimeBtwEvents);

        eventsForFrames = getEventsForFrames(events, movie);
        
        disp("Already got peaks")
        % displayEventsOnFrame(movie, eventsForFrames, ... 
        %     outlines, centroids, frameIndex, p, traces, peakFinderParams);
        createPlot();

    end

end

