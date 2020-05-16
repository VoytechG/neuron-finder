import numpy as np
import os
import skimage.io as io
import skimage.transform as trans
import numpy as np
from tensorflow import keras
from tensorflow.keras import layers


def build_down_step(entry, filters_no, dropout=None):
    conv = layers.Conv3D(
        filters_no, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(entry)
    conv = layers.Conv3D(
        filters_no, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(conv)

    to_pool = conv
    if dropout:
        to_pool = layers.Dropout(0.5)(conv)

    pool = layers.MaxPooling3D(pool_size=(2, 2, 2))(to_pool)

    return conv, pool


def build_bottom_step(entry, filters_no):
    conv_bottom = layers.Conv3D(
        filters_no, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(entry)
    conv_bottom = layers.Conv3D(
        filters_no, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(conv_bottom)
    conv_bottom = layers.Dropout(0.5)(conv_bottom)

    return conv_bottom


def build_up_step(entry, conv_link, filters_no):

    up = layers.Conv3D(
        filters_no, 2, activation="relu", padding="same", kernel_initializer="he_normal"
    )(layers.UpSampling3D(size=(2, 2, 2))(entry))
    merge = layers.concatenate([conv_link, up], axis=4)
    convup = layers.Conv3D(
        filters_no, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(merge)
    convup = layers.Conv3D(
        filters_no, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(convup)

    return convup


def build_output_step(entry, input_size):
    frames, height, width, _ = input_size
    convout = layers.Conv3D(
        2, (1, 3, 3), activation="relu", padding="same", kernel_initializer="he_normal"
    )(entry)
    convout = layers.Conv3D(
        2,
        (frames, 1, 1),
        activation="relu",
        padding="valid",
        kernel_initializer="he_normal",
    )(convout)
    convout = layers.Reshape((height, width, 2))(convout)
    return convout


def unet3d_simply(input_size, start_filters_no=32):
    def fil(depth):
        return start_filters_no * 2 ** (depth - 1)

    inputs = layers.Input(input_size)

    conv1, pool1 = build_down_step(inputs, fil(1))
    conv2, pool2 = build_down_step(pool1, fil(2))
    conv3, pool3 = build_down_step(pool2, fil(3), dropout=0.5)

    conv_bottom = build_bottom_step(pool3, fil(4))

    convup3 = build_up_step(conv_bottom, conv3, fil(3))
    convup2 = build_up_step(convup3, conv2, fil(2))
    convup1 = build_up_step(convup2, conv1, fil(1))

    convout = build_output_step(convup1, input_size)

    model = keras.Model(inputs=inputs, outputs=convout)

    model.compile(
        optimizer=keras.optimizers.Adam(lr=1e-4),
        loss=keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        metrics=["accuracy"],
    )

    return model


def unet3d(
    input_size,
    pretrained_weights=None,
    three_layers=True,
    categorical_cross_entropy=True,
):
    inputs = layers.Input(input_size)
    frames, height, width, _ = input_size

    # Down 1
    conv1 = layers.Conv3D(
        64, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(inputs)
    conv1 = layers.Conv3D(
        64, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(conv1)
    pool1 = layers.MaxPooling3D(pool_size=(2, 2, 2))(conv1)

    # Down 2
    conv2 = layers.Conv3D(
        128, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(pool1)
    conv2 = layers.Conv3D(
        128, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(conv2)
    pool2 = layers.MaxPooling3D(pool_size=(2, 2, 2))(conv2)

    # Down 3
    conv3 = layers.Conv3D(
        256, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(pool2)
    conv3 = layers.Conv3D(
        256, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(conv3)

    #  -------------------------- 4 levels version -------------------------------

    if not three_layers:
        pool3 = layers.MaxPooling3D(pool_size=(2, 2, 2))(conv3)

        # Down 4
        conv4 = layers.Conv3D(
            512, 3, activation="relu", padding="same", kernel_initializer="he_normal"
        )(pool3)
        conv4 = layers.Conv3D(
            512, 3, activation="relu", padding="same", kernel_initializer="he_normal"
        )(conv4)
        drop4 = layers.Dropout(0.5)(conv4)
        pool4 = layers.MaxPooling3D(pool_size=(2, 2, 2))(drop4)

        # Bottom
        conv_bottom = layers.Conv3D(
            1024, 3, activation="relu", padding="same", kernel_initializer="he_normal"
        )(pool4)
        conv_bottom = layers.Conv3D(
            1024, 3, activation="relu", padding="same", kernel_initializer="he_normal"
        )(conv_bottom)
        drop_bottom = layers.Dropout(0.5)(conv_bottom)

        # Up 4
        up4 = layers.Conv3D(
            512, 2, 2, activation="relu", padding="same", kernel_initializer="he_normal"
        )(layers.UpSampling3D(size=(2, 2, 2))(drop_bottom))
        merge4 = layers.concatenate([drop4, up4], axis=4)
        convup4 = layers.Conv3D(
            512, 3, activation="relu", padding="same", kernel_initializer="he_normal"
        )(merge4)
        convup4 = layers.Conv3D(
            512, 3, activation="relu", padding="same", kernel_initializer="he_normal"
        )(convup4)

        to_up3 = convup4

    #  -------------------------- 4 levels version -------------------------------

    # --------------------------- 3 levels version -------------------------------
    else:
        conv3 = layers.Dropout(0.5)(conv3)
        pool3 = layers.MaxPooling3D(pool_size=(2, 2, 2))(conv3)

        conv_bottom = layers.Conv3D(
            512, 3, activation="relu", padding="same", kernel_initializer="he_normal"
        )(pool3)
        conv_bottom = layers.Conv3D(
            512, 3, activation="relu", padding="same", kernel_initializer="he_normal"
        )(conv_bottom)
        drop_bottom = layers.Dropout(0.5)(conv_bottom)

        to_up3 = drop_bottom
    # --------------------------- 3 levels version -------------------------------

    # Up 3
    up3 = layers.Conv3D(
        256, 2, activation="relu", padding="same", kernel_initializer="he_normal"
    )(layers.UpSampling3D(size=(2, 2, 2))(to_up3))
    merge3 = layers.concatenate([conv3, up3], axis=4)
    convup3 = layers.Conv3D(
        256, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(merge3)
    convup3 = layers.Conv3D(
        256, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(convup3)

    # Up 2
    up2 = layers.Conv3D(
        128, 2, activation="relu", padding="same", kernel_initializer="he_normal"
    )(layers.UpSampling3D(size=(2, 2, 2))(convup3))
    merge2 = layers.concatenate([conv2, up2], axis=4)
    convup2 = layers.Conv3D(
        128, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(merge2)
    convup2 = layers.Conv3D(
        128, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(convup2)

    # Up 1
    up1 = layers.Conv3D(
        64, 2, activation="relu", padding="same", kernel_initializer="he_normal"
    )(layers.UpSampling3D(size=(2, 2, 2))(convup2))
    merge1 = layers.concatenate([conv1, up1], axis=4)
    convup1 = layers.Conv3D(
        64, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(merge1)
    convup1 = layers.Conv3D(
        64, 3, activation="relu", padding="same", kernel_initializer="he_normal"
    )(convup1)

    convout = layers.Conv3D(
        2, (1, 3, 3), activation="relu", padding="same", kernel_initializer="he_normal"
    )(convup1)
    convout = layers.Conv3D(
        2,
        (frames, 1, 1),
        activation="relu",
        padding="valid",
        kernel_initializer="he_normal",
    )(convout)
    convout = layers.Reshape((height, width, 1))(convout)

    # ----------------------- binary cross entropy ----------------------------
    # if not categorical_cross_entropy:

    #     convout = layers.Conv3D(1, 1, activation='sigmoid')(convup1)

    #     model = keras.Model(inputs=inputs, outputs=convout)

    #     model.compile(optimizer=keras.optimizers.Adam(lr=1e-4),
    #                   loss='binary_crossentropy', metrics=['accuracy'])
    # ----------------------- binary cross entropy ----------------------------

    # --------------------- categorical crossentropy --------------------------
    # else:
    model = keras.Model(inputs=inputs, outputs=convout)

    model.compile(
        optimizer=keras.optimizers.Adam(lr=1e-4),
        loss=keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        metrics=["accuracy"],
    )
    # --------------------- categorical crossentropy --------------------------

    if pretrained_weights:
        model.load_weights(pretrained_weights)

    return model


def plot_model(model, name):
    keras.utils.plot_model(model, name, show_shapes=True, show_layer_names=False)