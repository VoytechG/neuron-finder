import numpy as np
from load_data import (
    MOVIE_LEN,
    FRAME_SHAPE,
    load_movie,
    load_ground_truth_generation_data,
)
import tensorflow as tf
from cv2 import resize
import cv2 as cv
import skimage
from sklearn.model_selection import train_test_split
from tensorflow.keras.utils import Sequence


class DataGenerator:
    def __init__(
        self,
        movie,
        ground_truth_generation_data,
        spatial_dim=(256, 256),
        temporal_dim=8,
        positive_label_weight=100,
        sample_weight_function=None,
    ):
        self.movie = movie
        [
            filters_binary,
            events_for_filters,
            filter_centroids,
            events_in_frames,
        ] = ground_truth_generation_data
        self.filters_binary = filters_binary
        self.events_for_filters = events_for_filters
        self.filter_centroids = filter_centroids
        self.events_in_frames = events_in_frames
        self.spatial_dim = spatial_dim
        self.temporal_dim = temporal_dim
        self.positive_label_weight = positive_label_weight
        self.sample_weight_function = sample_weight_function

    def get_frame(self, index):
        frame_tranposed = self.movie[index]
        return np.array(frame_tranposed).transpose()

    def get_y(self, frame_index):
        """

        Arguments:
            frame_index {int}

        Returns:
            500x500 binary image, 
            ground truth image for this index
        """
        ground_truth = np.zeros_like(self.filters_binary[0], dtype=np.bool)
        events_in_this_frame = self.events_in_frames[frame_index]

        if len(events_in_this_frame) > 0:
            for fb in self.filters_binary[events_in_this_frame]:
                ground_truth = np.maximum(ground_truth, fb)

        if self.spatial_dim:
            ground_truth = resize(
                np.uint8(ground_truth), self.spatial_dim, interpolation=cv.INTER_NEAREST
            )

        y = np.array(ground_truth, dtype=np.bool).reshape(np.shape(ground_truth) + (1,))

        return y

    def get_x_range(self, frame_index):
        temporal_dim = self.temporal_dim
        p = frame_index - temporal_dim // 2 + 1
        q = frame_index + temporal_dim // 2

        if temporal_dim % 2 == 1:
            q = frame_index + temporal_dim // 2 + 1

        p = max(0, p)
        q = min(q, MOVIE_LEN - 1)

        return list(range(p, q + 1))

    def get_x(self, frame_index):
        """

        Arguments:
            frame_index {int} 

        Keyword Arguments:
            temporal_dim {int} -- (default: {8})

        Returns:
            4D tensor -- temporal_dim x spatial_dim x spatial_dim x 1
        """
        indices_range = self.get_x_range(frame_index)

        frames_raw = self.movie[indices_range]

        if self.spatial_dim:
            frames_raw = [
                skimage.transform.resize(img, self.spatial_dim, anti_aliasing=False)
                for img in frames_raw
            ]

        x = np.array(frames_raw).reshape(np.shape(frames_raw) + (1,))

        return x

    def get_sample_weight(self, frame_index):
        indices_range = self.get_x_range(frame_index)
        ys = [self.get_y(i) for i in indices_range]
        if self.sample_weight_function is not None:
            sample_weight_y = self.sample_weight_function(ys)
        else:
            sample_weight_y = sum(ys)
            sample_weight_y = np.minimum(sample_weight_y, np.ones_like(sample_weight_y))
            sample_weight_y = sample_weight_y * (self.positive_label_weight - 1) + 1

        return sample_weight_y


class DataSequencer(Sequence):
    def __init__(
        self,
        indices,
        movie,
        ground_truth_generation_data,
        batch_size=32,
        spatial_dim=(256, 256),
        temporal_dim=8,
        positive_label_weight=100,
        sample_weight_function=None,
        shuffle=True,
    ):
        self.indices = indices
        self.batch_size = batch_size
        self.spatial_dim = spatial_dim
        self.positive_label_weight = positive_label_weight
        self.sample_weight_function = sample_weight_function
        self.shuffle = shuffle
        self.on_epoch_end()
        self.gen = DataGenerator(
            movie,
            ground_truth_generation_data,
            spatial_dim=spatial_dim,
            temporal_dim=temporal_dim,
            positive_label_weight=positive_label_weight,
            sample_weight_function=sample_weight_function,
        )

    def __len__(self):
        return len(self.indices) // self.batch_size

    def __getitem__(self, index):

        indices = self.indices[index * self.batch_size : (index + 1) * self.batch_size]

        batch_X, batch_y, batch_sample_weights = self.__data_generation(indices)

        return batch_X, batch_y, batch_sample_weights

    def on_epoch_end(self):
        if self.shuffle == True:
            np.random.shuffle(self.indices)

    def __data_generation(self, indices):
        X = np.array([self.gen.get_x(i) for i in indices])
        batch_X = np.concatenate(X, 0).reshape((len(X),) + X[0].shape)

        batch_y = np.array([self.gen.get_y(i) for i in indices])

        batch_sample_weights = np.array(
            [self.gen.get_sample_weight(i) for i in indices]
        )

        return batch_X, batch_y, batch_sample_weights

    def get_all_data(self):
        all_X, all_y = self.__data_generation(self.indices)
        return (all_X, all_y)

    def data_generator(self):
        i = 0
        while True:
            X = self.gen.get_x(self.indices[i])
            y = self.gen.get_y(self.indices[i])
            i = (i + 1) % len(self.indices)

            yield (X, y)


def batch_generator(batch_size=16, spatial_dim=(256, 256)):
    gen = DataGenerator(spatial_dim=spatial_dim)
    while True:
        indices = np.random.choice(MOVIE_LEN - 16, batch_size, replace=False)

        X = np.array([gen.get_x(i) for i in indices])
        batch_X = np.concatenate(X, 0).reshape((batch_size,) + X[0].shape)

        batch_y = np.array([gen.get_y(i) for i in indices])

        yield (batch_X, batch_y)


def get_indices_split(indices, data_fraction=1, random_state=(42, 27)):
    if data_fraction != 1:
        np.random.seed(random_state[0])
        np.random.shuffle(indices)
        dataset_size = int(np.round(len(indices) * data_fraction))
        indices = indices[:dataset_size]

    indices_train, indices_test, _, _ = train_test_split(
        indices, indices, test_size=0.25, random_state=random_state[0]
    )
    indices_train, indices_validate, _, _ = train_test_split(
        indices_train, indices_train, test_size=0.25, random_state=random_state[1]
    )
    return indices_train, indices_validate, indices_test
