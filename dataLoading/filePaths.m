paths.mov = 'preprocessed/preprocessedMovie.h5';
paths.extraction_results = 'extracted/resultsPCAICA.mat';
paths.peak_finder_params = 'movie_inspector_code/peakFinderParams.mat';

paths.generateAnnotationsSavePath = @generateAnnotationsSavePath;

function fullpath = generateAnnotationsSavePath(peakFinderParams)
    annotationsDir = 'sorted/';
    filename = sprintf('annotations_%.2f_%d_%.2f.mat', ...
        peakFinderParams.stdToSignalRatioMult, ...
        peakFinderParams.minTimeBtwEvents, ...
        peakFinderParams.minPeakProminence);

    fullpath = strcat(annotationsDir, filename);
end
