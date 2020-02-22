t = cell(1, 10);
for i = 1:length(t)
    
    for j = 1:10
     if isempty(t{j})
         t{j} = {};
     end
     l = length(t{j});
     t{j}{l + 1} = i;
    end
end
