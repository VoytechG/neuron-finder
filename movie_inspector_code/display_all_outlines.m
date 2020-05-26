run("loadExtractionResults.m")

cropLimits = [-0.045, 0.075];
colors.peakColor = "0 0 0 0.5";
colors.nonPeakColor = Color.red;

drawAllOutlines(cropLimits, colors, movie, filters, outlines);

function drawAllOutlines(cropLimits, colors, movie, filters, outlines)
    imagesc(zeros(size(movie(:, :, 1))), cropLimits);

    outlinePatches = {};

    for i = 1:size(filters, 3)
        outlinePatches{i} = ...
            drawEventOutlinePatch(i, 0, outlines, colors);
    end

%     set(gcf, 'WindowButtonMotionFcn', @onMouseMove);

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
                px.EdgeColor = 'black';
                px.LineWidth = 0.5;
                %     body
            end

        end

    end

end
