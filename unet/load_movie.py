import h5py

'''
'../preprocessed/preprocessedMovie.h5'
'''


def load_movie(path):
    f = h5py.File(path, 'r')
    movie = f['/1']
    return movie
