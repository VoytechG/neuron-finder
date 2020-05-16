from model_3d import unet3d_simply, unet3d

model = unet3d_simply((8, 256, 256, 1))

model.summary()
