

%% set some parameters and paths 
p.PCAICA.mu = 0.1;
p.PCAICA.term_tol = 1e-5;
p.PCAICA.max_iter = 750;
p.PCAICA.nPCs = 800;
p.PCAICA.nICs = 600;    

mov_path = 'preprocessed/preprocessedMovie.h5';
save_path = 'extracted/resultsPCAICA';


%% run signal extraction
extractSignals( p, mov_path,save_path )

