function [valid, validf] = cellChecker(p, movie, traces, filters, events, annotationResultsPrev, varargin)

statuses.valid = ["Marked as valid", "green"];
statuses.invalid = ["Marked as invalid", "red"];
statuses.unmarked = ["Not Marked", "black"];
statuses.contaminated = ["Marked as contaminated", "yellow"];

stats = [statuses.invalid, statuses.valid, ...
    statuses.unmarked, statuses.contaminated];

% set params
% number of filters
nCells=size(filters,3);
currentIdx = 1;

eventMontages=cell(length(events),1);


persistent markings
if isempty(markings)
    % TODO Refactor the size
    markings = zeros(600, 100) + 2;
    disp("declaring markings for the first time");
end

% TODO Set properly
validf = []; 

% preallocate output
if (isempty(annotationResultsPrev))
    valid = -1*ones(nCells,1);
else
    valid = annotationResultsPrev;
end

%% get necessary data

persistent areas;
persistent centroids; 
persistent outlines;
if isempty(areas)
    [ areas,centroids,~,~,outlines ] = getFilterProps( filters );
end



%% exclude cells that are too small or have no events

tooSmall = areas <= p.annotation.areaThresh;
noEvents = cellfun(@(x) isempty(x),events);
skipCell = noEvents | tooSmall;

%% Go through each cell

h=figure('units','normalized','outerposition',[0 0 1 1]);
finished=0;
lastDir=1;
i = 0;
startFlag = 1;
polygon = [];
loopCounter = 0;

