classdef FrameViewerMain < handle
  properties (Access = public)
      frameIndex
  end
  
  methods
      function obj = FrameViewerMain(frameIndex)
        obj.frameIndex = frameIndex;
      end
      
      function displayFrame(obj)
        imagesc(movie(:, :, obj.frameIndex))
        setTitle();
        % colormap gray
           
      end
      
      function setTitle(obj, peakCalculationPending)

        if nargin == 0
            peakCalculationPending = 0;
        end

        disp("settign title");

        if peakCalculationPending
            topLine = sprintf('Frame %d (peak calculation pending)\n', obj.frameIndex);
        else
            topLine = sprintf('Frame %d \n', obj.frameIndex);
        end

        title(gca, {
            topLine , ...
            sprintf('<A-S> std constant : %d', peakFinderParams.stdToSignalRatioMult), ...
            sprintf('<Z-X> min dist btw events : %d \n', peakFinderParams.minTimeBtwEvents) ...
        });
    end
  end
end