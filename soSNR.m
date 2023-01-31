function snrValues = doSNR(theChannel,conditionOrder,useDWs,peakWindow)

    % compute SNR for all the ERP files in a given directory
    % uses a difference wave to find the peak of interest
    % set use DWs to 1 to work with difference waves instead of conditions,
    % specify peakWindow in points, conditionOrder or subtraction order, and theChannel is the channel to analyze


    useDWs = 1;
    theChannel = 2;
    conditionOrder = [2 1];
    peakWindow = 5;
    
    files = dir('*.mat');

    nFiles = length(files);

    for i = 1:nFiles

        load(files(i).name);

        erpData(:,:,i) = squeeze(ERP.data(theChannel,:,:));

    end

    % get mean data
    meanData = mean(erpData,3);

    % create DW
    plotData = meanData(:,conditionOrder(1)) - meanData(:,conditionOrder(2));

    % plot DW
    plot(ERP.times,plotData);

    % find peak for SNR calculations
    [peakTime peakAmplitude] = ginput(1);

    % correct for negative peaks
    searchNegative = 0;
    if peakAmplitude < 0 
        searchNegative = 1;
    end

    % find the baseline window
    baselineTime = find(ERP.times <= 0);
    baselineTime = baselineTime(end);

    peakTime = find(ERP.times <= peakTime);
    peakTime = peakTime(end);

    % compute classic baseline to erp peak SNR on average subject waveforms

    for i = 1:nFiles

        subjectData = squeeze(erpData(:,:,i));

        z = 1;

        if useDWs == 0

            for conditionCounter = 1:size(erpData,2)
    
                mathData = subjectData(:,conditionCounter);
    
                if searchNegative == 0
    
                    subjectPeak = max(mathData(peakTime-peakWindow:peakTime+peakWindow));
    
                else
    
                    subjectPeak = min(mathData(peakTime-peakWindow:peakTime+peakWindow));
                    subjectPeak = abs(subjectPeak);
    
                end
    
                baseLineVariance = std(mathData(1:baselineTime));
    
                erpSNR(i,conditionCounter) = subjectPeak / baseLineVariance;
    
            end

        else

            mathData = subjectData(:,conditionOrder(1)-conditionOrder(2));

            if searchNegative == 0

                subjectPeak = max(mathData(peakTime-peakWindow:peakTime+peakWindow));
                subjectPeak = abs(subjectPeak);

            else

                subjectPeak = min(mathData(peakTime-peakWindow:peakTime+peakWindow));
                subjectPeak = abs(subjectPeak);

            end

            baseLineVariance = std(mathData(1:baselineTime));

            erpSNR(i,1) = subjectPeak / baseLineVariance; 

        end

    end

end