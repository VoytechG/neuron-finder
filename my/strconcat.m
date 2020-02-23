close all
plot(1:10)
% title({'You can do it','with a cell array'})

title({
        sprintf('\n Frame %d \n', 1), ...
        sprintf('<A-S> std constant : %d', 2), ...
        sprintf('<Z-X> min dist btw events : %d\n', 3) ...
    });

%     title(strcat(sprintf('fvf\n'), sprintf('csdc')));