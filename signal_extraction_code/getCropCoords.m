function [N, S, W, E] = getCropCoords( im )
% takes away edges containing ones until all edges are all zeros

% set up initial parameters
[rows,cols] = size(im);
N = 1;  
S = rows;  
W = 1;  
E = cols;

% shrink image until no more ones exist
finished = 0;
while ~finished
    % get ratio of ones 
    rN = sum(im(N,W:E)) / cols;
    rS = sum(im(S,W:E)) / cols;
    rW = sum(im(N:S,W)) / rows;
    rE = sum(im(N:S,E)) / rows;
     
    [m,maxR] = max([rN,rS,rW,rE]);
    maxR = maxR(1);

    % if there are no more ones, stop
    if m == 0;
        finished = 1;
        continue;
    end
    
    % if ones remain, remove edge with the highes proportion of ones   
    switch maxR
        case 1
            N = N+1;
        case 2 
            S = S-1;
        case 3 
            W = W+1;
        case 4 
            E = E-1;
    end
end
   
end