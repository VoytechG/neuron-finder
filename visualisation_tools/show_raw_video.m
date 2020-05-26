% Create plots
no_frames = 13;
% t = tiledlayout(1,no_frames); % Requires R2019b or later
cropLimits = [-0.045, 0.060];
for i = 1 : no_frames
%     nexttile
    colormap gray;
    imagesc(movie(135:175, 260:300, i+191), cropLimits);
    axis off
    Image = getframe(gcf);
    imwrite(Image.cdata, "imgs/spike_frame" + i + ".jpg");
    
end
