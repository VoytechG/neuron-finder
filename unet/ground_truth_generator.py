import scipy.io
import matplotlib.pyplot as plt
import numpy as np
from load_movie import load_movie

movie = load_movie('../preprocessed/preprocessedMovie.h5')

groundTruthGenerationData = scipy.io.loadmat('../dataPackedForGeneration.mat')


# 600 x 500 x 500 bool
filtersBinary = groundTruthGenerationData['filtersBinary']
filtersBinary = np.array([
    filtersBinary[:, :, i] for i in range(np.shape(filtersBinary)[2])
], dtype=np.bool)

# 11998 x {eventsInThisFrame} int
eventsInFrames = groundTruthGenerationData['eventsInFrames']
eventsInFrames = np.array([
    eventsInFrames[0, i][0]
    for i
    in range(np.shape(eventsInFrames)[1])
])

# 600 x {eventsForThisFilter} int
eventsForFilters = groundTruthGenerationData['eventsForFilters']
eventsForFilters = np.array([
    eventsForFilters[0, i][0]
    for i
    in range(np.shape(eventsForFilters)[1])
])

# 600 x 2 int
filterCentroids = groundTruthGenerationData['filterCentroids']
