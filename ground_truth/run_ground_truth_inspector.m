run("loadExtractionResults.m")
load(paths.peak_finder_params, 'peakFinderParams');
load(paths.generateGroundTruthSavePath(peakFinderParams, framesToGenerate), 'groundTruth');

displayMovieAndGT(movie, groundTruth, 1);

function displayMovieAndGT(movie, groundTruth, frameIndex)

    numberOfFrames = size(groundTruth, 3);
    draw();

    function draw()
        t = tiledlayout(2, 2);
        title(t, sprintf('Frame %d \n', frameIndex));

        % Top plot
        nexttile([2 1])
        cropLimits = [-0.045, 0.075];
        imagesc(movie(:, :, frameIndex), cropLimits);

        % Bottom plot
        nexttile([2 1])
        imageOverlay = movie(:, :, frameIndex) + ...
            groundTruth(:, :, frameIndex) * cropLimits(2);
        imagesc(imageOverlay, cropLimits);

        set(gcf, 'KeyPressFcn', @onKeyPress);
    end

    function onKeyPress(~, event)
        keyPressed = event.Key;

        if strcmp(keyPressed, 'rightarrow')
            newFrameIndex = limitValue(frameIndex + 1, 1, numberOfFrames);
            displayMovieAndGT(movie, groundTruth, newFrameIndex);

        elseif strcmp(keyPressed, 'leftarrow')
            newFrameIndex = limitValue(frameIndex - 1, 1, numberOfFrames);
            displayMovieAndGT(movie, groundTruth, newFrameIndex);

        elseif strcmp(keyPressed, 'q')
            close
        end

    end

end
