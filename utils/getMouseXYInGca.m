function [mouseX, mouseY] = getMouseXYInGca()
  C = get (gca, 'CurrentPoint');
  mouseX = C(1,1);
  mouseY = C(1,2);
end