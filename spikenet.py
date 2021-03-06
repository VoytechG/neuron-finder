# -*- coding: utf-8 -*-
"""SpikeNet.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/1FEIFDUSNmSh90vnS1Emr3LnYUwNw0JMa
"""

from google.colab import drive
drive.mount('/content/drive')

import os
from getpass import getpass
password = getpass('GitHub password')
os.environ['GITHUB_AUTH'] = "VoytechG" + ':' + password
! git clone https://$GITHUB_AUTH@github.com/VoytechG/neuron-finder

! git pull

gpu_info = !nvidia-smi
gpu_info = '\n'.join(gpu_info)
if gpu_info.find('failed') >= 0:
  print('Select the Runtime > "Change runtime type" menu to enable a GPU accelerator, ')
  print('and then re-execute this cell.')
else:
  print(gpu_info)

# Commented out IPython magic to ensure Python compatibility.
# %cd drive/My Drive/Spikes/neuron_finder/unet

!ls

# %cd neuron_finder/unet

# %cd unet

# Commented out IPython magic to ensure Python compatibility.
# %cd drive/My Drive/Spikes/neuron_finder/unet

import matplotlib.pyplot as plt
import numpy as np
from load_data import (
    MOVIE_LEN, FRAME_SHAPE, 
    load_movie, load_ground_truth_generation_data
)
from sklearn.metrics import classification_report
from unet_basic.model_3d import unet3d, unet3d_simply, plot_model
import unet_basic
import tensorflow as tf
import data_gen
from importlib import reload
from skimage.io import imshow
from skimage.measure import label
from scipy.ndimage.morphology import distance_transform_edt
import skimage
from skimage.measure import regionprops, label


# from data_gen import DataGenerator
reload(data_gen)
reload(unet_basic)
DataSequencer = data_gen.DataSequencer
# get_indices_split = data_gen.get_indices_split
from sklearn.model_selection import train_test_split


unet3d = unet_basic.model_3d.unet3d_simply

DATA_PACKED_FOR_GT_GENERATION_PATH = "../../dataPackedForGeneration.mat"
MOVIE_PATH = "../../preprocessedMovie.h5"

data_packed = \
    load_ground_truth_generation_data(DATA_PACKED_FOR_GT_GENERATION_PATH)

movie_h5 = load_movie(MOVIE_PATH)

FRAMES_TO_LOAD = 3000
movie = movie_h5
# movie = np.array(movie_h5[:FRAMES_TO_LOAD])
# print(movie.shape)

# movie = movie_h5
# FRAMES_TO_LOAD = len(movie)
# FRAMES_TO_LOAD

def display(display_list, titles=None):
  plt.figure(figsize=(15, 15))

  for i in range(len(display_list)):
    plt.subplot(1, len(display_list), i+1)
    # if titles is not None: 
      # plt.title(titles[i])
    if i == 0:
      plt.imshow(display_list[i], vmin=-0.045, vmax=0.075)
    else:  
      plt.imshow(display_list[i])
    plt.axis('off')
  plt.show()

