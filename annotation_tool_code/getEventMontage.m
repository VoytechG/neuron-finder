function [eventMontage, eventImageCorrs, pairwiseEventImageCorrs] = getEventMontage(eventTimes, cellTrace, DFOF, imgCentroid, cellImage, varargin)

options.calcPairwise=0;



[~,inds]=sort(cellTrace(eventTimes),'descend');
eventTimes=eventTimes(inds);
eventImageCorrs=zeros(length(eventTimes),1);

if ~isempty(eventTimes)
    w=15;
    imgCentroid(1)=min(imgCentroid(1),size(DFOF,2));
    imgCentroid(2)=min(imgCentroid(2),size(DFOF,1));
    xLims=max(1,round(imgCentroid(1)-w)):min(size(DFOF,2), round(imgCentroid(1)+w));
    yLims=max(1,round(imgCentroid(2)-w)):min(size(DFOF,1), round(imgCentroid(2)+w));
    imgCentroid(1)=min(round(imgCentroid(1))-min(xLims)+1,length(xLims));
    imgCentroid(2)=min(round(imgCentroid(2))-min(yLims)+1,length(yLims));

    eventImages=DFOF(:,:,eventTimes);
    eventImages=eventImages(yLims,xLims,:);

    sqSide=ceil(sqrt(length(eventTimes)+1));
    imgCell=cell(sqSide,sqSide);
    minVal=min(eventImages(:));
    maxVal=max(eventImages(:));
    for j=1:numel(imgCell)
        if j==1
            imgCell{j}=single(cellImage(yLims, xLims)+1);
            imgCell{j}=(imgCell{j}-min(imgCell{j}(:)));
            imgCell{j}=imgCell{j}/max(imgCell{j}(:))*max(eventImages(:)-minVal)+minVal;
            imgCell{j}(imgCentroid(2), imgCentroid(1))=minVal;
        elseif j-1<=length(eventTimes)
            imgCell{j}=single(eventImages(:,:,j-1));
            imgCell{j}(imgCentroid(2), imgCentroid(1))=minVal;
            C=corrcoef(imgCell{1}(:),imgCell{j}(:));
            eventImageCorrs(j-1)=C(1,2);
        else
            if maxVal>1
                imgCell{j}=ones(size(eventImages(:,:,1)), 'single');
            else
                imgCell{j}=zeros(size(eventImages(:,:,1)), 'single');
            end
        end
    end
    eventMontage=cell2mat(imgCell);
    
    if options.calcPairwise
        
        pairwiseEventImageCorrs=ones(length(eventTimes));
        for i=1:length(eventTimes)
            for j=i+1:length(eventTimes)
                C=corrcoef(imgCell{i+1}(:),imgCell{j+1}(:));
                pairwiseEventImageCorrs(i,j)=C(1,2);
                pairwiseEventImageCorrs(j,i)=C(1,2);
            end
        end
    end
else
    eventMontage=[];
end


