## Launching

1. 1.

## Objects obtained by PCA-ICA procedure

### Modifications introduced

1. Filtering low quality filters (i.e. Removing filters with no events and low area neuron detections) has been moved from `cellChecker()` to the `getPeaks()`, which now returns array without low quality fitlers at all.

## Neuron and spike labelling pipeline

1. Run PCA ICA annotation tool and obtain filters (implmenetd by UZH).
1. For each filter (obtained via PCAICA), treat its responses (convolution results) as a signal. From this signal, extract local maxima, which represent spikes (moments of highest brightness of a neuron, corresponding to moments of highest calcium concentration in a neuron). This is done by using Matlabs's `findPeaks()` and parametrized with 2 thresholds:

   - Multiplier of ratio of local signal magnitutde and standard deviation of the whole signal. This allows for skipping small signal responses (i.e. peaks in its corresponding frames) which result from noise. On the other hand, too high value would eliminate actual, semi-bright spikes.
   - Minimum interval between subsequent signal peaks. This allows for elimination of very subtle local minima resulting from noise. On the other hand, too high value would eliminate true neighboring spikes.

1. Final elimination tools based on spatial features of the filters - eliminating filters that are too small (e.g. area of 20 square pixels).
   $add \space details$

The goal is to set these values to rule out as many false negatives as possible, but allow false positives. This is because it is easier for a human to eliminate the false positives by hand, rather than false negatives.

1. Filter checker
   Displayes all responses for each filter.
2. Frame checker
   For each frame, see the reponses on that frame.

## Frame Viewer

Frame Viewer can be used to inspect the original video and determine whether all spikes in the video have been labelled correctly. It allows for detecting potential issues such as too low tolerance in the local minima detector `getPeaks` and too high restriction in minimum interval between successive spikes.

### frame viewer - usability improvments

1. discard action if mouse outside of figure
2. in frame viewer: display all filter events (matches) for that frame, display filter number aside the matches, make matches clickable. Clicking would navigate to the corresponding filter in the cell checker

### Trying different colormaps

default parula provides best color range
grayscale is to low in variatey, jet is too high
