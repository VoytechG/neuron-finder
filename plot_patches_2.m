close all

figure('Name','Patches');

i1 = imread('rice.png');
i2 = imread('filter1.png');

subplot(1,2,1);
imshow(i1);

x2 = [2 5; 2 5; 8 8];
y2 = [4 0; 8 2; 4 0];
p1 = patch(x2,y2,'g');

subplot(1,2,2);
imshow(i2);

x2 = [2 5; 2 5; 8 8] * 10;
y2 = [4 0; 8 2; 4 0] * 10;
p2 = patch(x2,y2,'r');

s1 = setPatchForColorChange(p1);
s2 = setPatchForColorChange(p2);
s1();
m1 = setPatchAndSubplotForMove(p1);
m2 = setPatchAndSubplotForMove(p2);

while 1
    s1();
    s2();
    waitforbuttonpress();
end

function f = setPatchForColorChange(patch)
f = @changePatchColor;

    function changePatchColor()
        color = patch.FaceColor;
        disp(patch.FaceColor)
        if (isequal(color, [1,0,0]))
            color = 'g';
        else
            color = 'r';
        end
        patch.FaceColor = color;
    end
end

function f = setPatchAndSubplotForMove(patch)

org_x = patch.XData;
org_y = patch.YData;

f = @movePatch;
set (gcf, 'WindowButtonMotionFcn', @movePatch);

    function movePatch (object, eventdata)
        C = get (gca, 'CurrentPoint');
        mouseX = C(1,1);
        mouseY = C(1,2);
        title(gca, ['(X,Y) = (', num2str(mouseX), ', ',num2str(mouseY), ')']);
        patch.XData = org_x + mouseX;
        patch.YData = org_y + mouseY;
    end
end
