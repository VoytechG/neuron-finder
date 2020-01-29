figure();
I = imread('rice.png');
imagesc(I);

a = 20;
xs = [-a, -a, a, a];
ys = [-a, a, a, -a];
h = patch(xs,ys,'g');
moveit2(h);