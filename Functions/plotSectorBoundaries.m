function plotSectorBoundaries(ax, yLimValues, dt)

%This function is called by SEEDCDFSummaryPlots.m.  It will plot the sector
%boundaries, that is, the boundary in time for midnight, dawn, noon and
%dusk.
       
%Here we find the local time boundaries in terms of UTC time.
dawnLocalTimeIndex = find(dt.Hour == 9);
noonLocalTimeIndex = find(dt.Hour == 15);
duskLocalTimeIndex = find(dt.Hour == 21);
midnightLocalTimeIndex = find(dt.Hour == 3);


Dusk = plot(ax, [dt(duskLocalTimeIndex(1)), dt(duskLocalTimeIndex(1))], ...
            [yLimValues(1), yLimValues(2)], 'black'); 
Dusk.LineWidth = 2;  
text('Units', 'Normalized', 'Position', [0.012, 0.95], 'string', 'Dusk', ...
            'FontSize', 15);    
text('Units', 'Normalized', 'Position', [0.01, 0.9], 'string', 'Sector', ...
            'FontSize', 15);
    
Midnight = plot(ax, [dt(midnightLocalTimeIndex(1)), ...
           dt(midnightLocalTimeIndex(1))], ...
            [yLimValues(1), yLimValues(2)], 'black');    
Midnight.LineWidth = 2;
text('Units', 'Normalized', 'Position', [0.22, 0.95], 'string', 'Midnight', ...
        'FontSize', 15);    
text('Units', 'Normalized', 'Position', [0.24, 0.9], 'string', 'Sector', ...
        'FontSize', 15);

Dawn = plot(ax, [dt(dawnLocalTimeIndex(1)), dt(dawnLocalTimeIndex(1))], ...
            [yLimValues(1), yLimValues(2)], 'black');    
Dawn.LineWidth = 2;
text('Units', 'Normalized', 'Position', [0.46, 0.95], 'string', 'Dawn', ...
            'FontSize', 15);    
text('Units', 'Normalized', 'Position', [0.46, 0.9], 'string', 'Sector', ...
        'FontSize', 15);
    
Noon = plot(ax, [dt(noonLocalTimeIndex(1)), dt(noonLocalTimeIndex(1))], ...
            [yLimValues(1), yLimValues(2)], 'black');    
Noon.LineWidth = 2;    
text('Units', 'Normalized', 'Position', [0.7, 0.95], 'string', 'Noon', ...
        'FontSize', 15);    
text('Units', 'Normalized', 'Position', [0.7, 0.9], 'string', 'Sector', ...
        'FontSize', 15);

end  %End of function plotSectorBoundaries.m