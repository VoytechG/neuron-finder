close all

%% set params
p.frameRate = 5;
p.annotation.areaThresh = 0; 
p.annotation.numStdsForThresh = 3;
p.annotation.minTimeBtwEvents = 10;

% run cellChecker (this might take some time to load)
fprintf("Running cell checker... ");
valid = cellChecker(p, movie, traces, filters, events);
fprintf("Done.\nCell checker exited.\n")



%% save 

if sum(valid == -1) == 0
    disp('Annotation complete, saving results.')
    filters = filters(:,:,valid == 1);
    traces = traces(valid == 1,:);
    save(save_path,'valid','filters','traces')
else
    fprintf('Annotation is not complete, saving intermediate annotation results... ')
    save([save_path,'_intermediate'],'valid','filters','traces')
    fprintf("Done.\n")
end