def show_prediction(dataset, index):

    i = index

    x = dataset[0][i:i+1]
    frame = x[0, len(x)//2-1]
    frame = frame.reshape(frame.shape[:2])

    y = dataset[1][i]
    y = y.reshape(y.shape[:2])

    predictions = model.predict(x)
    p = np.argmax(predictions, 3)
    p = p.reshape(p.shape[1:3])

    p1 = predictions[0]
    p2 = predictions[1]

    display([frame, y, p, p1, p2])

def display_example(sequencer, batch_index, sample_index):

    i = batch_index
    j = sample_index
    xs, ys, sws = sequencer[i]
    # imshow(y.reshape(y.shape[:2]))
    x = xs[j]
    x_middle = x[3]
    y = ys[j]
    sw = sws[j]

    to_display = [img.reshape(img.shape[:2]) for img in [x_middle, y, sw]]
    display(to_display)
    imshow(to_display[2])

def get_indices_split(indices):
    indices_train, indices_test, _, _ = train_test_split(
        indices, indices, test_size=0.25, shuffle=False
    )
    indices_train, indices_validate, _, _ = train_test_split(
        indices_train, indices_train, test_size=0.25, shuffle=False
    )
    return indices_train, indices_validate, indices_test

indices_all = np.array(range(4,FRAMES_TO_LOAD-4))

def get_indices_split(indices):
    indices_train, indices_test, _, _ = train_test_split(
        indices, indices, test_size=0.25, shuffle=False
    )
    indices_train, indices_validate, _, _ = train_test_split(
        indices_train, indices_train, test_size=0.25, shuffle=False
    )
    return indices_train, indices_validate, indices_test

indices_train, indices_validate, indices_test = \
    get_indices_split(indices_all)

# Parameters
spatial_dims = {
    '128': (128, 128),
    '192': (192, 192),
    '256': (256, 256),
    '384': (384, 384) 
    }

params = {'spatial_dim': spatial_dims['192'],
          'temporal_dim': 8,
          'batch_size': 1,
          'shuffle': False, 
          'use_sample_weights': False}

# Generators
training_sequencer = DataSequencer(
    indices_train, movie, data_packed, **params)
training_sequencer.shuffle = True

validation_sequencer = DataSequencer(
    indices_validate, movie, data_packed, **params)

test_sequencer = DataSequencer(
    indices_test, movie, data_packed, **params)

input_size = (params['temporal_dim'],) + params['spatial_dim'] + (1,)

test_sequencer.indices[:10]

vs = validation_sequencer
validation_dataset = vs._DataSequencer__data_generation(vs.indices)

# model = unet3d(
#     input_size=input_size, 
#     start_filters_no=32)

# model.summary()

# Commented out IPython magic to ensure Python compatibility.
def get_checkpoint_callback(model_name):

  model_checkpoint_callback = tf.keras.callbacks.ModelCheckpoint(
      f'checkpoint_{model_name}/weights.{epoch:02d}-{val_loss:.2f}.hdf5', 
      monitor='val_loss', 
      verbose=1, 
      save_best_only=False,
      save_weights_only=True, 
      mode='auto', 
      save_freq='epoch'
  )

  return model_checkpoint_callback

def run_epochs(
    model, 
    training_sequencer, 
    initial_epoch, 
    epochs_to_go, 
    model_name, 
    callbacks=None):

  EPOCHS = initial_epoch + epochs_to_go

  history = model.fit(
    training_sequencer,
    validation_data = validation_dataset,
    epochs=EPOCHS, 
    verbose=1, 
    initial_epoch=initial_epoch,
    callbacks=callbacks)
  
  val_loss = '%.4f' % history.history['val_loss'][-1]

#   %cd ../..
  model.save(f"saved_model/{model_name}_{EPOCHS}_{val_loss}.h5")
#   %cd "neuron_finder/unet"

# reload(unet_basic.model_3d)

# build_down_step = unet_basic.model_3d.build_down_step
# build_bottom_step = unet_basic.model_3d.build_bottom_step
# build_up_step = unet_basic.model_3d.build_up_step
# build_output_step = unet_basic.model_3d.build_output_step

# def model_shallow(start_filters_no = 16):
#   def fil(depth):
#       return start_filters_no * 2 ** (depth - 1)

#   inputs = layers.Input(input_size)

#   conv1, pool1 = build_down_step(inputs, fil(1))
#   conv2, pool2 = build_down_step(pool1, fil(2), dropout=0.5)

#   conv_bottom = build_bottom_step(pool2, fil(3))

#   convup2 = build_up_step(conv_bottom, conv2, fil(2))
#   convup1 = build_up_step(convup2, conv1, fil(1))

#   convout = build_output_step(convup1, input_size, cat_ce=cat_ce)

#   return inputs, convout

# inputs, outputs = model_shallow()
# model = keras.Model(inputs=inputs, outputs=outputs)
# model.compile(
#     optimizer=keras.optimizers.Adam(lr=1e-4),
#     loss=keras.losses.SparseCategoricalCrossentropy(from_logits=True),
#     metrics=metrics,
# )

for start_filters, name, runs in [(32, "test", 4)]:
  model = unet3d(input_size=input_size, start_filters_no=start_filters)

  model.compile(
      optimizer=tf.keras.optimizers.Adam(lr=1e-5),
      loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
      metrics=['accuracy'],
  )

  for i in range(runs):
    to_go = 3
    run_epochs(model, training_sequencer, i*to_go, to_go, name)

model = tf.keras.models.load_model('../../saved_model/test_12_0.0055.h5')

model.compile(
      optimizer=tf.keras.optimizers.Adam(lr=1e-5),
      loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
      metrics=['accuracy'],
  )

runs = 3
for i in range(runs):
  to_go = 3
  run_epochs(model, training_sequencer, i*to_go, to_go, "test")

def get_prediction(model, x):
  p = model.predict(x)
  pred_mask = p[0]
  p1 = pred_mask[:,:,0]
  p2 = pred_mask[:,:,1]
  prediction = np.argmax(np.array([p1,p2]), 0)

  return prediction, p1, p2

def visualize_results(models, sequencer, i, names, display_activations=False):

  x = sequencer[i][0]
  y = sequencer[i][1]
  x_to_show = x[0,3, :, :,0]
  y_to_show = y[0,:,:,0]

  titles = ["Sample", 'Ground truth'] + names

  if len(models) == 1:
    model = models[0]

    prediction, p1, p2 = get_prediction(model, x)

    if display_activations:
      display([x_to_show, y_to_show, p1, p2, prediction], titles)
    else:
      display([x_to_show, y_to_show, prediction], titles)

  else:
    predictions = [get_prediction(model, x)[0] for model in models]
    display([x_to_show, y_to_show] + predictions, titles)


def get_model(name):
  return tf.keras.models.load_model(f'../../saved_model/{name}.h5')

model_names = [
               '32a_6_0.0049',
               '32a_9_0.0052',
               '32a_12_0.0062',
               '32a_15_0.0073',
               '16a_6_0.0051',
               '16a_9_0.0054',
               '16a_12_0.0062',
               '16a_15_0.0073'
               ]

model_names_16 = [
    '16a_6_0.0051',
    '16a_9_0.0054',
    # '16a_12_0.0062',
    '16a_15_0.0073',
    # '16a_18_0.0077',
    # '16a_21_0.0088',
    ]

model_names_8 = [
    '8b_6_0.0049'
    '8b_9_0.0049',
    '8b_12_0.0050',
    '8b_15_0.0054',
    '8b_18_0.0055',
    '8b_21_0.0060',
]

model_names_cross = [
    '8b_6_0.0049',
    '8b_9_0.0049',
    '16a_6_0.0051',
    '16a_9_0.0054',   
    '32a_6_0.0049',
    '32a_9_0.0052',      
]

model_names_384 = [
  '8_384_3_0.0057',
  '8_384_6_0.0048',
  '8_384_9_0.0048',
  '8_384_12_0.0047',
  '8_384_15_0.0047',
  '8_384_18_0.0052'
]

model_names_16c = [
  '16c_192_6_0.0050',
  '16c_192_9_0.0049',
  '16c_192_12_0.0060',
]

model_names_32c = [
  '32c_192_6_0.0047',
  # '32c_192_9_0.0049',
  # '32c_192_12_0.0054',
]

model_names_8c = [
  '8c_192_6_0.0050',
  '8c_192_9_0.0051',
  '8c_192_12_0.0052',
]

# models_with_names = [(get_model(name), name) for name in model_names]
# models_with_names = [(get_model(name), name) for name in model_names_16]
# models_with_names = [(get_model(name), name) for name in model_names_16c]
# models_with_names = [(get_model(name), name) for name in model_names_32c]
# models_with_names = [(get_model(name), name) for name in model_names_8c]
# models_with_names = [(get_model(name), name) for name in model_names_8]
# models_with_names = [(get_model(name), name) for name in model_names_cross]
# models_with_names = [(get_model(name), name) for name in model_names_384]
models_with_names = [[model, "test"]]



for i in list(range(16,24)):
  models = [m[0] for m in models_with_names]
  names = [m[1] for m in models_with_names]
  visualize_results(models, test_sequencer, i, names)



def get_cen_areas(bin_img):
  cen_areas = [
               [region.centroid[:2], 
                (region.area, 
                 region.major_axis_length, 
                 region.minor_axis_length,
                 region.orientation)]
               for region 
               in regionprops(label(bin_img))
             ]
  return cen_areas

def get_PN(cen_areas_y, cen_areas_p, dist_sq_thresh = 4):
  def get_closest_dist_sq(ca, cas_other):
    if len(cas_other) == 0:
      return 10000, None
    (x1, y1), _ = ca

    distances = [
      (x1-x2)**2 + (y1-y2)**2 
      for (x2, y2), _ in cas_other]

    min_dst = np.min(distances)
    min_dst_indx = np.argmin(distances)

    return min_dst, min_dst_indx

  TP = 0
  FP = 0
  FN = 0 
  TP_area_ratio_sum = 0
  TP_angle_abs_error = 0
  TP_major_ax_ratio = 0
  TP_minor_ax_ratio = 0

  for cas_y, cas_p in zip(cen_areas_y, cen_areas_p):
    for ca_y in cas_y:
      dist, ind = get_closest_dist_sq(ca_y, cas_p)
      if dist <= dist_sq_thresh:
        TP += 1
        TP_area_ratio_sum += ca_y[1][0] / cas_p[ind][1][0]
        TP_angle_abs_error += abs(ca_y[1][3] - cas_p[ind][1][3])
        try:
          TP_major_ax_ratio += ca_y[1][1] / cas_p[ind][1][1]
        except:
          TP_major_ax_ratio += 5
        try:
          TP_minor_ax_ratio += ca_y[1][2] /cas_p[ind][1][2]
        except:
          TP_minor_ax_ratio += 3
      else:
        FN += 1
    for ca_p in cas_p:
      dist, _ = get_closest_dist_sq(ca_p, cas_y)
      if dist > dist_sq_thresh:
        FP += 1

  mean_area_ratio_TP = TP_area_ratio_sum / TP 
  TP_angle_abs_error = TP_angle_abs_error / TP
  TP_major_ax_ratio = TP_major_ax_ratio  / TP
  TP_minor_ax_ratio = TP_minor_ax_ratio / TP
  return TP, FP, FN, (mean_area_ratio_TP, TP_angle_abs_error, TP_major_ax_ratio, TP_minor_ax_ratio)


def get_pre_rec(model, test_sequencer, cen_areas_y, r2=9):
  
  predictions = model.predict(test_sequencer)
  predictions = np.argmax(predictions, 3)

  cen_areas_p = [get_cen_areas(img) for img in predictions]

  TP, FP, FN, spatial_errors = get_PN(
      cen_areas_y, cen_areas_p, dist_sq_thresh=r2)

  precision = TP/(TP+FP)
  recall = TP/(TP+FN)

  return precision, recall, spatial_errors

def evaluate_models(models_with_names, test_sequencer, cen_areas_y, r2):
  print (f"Testing {r2}")
  for model, name in models_with_names:
    precision, recall, spatial_errors = \
      get_pre_rec(model, test_sequencer, cen_areas_y, r2=r2)
    # print(name, precision, recall, spatial_errors)
    print(f"{name}, {precision:.2f}, {recall:.2f}")

def get_cen_areas_y(test_sequencer):
  ts = test_sequencer
  ts.shuffle = False

  cen_areas_y = [get_cen_areas(ts.gen.get_y(i)[:,:,0]) for i in ts.indices]
  return cen_areas_y

cen_areas_y = get_cen_areas_y(test_sequencer)

for r2 in [1,4,9,16]:
  evaluate_models(models_with_names, test_sequencer, cen_areas_y, r2)

from sklearn.metrics import jaccard_score

def dice_loss(y_true, y_pred):
  y_pred_mask = tf.expand_dims(tf.argmax(y_pred, -1), -1)
  print(y_true.shape, y_pred.shape, y_pred_mask.shape)
  numerator = 2 * tf.reduce_sum(y_true * y_pred_mask, axis=-1)
  denominator = tf.reduce_sum(y_true + y_pred_mask, axis=-1)

  return 1 - (numerator + 1) / (denominator + 1)

def iou(y_true, y_pred):
  tf.enable_eager_execution() 
  # y_pred_n = tf.argmax(y_pred, -1).numpy().flatten()
  # y_true_n = y_true.numpy().flatten()

  y_pred_n = tf.argmax(y_pred, -1).numpy().flatten()
  # y_true_n = y_true.numpy().flatten()

  m.reset_states()
  _ = m.update_state(y_pred_n, y_ture_n,
                   sample_weight=[0.3, 0.3, 0.3, 0.1])
  m.result().numpy()
  return m.result().numpy()

def eval_loss(models_with_names, test_sequencer, loss):
  for model, name in models_with_names:
    model.compile(
          optimizer=tf.keras.optimizers.Adam(lr=1e-4),
          loss=loss,
      )

    ev = model.evaluate(test_sequencer)

# tf.InteractiveSession()
eval_loss(models_with_names, test_sequencer, iou)

def weighted_cross_entropy(beta):

  def loss(y_true, y_pred):
    y_true_mask = tf.concat([1-y_true, y_true], -1)
    loss = tf.nn.weighted_cross_entropy_with_logits(logits=y_pred, labels=y_true_mask, pos_weight=beta)
    # or reduce_sum and/or axis=-1
    return tf.reduce_mean(loss)

  return loss

    
def precision(y_true, y_pred):
  y_true_mask = tf.concat([1-y_true, y_true], -1)
  res, _ = tf.compat.v1.metrics.precision(y_true_mask, y_pred)
  return res

def recall(y_true, y_pred):
  y_true_mask = tf.concat([1-y_true, y_true], -1)
  res, _ = tf.compat.v1.metrics.recall(y_true_mask, y_pred)
  return res

def dice_loss(y_true, y_pred):
  y_pred_mask = tf.argmax(y_pred, -1)
  numerator = 2 * tf.reduce_sum(y_true * y_pred, axis=-1)
  denominator = tf.reduce_sum(y_true + y_pred, axis=-1)

  return 1 - (numerator + 1) / (denominator + 1)

model = models_with_names[0][0]
model.compile(
        optimizer=tf.keras.optimizers.Adam(lr=1e-4),
        # loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        # loss=dice_loss,
        # metrics=[tf.keras.metrics.Precision(), tf.keras.metrics.Recall()],
        # metrics=["accuracy", precision, recall]
        metrics=[tf.keras.metrics.MeanIoU(num_classes=2)]
    )

model.evaluate(test_sequencer)







from tensorflow.keras import layers
from tensorflow import keras

frames, height, width, _ = input_size

# Down 1
def conv_bnorm_relu(input, filters_no, kernel=3, padding="same"):
    conv = layers.Conv3D(
        filters_no, kernel, padding=padding, kernel_initializer="he_normal"
    )(input)
    norm = layers.BatchNormalization()(conv)
    relu = layers.Activation("relu")(norm)

    return relu

inputs = layers.Input(input_size)
conv = conv_bnorm_relu(inputs, 10, (1, 20,20))
conv = conv_bnorm_relu(conv, 10, (1, 20,20))
conv = conv_bnorm_relu(conv, 10, (1, 10,10))
conv = layers.MaxPool3D(
    pool_size=(8, 1, 1)
)(conv)
conv = conv_bnorm_relu(conv, 10, (1, 10,10))
conv = layers.Conv3D(
            2,
            (1, 1, 1),
            padding="valid",
            kernel_initializer="he_normal",
        )(conv)
# den = layers.Dense((1, height, width), 20)
conv = layers.Reshape((height, width, 2))(conv)

model = keras.Model(inputs=inputs, outputs=conv)

model.compile(
    optimizer=keras.optimizers.Adam(lr=1e-4),
    loss=keras.losses.SparseCategoricalCrossentropy(from_logits=True),
    metrics=["accuracy"],
)

model.summary()

history = model.fit(
    training_sequencer,
    validation_data = validation_dataset,
    epochs=3, 
    verbose=1, 
    initial_epoch=0)

for i in [0,1,2,3,4,5]:
  visualize_results([model], test_sequencer, i, ['old'])