while ~finished
    
    loopCounter =  loopCounter + 1;
    %         disp(loopCounter);
    % set indices
    if i ~= currentIdx
        i = currentIdx;
        eventIdx = 1;
        [~,eventOrder] = sort(traces(i,events{i}),'descend');
    else
        eventIdx = eventIdx+1;
        if eventIdx > length(eventOrder)
            eventIdx = 1;
        end
    end
    
    
    
    if ~skipCell(i)
        
        no_events = size(events{i}, 2);
        max_marker = no_events+1;
        
        %% plot data
        filter = filters(:,:,i);
        %plot filter
        figure(h)
        subplot(2,4,1);
        imagesc(filter);
        xlim([1,size(filters,2)])
        ylim([1,size(filters,1)])
        axis off
        title('Spatial Filter')
        
        % plot average transient
        subplot(2,4,2);
        hold on
        % get cutouts around events
        transMat = [];
        for e = 1:no_events
            if events{i}(e)>20 && events{i}(e) < size(traces,2)-30
                thisTrans = traces(i,events{i}(e)-20:events{i}(e)+30);
                transMat = cat(1,transMat,thisTrans);
            end
        end
        if ~isempty(transMat)
            plot(-20:1:30,transMat','k')
            plot(-20:1:30,mean(transMat,1),'r','LineWidth',2)
            set(gca,'xlim',[-20 30],'ylim',[min(transMat(:)) max(transMat(:))],'ytick',[])
            set(gca,'XTick',[-20,30])
            set(gca,'XTickLabel',[0 50]/p.frameRate)
            xlabel('Time (s)')
        end
        clear e transMat
        title('Mean Transient')
        
        
        % Plot whole trace
        subplot(2,4,[5 6]);
        plot(traces(i,:),'k')
        if ~isempty(events{i})
            hold on
            plot(events{i},traces(i,events{i}),'r*');
            hold off
        end
        set(gca,'ylim',[min(traces(i,:)) max(traces(i,:))])
        set(gca,'YTick',[])
        title('Full Activity Trace')
        set(gca,'XTick',[0,size(traces,2)])
        set(gca,'XTickLabel',[0 size(traces,2)/(p.frameRate*60)])
        xlabel('Time (min)')
        
        % plot event montage
        subplot(2,4,[3 4 7 8]);
        
        
        if isempty(eventMontages{i})
            title('Loading snapshots...')
            eventMontages{i} = getEventMontage(events{i}, traces(i,:), movie, centroids(i,:), filters(:,:,i));
        end
        montage = eventMontages{i};
        imagesc(montage)
        title(['Snapshots of ' num2str(length(events{i})) ' events']);
        axis off
        
        gridA = ceil(sqrt(max_marker));
        
        setPatchForMouseMove(gridA, size(montage), max_marker);
        
        %         height = size(montage, 1) / gridA;
        %         width = size(montage, 2) / gridA;
        %         markerPosX = floor((marker-1)/gridA) * width;
        %         markerPosY = (mod(marker-1 , gridA)) * height;
        %         xs = [0, 0, 1, 1] * width;
        %         ys = [0, 1, 1, 0] * height;
        %         patch('XData', xs + markerPosX, 'YData', ys + markerPosY,...
        %             'EdgeColor','green','FaceColor','none','LineWidth',2);
        
        %         for j = 2:max_marker
        %             status = markings(i, j);
        %             color = stats((status+1)*2);
        %             markerPosX = floor((j-1)/gridA) * width;
        %             markerPosY = (mod(j-1 , gridA)) * height;
        %             circles(markerPosX + width * 0.9, ...
        %                 markerPosY + height * 0.1, ...
        %                 min(width, height)* 0.1, ...
        %                 'facecolor',color)
        %         end
        
        
        status = valid(i);
        
        desc = stats((status+1)*2-1);
        color = stats((status+1)*2);
        
        suptitle(sprintf('Press h for instructions\nCandidate %d of %d \n \\color{%s}%s',...
            currentIdx-sum(skipCell(1:currentIdx)),...
            sum(~skipCell), ...
            color, ...
            desc))
        
        %% define button actions
        if startFlag
            showInstructions
            startFlag = 0;
        end
        figure(h);
        set(h, 'CurrentCharacter', 'k');
        waitforbuttonpress();
        reply=get(h, 'CurrentCharacter');
        
        if strcmpi(reply,'m') % event movie
            playEventMovie(movie, i, traces(i,:), events{i}(eventOrder(eventIdx)), centroids, outlines, skipCell)
        elseif strcmpi(reply,'y')   % valid
            valid(i) = 1;
            %             currentIdx=currentIdx+1;
            lastDir=1;
        elseif strcmpi(reply,'n')   % invalid
            valid(i) = 0;
            %             currentIdx=currentIdx+1;
            lastDir=1;
        elseif strcmpi(reply, 'c')  % contaminated
            valid(i)=3;
            %             currentIdx=currentIdx+1;
            lastDir=1;
        elseif strcmpi(reply, 'f')  % forward
            currentIdx=currentIdx+1;
            lastDir=1;
        elseif strcmpi(reply, 'b')  % backward
            currentIdx=currentIdx-1;
            lastDir=-1;
        elseif strcmpi(reply,'q')   % quit
            finished=1;
        elseif strcmpi(reply,'h')   % display instructions
            showInstructions
        elseif strcmpi(reply,'w')   % display instructions
            marker = max(marker - 1, min_marker);
        elseif strcmpi(reply,'s')   % display instructions
            marker = min(marker + 1, max_marker );
        elseif strcmpi(reply,'a')   % display instructions
            marker = max(marker - gridA, min_marker);
        elseif strcmpi(reply,'d')   % display instructions
            marker = min(marker + gridA, max_marker);
        elseif strcmpi(reply, 'z')
            markings(i, marker) = 1;
        elseif strcmpi(reply, 'x')
            markings(i, marker) = 0;
            
            
            %             elseif strcmpi(reply,'d')
            %                 drawPolygon(filter, polygon)
            
        end
        
    else
        valid(i)=0;
        currentIdx=currentIdx+lastDir;
    end
    
    % when reaching end, show finishing dialog, if cells were skipped go back to 1
    if currentIdx>nCells
        currentIdx=1;
        if sum(valid == -1) == 0
            finishingDialog
            finished = 1;
        end
    elseif currentIdx<1
        currentIdx=nCells;
    end
end

close(h)
end


function showInstructions
d = dialog('Position',[600 300 800 400],'Name','Instructions');

txt = uicontrol('Parent',d,...
    'Style','text',...
    'FontSize',14,...
    'Position',[100 100 200 200],...
    'String',{'Annotation Keys','','y = yes','n = no', 'c = maybe', 'd = draw polygon'});

txt = uicontrol('Parent',d,...
    'Style','text',...
    'FontSize',14,...
    'Position',[500 100 200 200],...
    'String',{'Navigation Keys','','f = forward','b = back','m = show event movie','q = quit'});

btn = uicontrol('Parent',d,...
    'KeyPressFcn','delete(gcf)',...
    'FontSize',14,...
    'Position',[300 50 200 70],...
    'String','Resume',...
    'Callback','delete(gcf)');
end


function finished = finishingDialog
d = dialog('Position',[300 300 400 200],'Name','The End');
finished = 0;
txt = uicontrol('Parent',d,...
    'Style','text',...
    'FontSize',14,...
    'Position',[50 50 300 100],...
    'String','You are done!');
btn = uicontrol('Parent',d,...
    'Position',[150 20 100 20],...
    'String','Ok',...
    'Callback','delete(gcf)');
end


function setPatchForMouseMove(squareGridLength, imgDim, no_events)

px = patch([0, 1, 1, 0] * 10, [0, 0, 1, 1] * 10, 'g');
set (gcf, 'WindowButtonMotionFcn', @movePatch);

    function movePatch (~, ~)
        C = get (gca, 'CurrentPoint');
        mouseX = C(1,1);
        mouseY = C(1,2);
        
        % TODO remove the title changer
        title(gca, ['(X,Y) = (', num2str(mouseX), ', ',num2str(mouseY), ')']);
        
        markerIndexUnderCursor = mousePositionToMarker( ...
            squareGridLength, imgDim, mouseX, mouseY, no_events );
        
        [selectionBoxX, selectionBoxY] = selectionBoxFromMarkerIndex( ...
            markerIndexUnderCursor, imgDim, squareGridLength );
        
        px.XData = selectionBoxX;
        px.YData = selectionBoxY;
        
    end

    function markerIndexUnderCursor = ...
            mousePositionToMarker(squareGridLength, imgDim, mouseX, mouseY, no_events)
        
        imgHeight = imgDim(1);
        imgWidth = imgDim(2);
        
        mouseX_rel = limitValue(mouseX, 0, imgWidth) / imgWidth;
        mouseY_rel = limitValue(mouseY, 0, imgHeight) / imgHeight;
        
        grid_x = min(floor(mouseX_rel * squareGridLength), squareGridLength - 1);
        grid_y = min(floor(mouseY_rel * squareGridLength), squareGridLength - 1);
        
        markerIndexUnderCursor = squareGridLength * grid_x + grid_y + 1;
        markerIndexUnderCursor = ...
            limitValue(markerIndexUnderCursor, 2, no_events);
    end

    function [selectionBoxX, selectionBoxY] = ...
            selectionBoxFromMarkerIndex(markerIndex, imgDim, squareGridLength)
        imgHeight = imgDim(1);
        imgWidth = imgDim(2);
        
        markerHeight = imgHeight / squareGridLength;
        markerWidth = imgWidth / squareGridLength;
        xs = [0, 0, 1, 1] * markerWidth;
        ys = [0, 1, 1, 0] * markerHeight;
        
        markerPosX = floor((markerIndex - 1) / squareGridLength) * markerWidth;
        markerPosY = (mod(markerIndex - 1 , squareGridLength)) * markerHeight;
        
        empiricallyDeterminedOffset = 0.5;
        selectionBoxX = xs + markerPosX + empiricallyDeterminedOffset;
        selectionBoxY = ys + markerPosY + empiricallyDeterminedOffset;
    end

    function value = limitValue(value, Min, Max)
        value = min(value, Max);
        value = max(value, Min);
    end

end
