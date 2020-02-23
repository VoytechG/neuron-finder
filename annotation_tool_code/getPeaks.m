% This might not be entirely accurate, since how many and which peaks
% are found is dependent on the minTimeBtEvents paramter
function [signalPeaksArray] = getPeaks(p, signalMatrix, stdToSignalRatioMult, minTimeBtwEvents)

    if nargin == 2
        stdToSignalRatioMult = p.annotation.numStdsForThresh;
        minTimeBtwEvents = p.annotation.minTimeBtwEvents;
    end
    
    numberOfFilters = size(signalMatrix,1);
    signalPeaksArray = cell(1, numberOfFilters);

    for filterIndex = 1:numberOfFilters
        inputSignal = signalMatrix(filterIndex,:);

        % get standard deviation of current signal
        inputSignalStd = std(inputSignal(:));

        stdThreshold = inputSignalStd * stdToSignalRatioMult;

        % run findpeaks, returns maxima above thisStdThreshold and ignores 
        % smaller peaks around larger maxima within minTimeBtEvents
        [~,testpeaks] = findpeaks(inputSignal, ...
            'minpeakheight', stdThreshold, ...
            'minpeakdistance', minTimeBtwEvents);
        
        signalPeaksArray{filterIndex} = testpeaks;
    end
end