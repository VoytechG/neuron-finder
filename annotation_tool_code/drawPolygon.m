function polygon = drawPolygon(input_img, org_polygon) 
    figure
    img = mat2gray(input_img);
    imshow(img);
    if isempty(org_polygon)
        polygon = drawpolygon('FaceAlpha', 0, 'LineWidth',1,'Color','magenta');
    else
        polygon = drawpolygon('FaceAlpha', 0, 'LineWidth',1,'Color','magenta', 'Position',org_polygon);
    end
    addlistener(polygon,'ROIMoved',@allevents);


    function allevents(src,evt)
        evname = evt.EventName;
        switch(evname)
            case{'ROIMoved'}
                disp(['Polygon moved current position: ' mat2str(evt.CurrentPosition)]);
                polygon = evt.CurrentPosition;
        end
    end
end