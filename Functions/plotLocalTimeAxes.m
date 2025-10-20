function plotLocalTimeAxes(ax, xTickLabels)

%This function will plot the local time axes as well as the UTC time axes
%on the summary plots for the SEED data.  It is called by
%SEEDCDFSummaryPlots.m.
    	
additionalAxisTicks = {[18 19 20 21 22 23 0 1 2 3 4 5 6 7 8 9 10 ...
            11 12 13 14 15 16 17 18]};
    	
% Set up multi-line ticks
allTicks = [cell2mat(xTickLabels'); cell2mat(additionalAxisTicks')];
		
tickLabels = compose('%4d\\newline%4d', allTicks(:).');
    	
% The %4d adds space to the left so the labels are centered.	
% You'll need to add "%.1f\\newline" for each row of labels (change    
% formatting as needed). 	
% Alternatively, you can use the flexible line below that works with any    
% number of rows but uses the same formatting for all rows.	
%    tickLabels = compose(repmat('%.2f\\newline',1,size(allTicks,1)),    
%    allTicks(:).'); 

	
% Decrease axis height & width to make room for labels	
ax.Position(3:4) = ax.Position(3:4) * 0.75; % Reduced to 75%	
ax.Position(2) = ax.Position(2) + 0.2;  % move up

% Add x tick labels	
ax.XTickLabel = tickLabels;
ax.TickDir = 'out';
ax.XTickLabelRotation = 0;	

%Define each row of labels	
ax2 = axes('Position', [sum(ax.Position([1,3]))*1.08, ...
ax.Position(2), 0.02, 0.001]);
	
%Now lets force Matlab to keep the same properties for both axes by linking
%them together.   
linkprop([ax, ax2], {'TickDir', 'FontSize'});
	
axisLabels = {'Hours(UTC)', 'Hours(LT)'}; % one for each x-axis	
ax2.XTick = 0.5;
ax2.XLim = [0 1];
ax2.XTickLabelRotation = 0;
ax2.XTickLabel = strjoin(axisLabels, '\\newline');    

%Adjust as needed to align ticks between the two axes	
ax2.TickLength(1) = 0.2; 

end  %End of the function plotLocalTimeAxes.m