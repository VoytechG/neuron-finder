

%% set some parameters and paths 
p.PCAICA.mu = 0.1;
p.PCAICA.term_tol = 1e-5;
p.PCAICA.max_iter = 750;
p.PCAICA.nPCs = 800;
p.PCAICA.nICs = 600;    

mov_path = 'C:\Users\wojci\Desktop\UCL 4th\AB Spikes\example_code_original\example_code\preprocessed\preprocessedMovie.h5';
save_path = 'C:\Users\wojci\Desktop\UCL 4th\AB Spikes\example_code_original\example_code\extracted\resultsPCAICA';


%% run signal extraction
extractSignals( p, mov_path,save_path )

