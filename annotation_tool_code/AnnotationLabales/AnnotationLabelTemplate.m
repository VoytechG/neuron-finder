classdef AnnotationLabelTemplate < handle
    
   properties (SetAccess = immutable)
      description
      color
      numericalEncoding
   end
   
   methods
      function obj = ...
              AnnotationLabelTemplate(description, color, num)
        obj.description = description;
        obj.color = color;
        obj.numericalEncoding = num;
      end
   end
   
end