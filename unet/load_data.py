import scipy.io
import matplotlib.pyplot as plt
import numpy as np
import h5py

MOVIE_LEN = 11998
FRAME_H = 500
FRAME_W = 500
FRAME_SHAPE = (FRAME_H, FRAME_W)


def load_ground_truth_generation_data(path):

    """
    filters_binary 
    600 x 500 x 500 bool

    events_in_frames 
    11998 x {eventsInThisFrame} int

    events_for_filters 
    600 x {eventsForThisFilter} int

    filter_centroids 
    600 x 2 int
    """
    ground_truth_generation_data = scipy.io.loadmat(path)

    # 600 x 500 x 500 bool
    filters_binary = ground_truth_generation_data["filtersBinary"]
    filters_binary = np.array(
        [
            np.array(filters_binary[:, :, i]).transpose()
            for i in range(np.shape(filters_binary)[2])
        ],
        dtype=np.bool,
    )

    # 11998 x {eventsInThisFrame} int
    events_in_frames = ground_truth_generation_data["eventsInFrames"]
    events_in_frames = np.array(
        [events_in_frames[0, i][0] - 1 for i in range(np.shape(events_in_frames)[1])]
    )

    # 600 x {eventsForThisFilter} int
    events_for_filters = ground_truth_generation_data["eventsForFilters"]
    events_for_filters = np.array(
        [
            events_for_filters[0, i][0] - 1
            for i in range(np.shape(events_for_filters)[1])
        ]
    )

    # 600 x 2 int
    filter_centroids = ground_truth_generation_data["filterCentroids"]
    filter_centroids = [[y, x] for [x, y] in filter_centroids]
    return [filters_binary, events_for_filters, filter_centroids, events_in_frames]


def load_movie(path):
    f = h5py.File(path, "r")
    movie = f["/1"]
    return movie
