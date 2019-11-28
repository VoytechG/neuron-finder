function [ filters, traces ] = run_pca_ica( p,M )
%RUNPCAICA performs signal extraction using PCA and ICA 

    
%% PCA
    
    % perform mean subtraction for optimal PCA performance
    inputMean = mean(M(:));
    inputMean = cast(inputMean,class(M));
    M = bsxfun(@minus,M,inputMean);
    [height, width, num_frames] = size(M);

    % reshape movie into [space x time] matrix
    M = reshape(M, height * width, num_frames);

    % make each frame zero-mean in place
    mean_M = mean(M,1);
    M = bsxfun(@minus, M, mean_M);

    % display error message if nPCs is too high for video length
    if p.PCAICA.nPCs > size(M,2)
        disp('p.PCAICA.nPCs has to be smaller than the number of frames')
    end
    
    % run PCA
    [spatial, temporal, S] = compute_pca(M, p.PCAICA.nPCs); 
    S = diag(S); % keep only the diagonal of S
    clear M
   
    disp([ char(datetime('now')) ' done with PCA, starting ICA'])
    
%% ICA

    % set parameters
    mu = p.PCAICA.mu;
    term_tol = p.PCAICA.term_tol; 
    max_iter = p.PCAICA.max_iter;  
    num_ICs = p.PCAICA.nICs;
    
    % run ICA
    ica_mixed = compute_spatiotemporal_ica_input(spatial, temporal, mu);
    ica_W = compute_ica_weights(ica_mixed, num_ICs, term_tol, max_iter)'; 
    [filters, traces] = compute_ica_pairs(spatial, temporal, S, height, width, ica_W);
    traces = permute(traces,[2 1]);

end