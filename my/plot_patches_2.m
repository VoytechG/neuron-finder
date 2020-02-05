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

pat = ones(2);
pat(1) = p1;
pat(2) = p2;

pat(2).FaceColor = 'magenta';

s1 = setPatchForColorChange(p1);
s2 = setPatchForColorChange(p2);
% s1();
m1 = setPatchAndSubplotForMove(p1);
m2 = setPatchAndSubplotForMove(p2);

% while 1
%     s1();
%     s2();
%     waitforbuttonpress();
% end



function f = setPatchForColorChange(patch)
f = @changePatchColor;

    
end

function f = setPatchAndSubplotForMove(p)

    org_x = p.XData;
    org_y = p.YData;

    f = @movePatch;
    set (gcf, 'WindowButtonMotionFcn', @movePatch);
    set (gcf, 'WindowButtonDownFcn', @changePatchColor);

    function movePatch (~, ~)
        C = get (gca, 'CurrentPoint');
        mouseX = C(1,1);
        mouseY = C(1,2);
        title(gca, ['(X,Y) = (', num2str(mouseX), ', ',num2str(mouseY), ')']);
        p.XData = org_x + mouseX;
        p.YData = org_y + mouseY;
    end

    function changePatchColor(~, ~)
        color = p.FaceColor;
        disp(p.FaceColor);
        if (isequal(color, [1,0,0]))
            color = 'g';
        else
            color = 'r';
        end
        p.FaceColor = color;
    end
end
