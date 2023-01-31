%function icData = doIntCon(theChannel,conditionOrder,peakWindow)

    % compute internal consistency for all the ERP files in a given directory
    % using odd - even comparisons
    % specify peakWindow in points, conditionOrder or subtraction order, and theChannel is the channel to analyze

    theChannel = 52;
    conditionOrder = [1 2];
    peakWindow = 5;
    
    files = dir('*.mat');

    nFiles = length(files);

    for i = 1:nFiles

        load(files(i).name);

        erpData(:,:,i) = squeeze(ERP.data(theChannel,:,:));

    end

    % get mean data
    meanData = nanmean(erpData,3);

    % create DW
    plotData = meanData(:,conditionOrder(1)) - meanData(:,conditionOrder(2));

    % plot DW
    plot(ERP.times,plotData);

    % find peak for SNR calculations
    [peakTime peakAmplitude] = ginput(1);

    peakTime = find(ERP.times <= peakTime);
    peakTime = peakTime(end);

    for i = 1:nFiles

        files = dir('*.mat');

        load(files(i).name);

        markers = unique(ERP.markers(:,2));

        if ~isempty(ERP.markers)

            [x1 y1] = find(ERP.markers(:,2) == markers(1));
            [x2 y2] = find(ERP.markers(:,2) == markers(2));
    
            workingData = squeeze(ERP.trialData(theChannel,:,:));
    
            data1 = workingData(:,x1);
    
            evens = 1:2:size(data1,2);
            odds = 2:2:size(data1,2);
    
            data11 = data1(:,evens);
            data21 = data1(:,odds);
    
            data2 = workingData(:,x2);
    
            evens = 1:2:size(data2,2);
            odds = 2:2:size(data2,2);
    
            data12 = data2(:,evens);
            data22 = data2(:,odds);
    
            data11 = mean(data11,2);
            data21 = mean(data21,2);
    
            data12 = mean(data12,2);
            data22 = mean(data22,2);
    
            if sum(conditionOrder == [2 1]) == 2
    
                dw1 = data21 - data11;
                dw2 = data22 - data12;
    
            else
    
                dw1 = data11 - data21;
                dw2 = data12 - data22;
    
            end
    
            peak1 = nanmean(dw1(peakTime-peakWindow:peakTime+peakWindow));
            peak2 = nanmean(dw2(peakTime-peakWindow:peakTime+peakWindow));
    
            icData(1,i) = peak1;
            icData(2,i) = peak2;

        else

            icData(1,i) = NaN;
            icData(2,i) = NaN;

        end


    end

%end