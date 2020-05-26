import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from tensorflow.keras.utils import Sequence

from load_data import MOVIE_LEN, FRAME_SHAPE
from data_gen import DataGenerator
from unet_basic.model_3d import unet3d_simply

FRAME_NEW_SHAPE = (256, 256)

model = unet3d_simply(input_size=(8, 256, 256, 1))

# model.summary()
tf.keras.utils.plot_model(model, show_shapes=True)
