run("loadExtractionResults.m")

index = 458;
colors.peakColor = "0 0 0 0.5";
colors.nonPeakColor = Color.red;

imagesc(filters(:, :, index));
drawEventOutlinePatch(index, 0, outlines, colors);
