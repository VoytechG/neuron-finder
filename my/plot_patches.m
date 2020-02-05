mouse = mouseXY(0,0);

h=figure('units','normalized','outerposition',[0 0 1 1]);
figure(h);

% pats = [p1, p2];

while 1 == 1

    s = subplot(2,1,1);
    I = imread('rice.png');
    imagesc(I);
    
    height = size(I, 1);
    width = size(I, 2);
  
    x2 = [2 5; 2 5; 8 8];
    y2 = [4 0; 8 2; 4 0];
    p = patch(x2,y2,'green');
% %     set(gcf, 'WindowButtonMotionFcn', @setFromGca);
    moveit2(p);
% 
    subplot(2,1,2); 
    y2 = sin(5*x);
    plot(x,y2)
    
    waitforbuttonpress();
    disp("it")
end

function obj = setFromGca(object, event)
    s = subplot(2,1,1);
    C = get(s, 'CurrentPoint');
    x = C(1,1);
    y = C(1,2);
    title(s, ['(X,Y) = (', num2str(C(1,1)), ', ',num2str(C(1,2)), ')']);
    
%     mouse.setPatch(x, y);

    a = 20;
    xs = [-a, -a, a, a];
    ys = [-a, a, a, -a];
    patch(xs + x, ys + y, 'green')
    
    pause(0.1);
end


