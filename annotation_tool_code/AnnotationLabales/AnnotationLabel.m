classdef AnnotationLabel < AnnotationLabelTemplate
   enumeration
     Invalid ('invalid', Color.red, 0)
     Valid ('valid', Color.green, 1)
     NotAnnotated ('not annotated', Color.dark_gray, 2)
     Contaminated ('conatminated', Color.orange, 3)
   end

   methods (Static)
     function label = getLabelByNumberCode(num)
        labels = [ ...
           AnnotationLabel.Invalid, ...
           AnnotationLabel.Valid, ...
           AnnotationLabel.NotAnnotated, ...
           AnnotationLabel.Contaminated ...
        ];
        label = labels(num + 1);   
     end
   end
end