import numpy as np
import os
import skimage.io as io
import skimage.transform as trans
import numpy as np
from tensorflow import keras
from tensorflow.keras import layers

from data import *


def pooling(pretrained_weights=None, input_size=(256, 256, 1)):
    inputs = layers.Input(input_size)

    outs = layers.MaxPooling2D(pool_size=(2, 2))(inputs)
    outs = layers.UpSampling2D(size=(2, 2))(outs)

    # Model
    model = keras.Model(inputs=inputs, outputs=outs)

    model.compile(optimizer=keras.optimizers.Adam(lr=1e-4),
                  loss='binary_crossentropy', metrics=['accuracy'])

    model.summary()

    return model


model = pooling()

testGene = testGenerator("data/membrane/test")
results = model.predict_generator(testGene, 1, verbose=1)
saveResult("test/pooling", results)
