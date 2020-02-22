% This might not be entirely accurate, since how many and which peaks
% are found is dependent on the minTimeBtEvents paramter
function [signalPeaksArray] = getPeaks(p, signalMatrix)
    signalPeaksArray = {};
    numberOfFilters = size(signalMatrix,1);
    for filterIndex = 1:numberOfFilters
        inputSignal = signalMatrix(filterIndex,:);
        % get standard deviation of current signal
        inputSignalStd = std(inputSignal(:));
        thisStdThreshold = inputSignalStd * p.annotation.numStdsForThresh;
        % run findpeaks, returns maxima above thisStdThreshold and ignores 
        % smaller peaks around larger maxima within minTimeBtEvents
        [~,testpeaks] = findpeaks(inputSignal,'minpeakheight',thisStdThreshold,'minpeakdistance',p.annotation.minTimeBtwEvents);
        
        signalPeaksArray{filterIndex} = testpeaks;
    end
end