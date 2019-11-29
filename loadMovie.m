function [ movieMat ] = loadMovie( moviePath, varargin )
%loadMovie loading movie from h5 files 
%optional argument: start and stop index as a vector
    if isempty(varargin)
        movieMat = h5read(moviePath,'/1');
    else
        start = varargin{1};
        stop = varargin{2};
        info = h5info(moviePath);
        chunkSize = info.Datasets.Dataspace.Size;
        chunkSize(3) = stop+1-start;
        movieMat = h5read(moviePath,'/1',[1 1 start], chunkSize);
    end
end

