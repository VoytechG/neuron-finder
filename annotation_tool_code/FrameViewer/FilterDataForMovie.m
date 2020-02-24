classdef FilterDataForMovie < handle
    
    properties (Access = public)
      filterIndex
      frameDistanceToPeakFrame
    end

    methods (Access = public)
      function obj = myFun(filterIndex, frameDistanceToPeakFrame)
            obj.filterIndex = filterIndex;
            obj.frameDistanceToPeakFrame = frameDistanceToPeakFrame;      
      end
    end
end