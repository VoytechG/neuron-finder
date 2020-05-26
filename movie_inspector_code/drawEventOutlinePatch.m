function px = drawEventOutlinePatch(...
        filterIndex, frameDistanceToPeakFrame, outlines, colors)

    config.drawText = false;

    if frameDistanceToPeakFrame == 0
        color = colors.peakColor;
        lineWidth = 1;
    else
        color = colors.nonPeakColor;
        lineWidth = 1;
    end

    xs = outlines{filterIndex}(:, 1);
    ys = outlines{filterIndex}(:, 2);
    px = patch('XData', xs, 'YData', ys, ...
        'EdgeColor', color, 'FaceColor', 'none', 'LineWidth', lineWidth);

    if config.drawText

        if frameDistanceToPeakFrame > 0
            frameDistanceToPeakFrameString = sprintf('+%d', frameDistanceToPeakFrame);
        else
            frameDistanceToPeakFrameString = sprintf('%d', frameDistanceToPeakFrame);
        end

        % patchLabel = sprintf('(%s) %d', frameDistanceToPeakFrameString, filterIndex);
        patchLabel = frameDistanceToPeakFrameString;
        text('Position', [max(xs) + 2, max(ys) + 2], 'String', patchLabel, ...
            'Color', color, 'FontSize', 16, 'FontWeight', 'Bold');
    end

end
