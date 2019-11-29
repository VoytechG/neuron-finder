

img = imread('filter1.png');
figure
imshow(img);
p = drawpolygon('FaceAlpha', 0, 'LineWidth',7,'Color','cyan');
addlistener(p,'ROIMoved',@allevents);


function allevents(src,evt)
    evname = evt.EventName;
    switch(evname)
        case{'MovingROI'}
            disp(['ROI moving previous position: ' mat2str(evt.PreviousPosition)]);
            disp(['ROI moving current position: ' mat2str(evt.CurrentPosition)]);
        case{'ROIMoved'}
            disp(['ROI moved previous position: ' mat2str(evt.PreviousPosition)]);
            disp(['ROI moved current position: ' mat2str(evt.CurrentPosition)]);
    end
end