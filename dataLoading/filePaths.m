paths.mov = 'preprocessed/preprocessedMovie.h5';
paths.extraction_results = 'extracted/resultsPCAICA.mat';
paths.peak_finder_params = 'movie_inspector_code/peakFinderParams.mat';

paths.generateAnnotationsSavePath = @generateAnnotationsSavePath;

function fullpath = generateAnnotationsSavePath(peakFinderParams)
  annotationsDir = 'sorted/';
  filename = sprintf('annotations_%f_%d.mat', ... 
    peakFinderParams.stdToSignalRatioMult, ...
    peakFinderParams.minTimeBtwEvents);

  fullpath = strcat(annotationsDir, filename);
end