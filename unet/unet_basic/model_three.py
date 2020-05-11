import numpy as np
import os
import skimage.io as io
import skimage.transform as trans
import numpy as np
from tensorflow import keras
from tensorflow.keras import layers


def unet3d(pretrained_weights=None,
           input_size=(16, 256, 256, 1),
           three_layers=True,
           categorical_cross_entropy=True):
    inputs = layers.Input(input_size)
    frames, height, width, _ = input_size

    # Down 1
    conv1 = layers.Conv3D(64, 3, activation='relu',
                          padding='same', kernel_initializer='he_normal')(inputs)
    conv1 = layers.Conv3D(64, 3, activation='relu',
                          padding='same', kernel_initializer='he_normal')(conv1)
    pool1 = layers.MaxPooling3D(pool_size=(2, 2, 2))(conv1)

    # Down 2
    conv2 = layers.Conv3D(128, 3, activation='relu',
                          padding='same', kernel_initializer='he_normal')(pool1)
    conv2 = layers.Conv3D(128, 3, activation='relu',
                          padding='same', kernel_initializer='he_normal')(conv2)
    pool2 = layers.MaxPooling3D(pool_size=(2, 2, 2))(conv2)

    # Down 3
    conv3 = layers.Conv3D(256, 3, activation='relu',
                          padding='same', kernel_initializer='he_normal')(pool2)
    conv3 = layers.Conv3D(256, 3, activation='relu',
                          padding='same', kernel_initializer='he_normal')(conv3)

    #  -------------------------- 4 levels version -------------------------------

    if not three_layers:
        pool3 = layers.MaxPooling3D(pool_size=(2, 2, 2))(conv3)

        # Down 4
        conv4 = layers.Conv3D(512, 3, activation='relu',
                              padding='same', kernel_initializer='he_normal')(pool3)
        conv4 = layers.Conv3D(512, 3, activation='relu',
                              padding='same', kernel_initializer='he_normal')(conv4)
        drop4 = layers.Dropout(0.5)(conv4)
        pool4 = layers.MaxPooling3D(pool_size=(2, 2, 2))(drop4)

        # Bottom
        conv_bottom = layers.Conv3D(1024, 3, activation='relu',
                                    padding='same', kernel_initializer='he_normal')(pool4)
        conv_bottom = layers.Conv3D(1024, 3, activation='relu',
                                    padding='same', kernel_initializer='he_normal')(conv_bottom)
        drop_bottom = layers.Dropout(0.5)(conv_bottom)

        # Up 4
        up4 = layers.Conv3D(512, 2, 2, activation='relu', padding='same',
                            kernel_initializer='he_normal')(layers.UpSampling3D(size=(2, 2, 2))(drop_bottom))
        merge4 = layers.concatenate([drop4, up4], axis=4)
        convup4 = layers.Conv3D(512, 3, activation='relu',
                                padding='same', kernel_initializer='he_normal')(merge4)
        convup4 = layers.Conv3D(512, 3, activation='relu',
                                padding='same', kernel_initializer='he_normal')(convup4)

        to_up3 = convup4

    #  -------------------------- 4 levels version -------------------------------

    # --------------------------- 3 levels version -------------------------------
    else:
        conv3 = layers.Dropout(0.5)(conv3)
        pool3 = layers.MaxPooling3D(pool_size=(2, 2, 2))(conv3)

        conv_bottom = layers.Conv3D(512, 3, activation='relu',
                                    padding='same', kernel_initializer='he_normal')(pool3)
        conv_bottom = layers.Conv3D(512, 3, activation='relu',
                                    padding='same', kernel_initializer='he_normal')(conv_bottom)
        drop_bottom = layers.Dropout(0.5)(conv_bottom)

        to_up3 = drop_bottom
    # --------------------------- 3 levels version -------------------------------

    # Up 3
    up3 = layers.Conv3D(256, 2, activation='relu', padding='same',
                        kernel_initializer='he_normal')(layers.UpSampling3D(size=(2, 2, 2))(to_up3))
    merge3 = layers.concatenate([conv3, up3], axis=4)
    convup3 = layers.Conv3D(256, 3, activation='relu',
                            padding='same', kernel_initializer='he_normal')(merge3)
    convup3 = layers.Conv3D(256, 3, activation='relu',
                            padding='same', kernel_initializer='he_normal')(convup3)

    # Up 2
    up2 = layers.Conv3D(128, 2, activation='relu', padding='same',
                        kernel_initializer='he_normal')(layers.UpSampling3D(size=(2, 2, 2))(convup3))
    merge2 = layers.concatenate([conv2, up2], axis=4)
    convup2 = layers.Conv3D(128, 3, activation='relu',
                            padding='same', kernel_initializer='he_normal')(merge2)
    convup2 = layers.Conv3D(128, 3, activation='relu',
                            padding='same', kernel_initializer='he_normal')(convup2)

    # Up 1
    up1 = layers.Conv3D(64, 2, activation='relu', padding='same',
                        kernel_initializer='he_normal')(layers.UpSampling3D(size=(2, 2, 2))(convup2))
    merge1 = layers.concatenate([conv1, up1], axis=4)
    convup1 = layers.Conv3D(64, 3, activation='relu',
                            padding='same', kernel_initializer='he_normal')(merge1)
    convup1 = layers.Conv3D(64, 3, activation='relu',
                            padding='same', kernel_initializer='he_normal')(convup1)

    convout = layers.Conv3D(2, (1, 3, 3), activation='relu',
                            padding='same', kernel_initializer='he_normal')(convup1)
    convout = layers.Conv3D(2, (frames, 1, 1), activation='relu',
                            padding="valid", kernel_initializer='he_normal')(convout)
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
        metrics=['accuracy']
    )
    # --------------------- categorical crossentropy --------------------------

    if(pretrained_weights):
        model.load_weights(pretrained_weights)

    return model


def plot_model(model, name):
    keras.utils.plot_model(
        model,
        name,
        show_shapes=True,
        show_layer_names=False)
