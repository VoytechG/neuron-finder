function [ areas,centroids,cvxHulls,cvxAreas,outlines ] = getFilterProps( filters )

thresh = 0.6;

for i = 1:size(filters,3)  
    pic = filters(:,:,i);
    pic = pic > thresh*max(pic(:));
    
    % get bigges connected component
    bwcc = bwconncomp(pic);
    [~,maxIdx] = max(cellfun(@(x) length(x),bwcc.PixelIdxList));
    pic(:) = 0;
    pic(bwcc.PixelIdxList{maxIdx}) = 1;
    
    
    props = regionprops(pic,'Area','Centroid','ConvexHull','ConvexArea');
    areas(i) = props.Area;
    centroids(i,:) = props.Centroid;
    cvxHulls{i} = props.ConvexHull;
    cvxAreas(i) = props.ConvexArea;
    
    b = bwboundaries(pic);
    outlines{i} = [b{1}(:,2) b{1}(:,1)];
    
    imshow(pic);
    hold on;
    plot(props.Centroid(1), props.Centroid(2), 'r*');
    
    a=1;

end

