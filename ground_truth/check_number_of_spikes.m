run("loadExtractionResults.m")

annotations = annotationsPrev;

no_filters = size(annotations.filters, 2);

totalSpikes = 0;
totalMatchings = 0;

for i = 1:no_filters
    totalSpikes = totalSpikes + sum(annotations.matchings{i} == AnnotationLabel.Valid);
    totalMatchings = totalMatchings + size(annotations.matchings{i}, 2);
end

disp("Total spikes number: " + totalSpikes);
disp("Total matchings number: " + totalMatchings);

f_valid = 0;
for i = 1:no_filters
    f_valid = f_valid + (annotations.filters(i) == AnnotationLabel.Valid);
end
disp("Total filters valid: " + f_valid);