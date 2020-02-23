classdef PeakFinderParams < handle
  
  properties (Access = public)
    stdToSignalRatioMult
    minTimeBtwEvents
  end

  methods
    function obj = PeakFinderParams()
    end
  end
end