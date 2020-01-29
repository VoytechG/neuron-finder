classdef mouseXY
   properties
      x
      y
      patch
   end
   methods
      function obj = mouseXY(x, y)
            obj.x = x;
            obj.y = y;
            obj.patch = 0;
      end
      function obj = constructPatch(obj, patch)
           if (obj.patch == 0)
                obj.patch = patch;
           end
      end
      function obj = setPatch(obj)
            if (obj.patch == 0)
                return
            end
          
            a = 20;
            xs = [-a, -a, a, a];
            ys = [-a, a, a, -a];
            obj.patch.XData = xs + obj.x;
            obj.patch.YData = ys + obj.y;
%             p.XData = xs + obj.x;
%             p.Ydata = ys + obj.y;
            set(obj.patch,'visible','on');
      end
      function obj = setFromGca(obj, object, event)
            s = subplot(2,1,1);
            C = get (s, 'CurrentPoint');
            title(s, ['(X,Y) = (', num2str(C(1,1)), ', ',num2str(C(1,2)), ')']);
            obj.x = C(1,1);
            obj.y = C(1,2);
            obj.setPatch();
            pause(0.01);
      end
   end
end