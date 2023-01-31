function resampleResults = doResampleAnalysis(data,nTests)

    % reads in a matrix of peak data, rows = participants, columns = peaks for
    % conditions and does a resample analysis. Returns the percentage of
    % significant tests
    
    nParticipants = size(data,1);
    nColumns =  size(data,2);
    
    for q = 1:nColumns
    
        for n = 2:nParticipants
         
            for i = 1:nTests
                
                y = datasample(data(:,q),n);
                
                h = ttest(y);
                
                tResults(i) = h;
                
            end
            
            resampleResults(n-1,q) = mean(tResults);
            
        end
    
    end
    
    xAxisVals = 2:1:nParticipants;
    for q = 1:nColumns
        plot(xAxisVals,resampleResults(:,q));
        hold on;
    end
    ylabel('Percent Significant Tests');
    xlabel('Participants');

end