% if isempty(areas)
%     [ areas,centroids,cvxHulls,cvxAreas,outlines ] = ...
%         getFilterProps( filters );
% end
%
% imagesc(movie(:,:,1))
% colormap gray

%% extract events for each frame and filter features

% if ~checkIfExistsInWorkspace('eventsForFrames')
eventsForFrames = cell(1, size(movie, 3));
for filterIndex = 1:length(events)
    filterEvents = events{filterIndex};
    for j = 1:length(filterEvents)
        frameNumber = events{filterIndex}(j);
        if isempty(eventsForFrames{frameNumber})
            eventsForFrames{frameNumber} = {};
        end
        eventsForFrames{frameNumber}{end + 1} = filterIndex;
        %             fprintf("%d %d\n", filterIndex, frameNumber);
        %             pause(0.1);
    end
end
% end

if ~checkIfExistsInWorkspace('areas')
    [areas,centroids,cvxHulls,cvxAreas,outlines] = ...
        getFilterProps( filters );
end


%% display
displayEventsOnFrame(movie, eventsForFrames, outlines, centroids);

function displayEventsOnFrame(movie, eventsForFrames, outlines, centroids)

    frameIndex = 19;
    imagesc(movie(:, :, frameIndex))
    % imagesc(filters(:, :, eventsForFrames{frameIndex}{2}));
    colormap gray

    outlinePatches = {};
    for i = 1:length(eventsForFrames{frameIndex})
        filterIndex = eventsForFrames{frameIndex}{i};
        disp(filterIndex);
        xs = outlines{filterIndex}(:, 1);
        ys = outlines{filterIndex}(:, 2);
        px = patch('XData', xs, 'YData', ys, ...
            'EdgeColor','red','FaceColor','none','LineWidth', 2);

        text('Position', [max(xs) + 2, max(ys) + 2], ...
            'String', sprintf("%d", filterIndex), ...
            'Color', 'red', 'FontSize', 16, 'FontWeigth', 'Bold');
        
        outlinePatches{end + 1} = px;
        
        xs = [centroids(filterIndex, 1), centroids(filterIndex, 1) + 0.1];
        ys = [centroids(filterIndex, 2), centroids(filterIndex, 2) + 0.1];
        patch('XData', xs, 'YData', ys, ...
            'EdgeColor','red','FaceColor','red','LineWidth', 2);
    end

    set (gcf, 'WindowButtonMotionFcn', @onMouseMove);

    function onMouseMove(~, ~)
        
        [mouseX, mouseY] = getMouseXYInGca();
        
        % TODO remove the title changer
        bounds = 500;
        if 0 <= mouseX && mouseX < bounds && 0 <= mouseY && mouseY < 500
            title(gca, ['(X,Y) = (', num2str(mouseX), ', ',num2str(mouseY), ')']);
        else
            title(gca, "Cursor outisde figure");
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

    function [mouseX, mouseY] = getMouseXYInGca()
        C = get (gca, 'CurrentPoint');
        mouseX = C(1,1);
        mouseY = C(1,2);
    end
end

