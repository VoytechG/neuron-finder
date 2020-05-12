function playEventMovie(movie, cellIdx, trace, eventTime, centroids, cvxHulls, skipCell)
    
    % set display params
    windowSpace = 20;
    windowTime = 20;
    waitTime = 1/(windowTime);
    thisCentroid = centroids(cellIdx,:);
    thisHull = cvxHulls{cellIdx};
    skipCell(cellIdx) = 1;
    centroids = centroids(~skipCell,:);
    cvxHulls = cvxHulls(~skipCell);


    % define borders 
    xLow  = round(max(thisCentroid(2) - (windowSpace-1),1));
    xHigh = min(xLow + 2*windowSpace-1,size(movie,1));
    if length(xLow:xHigh) ~= 2*windowSpace
        xLow = size(movie,1) - (2*windowSpace-1);
    end
    yLow  = round(max(thisCentroid(1) - (windowSpace-1),1));
    yHigh = min(yLow + 2*windowSpace-1,size(movie,2));
    if length(yLow:yHigh) ~= 2*windowSpace
        yLow = size(movie,2) - (2*windowSpace-1);
    end
    zLow  = max(eventTime - (windowTime-1),1);
    zHigh = min(eventTime + windowTime,size(movie,3)); 

    
    % get cvxHulls of neighbors
    cDist = abs(round(bsxfun(@minus,centroids,thisCentroid))); 
    neighborHulls = cvxHulls(cDist(:,1) < 20 & cDist(:,2) < 20);
    offset = [yLow xLow];
    neighborHulls = cellfun(@(x) bsxfun(@minus,x,offset),neighborHulls,'UniformOutput', false);
    thisHull =  bsxfun(@minus,thisHull,offset);

    
    % get cutouts of trace and movie
    movieCutout = movie(xLow:xHigh,yLow:yHigh,zLow:zHigh);
    traceCutout = trace(zLow:zHigh);

    
    % set color values
    minVals=min(movieCutout,[],3);
    maxVals=max(movieCutout,[],3);
    clims = [prctile(minVals(:),50) prctile(maxVals(:),99)];


    f = figure('WindowStyle','normal','Position',[100,200,500,400]);
    for i = 1:size(movieCutout,3)
        % plot movie
        % had to flip first dim of movie
        ax = subplot(3,2,[1:4]);
        hold on
        cropLimits = [-0.045, 0.075];

        imagesc(flipud(movieCutout(:,:,i)), cropLimits);
        colormap(ax,gray)
        set(gca,'CLim',clims)
        set(gca, 'XTick', [], 'YTick', [])

        % plot cvxHulls
        % had to flip values for y part
        plot(thisHull(:,1),abs(thisHull(:,2)-40),'m')
        for j=1:length(neighborHulls)
            plot(neighborHulls{j}(:,1),abs(neighborHulls{j}(:,2)-40),'y')
        end    
        xlim([1 40])
        ylim([1 40])  
        

        % plot trace
        subplot(3,2,[5:6])
        hold off
        plot(1:length(traceCutout),traceCutout,'k')
        hold on
        plot(i,traceCutout(i),'or')
        xlabel('Time (s)')
        ylabel('\Delta F / F')
        % TODO get measures right
        set(gca, 'XTick', [], 'YTick', [])

        pause(waitTime);
    end
    close(f)


end