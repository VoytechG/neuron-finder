
load('dataPackedForGeneration.mat')
s = zeros(500, 500);

for i = 1:600
    s = s + filtersBinary(:, :, i);
end

imagesc(s);
