import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf

from load_data import MOVIE_LEN, FRAME_SHAPE
from data_gen import DataGenerator
from unet_basic.model_3d import unet3d

gen = DataGenerator()

FRAME_NEW_SHAPE = (256, 256)
DATASET_SIZE = 64

indices = np.random.choice(MOVIE_LEN, DATASET_SIZE, replace=False)

X = np.array([gen.get_x(i) for i in indices])
Y = np.array([gen.get_y(i) for i in indices])

vfunc = np.vectorize(lambda img: tf.image.resize(img, FRAME_NEW_SHAPE))

X = vfunc(X)
Y = vfunc(Y)

model = unet3d(input_size=(8, 256, 256, 1))
