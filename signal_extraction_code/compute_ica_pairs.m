function [ica_filters, ica_traces] = compute_ica_pairs(spatial, temporal, S, height ,width, ica_W)

	% Compute ICA pairs
	ica_traces  = ica_W*diag(S)*temporal;
	ica_filters = ica_W*spatial;

	% Format the ICA dimensions for output
	ica_traces  = ica_traces'; % [time x IC]
	ica_filters = reshape(ica_filters, size(ica_W, 1), height, width);
	ica_filters = permute(ica_filters, [2 3 1]); % [height, width, IC]

	% Sort ICs based on skewness
	skews = skewness(ica_traces);
	[~, sorted] = sort(skews, 'descend');
	ica_traces  = ica_traces(:,sorted); 
	ica_filters = ica_filters(:,:,sorted);
	clear skews sorted;
end