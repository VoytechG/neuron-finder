function [valid] = cellChecker(p, movie, traces, filters, events, varargin)

statuses.valid = ["Marked as valid", "green"];
statuses.invalid = ["Marked as invalid", "red"];
statuses.unmarked = ["Not Marked", "black"];
statuses.contaminated = ["Marked as contaminated", "yellow"];

% set params
% number of filters
nCells=size(filters,3);
currentIdx = 1;

% preallocate output
valid = -1*ones(nCells,1);
%% get necessary data

[ areas,centroids,cvxHulls,cvxAreas,outlines ] = getFilterProps( filters );

% get event montages
eventMontages=cell(length(events),1);
% for cInd=1:length(events)
%      eventMontages{cInd} = getEventMontage(events{cInd}, traces(cInd,:), movie, centroids(cInd,:), filters(:,:,cInd));
% end

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

while ~finished   
    
    
    
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
        for e = 1:length(events{i})
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
        subplot(2,4,[3 4 7 8])
        if isempty(eventMontages{i})
            title('Loading snapshots...')
            eventMontages{i} = getEventMontage(events{i}, traces(i,:), movie, centroids(i,:), filters(:,:,i));
        end
        imagesc(eventMontages{i})
        title(['Snapshots of ' num2str(length(events{i})) ' events'])
        axis off

        status = valid(i);
        
        if status == 0
            description = statuses.invalid;
        elseif status == 1
            description = statuses.valid;
        elseif status == 3
            description = statuses.contaminated;
        else
            description = statuses.unmarked;
        end
            
        desc = description(1);
        color = description(2);
        
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
        elseif strcmpi(reply,'d')
            drawPolygon(filter, polygon)
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
    