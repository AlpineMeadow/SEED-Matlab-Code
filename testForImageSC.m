%This script will read in a SEED data file and attempt to plot it as a
%spectrogram using imagesc.

dbstop if error;

clearvars;
close all;
fclose('all');


%Set the date.
year = 2025;
month = 1;
dayOfMonth = 5;
dayOfYear = 5;

%Set the filename to be read in.
filename = "STPSat-6_Falcon_SEED-L1_20250105_v02.cdf";

%Get the CDF data.
[data, CDFInfo] = spdfcdfread(filename);

%Get the data into the appropriate variables.
numVariables = length(data);

%Read the data into the CDF data structure.  
for numVar = 1 : numVariables
    CDFData.(CDFInfo.Variables{numVar, 1}) = data{numVar};
end

%I am going to convert the output times(given in datenums) into Matlab's
%datetime objects.
epochTime = datetime(CDFData.Epoch, 'ConvertFrom', 'datenum');
SEEDGoodTime = datetime(CDFData.SEED_Time_Dt15_Good, 'ConvertFrom', ...
    'datenum');
dosimeterTime = datetime(CDFData.SEED_Dosimeter_Time, 'ConvertFrom', ...
    'datenum');

%Now place them in the data structure.
CDFData.Epoch = epochTime;
CDFData.SEED_Time_Dt15_Good = SEEDGoodTime;
CDFData.SEED_Dosimeter_Time = dosimeterTime;




%Set up the y axis tick labels and values.
yTickLabels = {[20, 40, 60, 80, 100, 120, 140]};
yLimValues = [CDFData.SEED_Energy_Channels(1), ...
    CDFData.SEED_Energy_Channels(end)];
yTickValues = [20, 40, 60, 80, 100, 120, 140];

%Sometimes we do not want to make a large number of plots appear onto the
%screen.  This can happen when lots of plots are being made.  If we have
%lots of plots to make, then we tell Matlab not to make plots to the
%screen.
fig1 = figure('DefaultAxesFontSize', 12);


%Set up a set of axes for the plot.  Also, set the positions for both the
%figure and the axes.
ax = axes();
fig1.Position = [750 25 1200 500];
ax.Position = [0.13, 0.02, 0.995, 0.950];

%Get the variables out of the CDFData structure.
time = CDFData.Epoch;
energyBins = CDFData.SEED_Energy_Channels;
data = double(CDFData.SEED_Electron_Flux_Total);
numEnergyBins = length(energyBins);

%Due to the difference between UTC and GPS time systems the data may have
%been taken during the previous day.  Let us remove any data that
%corresponds to the day before. This should only be a couple of data
%points.
goodDayIndex = find(time.Day == dayOfMonth);
time = time(goodDayIndex);

%Set up the plot title as well as the plot file name.
satellite = "Falcon";
instrument = "SEED";
plotType = "Spectrogram";
dateStr = [num2str(2025), num2str(1, '%02d'), ...
    num2str(5, '%02d')];
doyStr = num2str(5, '%03d');

titStr = satellite + " " + instrument + " " + plotType + " " + dateStr + ...
    " " + doyStr;

saveName = satellite + instrument + plotType + "_" + ...
    dateStr + "_" + doyStr;

%Generate the SEED file name.
SEEDFileName = strcat(saveName, '.png');

%Let us now interpolate and smooth the data.
%First make an interpolation vector. We will interpolate onto a time grid
%with a delta t of 15 seconds.
timeSeconds = time.Hour*3600 + time.Minute*60 + time.Second;

%Convert from the datetime structure into seconds from start of the day.
%Set up a vector of times to be interpolated onto.
tt = 0:15:86399;
interpTime = datetime(year, month, dayOfMonth) + seconds(tt);

%Create a vector of x tick values.
xTickVals = NaT(1, 25);

for ii = 0 : 23
    hIndex = find(interpTime.Hour == ii);
    xTickVals(ii + 1) = interpTime(hIndex(1)');
    if ii == 23
        xTickVals(25) = interpTime(hIndex(end));
    end 
end

%Set up an interpolated flux array of size [5760,904]
interpFlux = zeros(length(tt), numEnergyBins);

smoothConstant = 50;

%Now we loop through the energy channels.
for e = 1 : numEnergyBins
    y = data(goodDayIndex, e);
    interpFlux(:, e) = smoothdata(interp1(timeSeconds, y, tt, 'linear'), ...
        'gaussian', smoothConstant);
end

%The array interpFlux can potentially have negative values most likely due
%to the interpolation/smoothing.  Lets get rid of them.
interpFlux(interpFlux < 0) = 0.001;

%The array interpFlux can potentially have NaN values.  Lets get rid of
%them.
NaNIndex = isnan(interpFlux);
interpFlux(NaNIndex) = 1.0;

interpFlux10 = log10(interpFlux);


imagesc(interpTime, energyBins, interpFlux10')
xticks(xTickVals)
ylabel('Energy (keV)')
title(titStr)
caxis([3 8])
cb = colorbar;
ylabel(cb,'Log_{10}(Flux)') 
ax.YDir = 'normal';
ax.YTick = yTickValues;
ax.YLim = yLimValues;
ax.YTickLabel = yTickLabels;

hold on

%Set up the x-axis tick labels and limits.
xTickLabels = {[0 : 23, 0]};


additionalAxisTicks = {[18 19 20 21 22 23 0 1 2 3 4 5 6 7 8 9 10 ...
            11 12 13 14 15 16 17 18]};
    	
% Set up multi-line ticks
allTicks = [cell2mat(xTickLabels'); cell2mat(additionalAxisTicks')];
		
%Now make the labels.
tickLabels = compose('%4d\\newline%4d', allTicks(:).');	

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

%Set up the axis labels. This will be placed to the side of the actual axes. 	
axisLabels = {'Hours(UTC)', 'Hours(LT)'}; % one for each x-axis	
ax2.XTick = 0.5;
ax2.XLim = [0 1];
ax2.XTickLabelRotation = 0;
ax2.XTickLabel = strjoin(axisLabels, '\\newline');    

%Adjust as needed to align ticks between the two axes	
ax2.TickLength(1) = 0.2; 



joe = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out, info] = spdfcdfread(filename, varargin)

if (nargin < 1)
    error('MATLAB:spdfcdfread:inputArgumentCount', ...
          'SPDFCDFREAD requires at least one input argument.')
end

if (nargout > 2)
    error('MATLAB:spdfcdfread:outputArguments', ...
          'SPDFCDFREAD requires two or fewer output argument.')
end

[args, msg, structure, show_progress] = parse_inputs(varargin{:});

if (args.DataOnly && (nargout == 2))
    error('MATLAB:spdfcdfread:outputArguments', ...
          'SPDFCDFREAD requires only one output argument for dataonly option.')
end

if (~isempty(msg))
    error('MATLAB:spdfcdfread:badInputArguments', '%s', msg)
end

validate_inputs(args);

if (~args.DataOnly) 
  if (args.CombineRecords)
    if (args.epochtodatenum == 1)
      args.ConvertEpochToDatestr = false;
      args.KeepEpochAsIs = false;
      args.CDFEpochToString = false;
    elseif (args.epochtodatestr == 1)
      args.ConvertEpochToDatenum = false;
      args.KeepEpochAsIs = false;
      args.CDFEpochToString = false;
    elseif (args.keepepoch == 1)
      args.ConvertEpochToDatenum = false;
      args.ConvertEpochToDatestr = false;
      args.CDFEpochToString = false;
    elseif (args.epochtostring == 1)
      args.ConvertEpochToDatenum = false;
      args.ConvertEpochToDatestr = false;
      args.KeepEpochAsIs = false;
    else
      args.ConvertEpochToDatenum = true;
      args.ConvertEpochToDatestr = false;
      args.KeepEpochAsIs = false;
      args.CDFEpochToString = false;
    end
  else
    if (args.epochtodatenum == 1)
      args.ConvertEpochToDatestr = false;
      args.KeepEpochAsIs = false;
      args.CDFEpochToString = false;
    elseif (args.epochtodatestr == 1)
      args.ConvertEpochToDatenum = false;
      args.KeepEpochAsIs = false;
      args.CDFEpochToString = false;
    elseif (args.keepepoch == 1)
      args.ConvertEpochToDatenum = false;
      args.ConvertEpochToDatestr = false;
      args.CDFEpochToString = false;
    elseif (args.epochtostring == 1)
      args.ConvertEpochToDatenum = false;
      args.ConvertEpochToDatestr = false;
      args.KeepEpochAsIs = false;
    else
      args.ConvertEpochToDatenum = false;
      args.ConvertEpochToDatestr = false;
      args.KeepEpochAsIs = false;
      args.CDFEpochToString = false;
    end
  end
end

%
% Verify existence of filename.
%

% Get full filename.
fid = fopen(filename);

if (fid == -1)
  
    % Look for filename with extensions.
    fid = fopen([filename '.cdf']);
    
    if (fid == -1)
        fid = fopen([filename '.CDF']);
    end
    
end

if (fid == -1)
    error('MATLAB:spdfcdfread:fileOpen', 'Couldn''t open file (%s).', filename)
else
    filename = fopen(fid);
    fclose(fid);
end

% CDFlib's OPEN_ routine is flakey when the extension ".cdf" is used.
% Strip the extension from the file before calling the MEX-file.

if ((length(filename) > 4) && (isequal(lower(filename((end-3):end)), '.cdf')))
    filename((end-3):end) = '';
end

if (args.DataOnly)
  out = spdfcdfreadc(filename, args.Variables, args.Records, ...
                     [], args.CombineRecords, ...
                     args.ConvertEpochToDatenum, structure, ...
                     args.KeepEpochAsIs, args.CDFEpochToString, ...
                     args.ConvertEpochToDatestr, args.DataOnly);
  if (numel(args.Variables) == 1)
    out = out{1};
  end
else

  %
  % Get information about the variables.
  %

  info = spdfcdfinfo(filename, 'VALIDATE', args.Validate);

  if (isempty(args.Variables))
    args.Variables = info.Variables(:, 1)';
  end

  % To make indexing info.Variables easier, reorder it to match the values in
  % args.Variables and remove unused values. Deblank variable list because
  % the intersection is based on the predicate of equality of strings.
  % Inconsistent trailing blanks in variable names from args and info may cause
  % inadvertent mismatch and consequent failure.
  [int, idx1, idx2] = intersect(deblank(args.Variables), ...
                                deblank(info.Variables(:, 1)));

  if (length(int) < length(args.Variables))
    
    % Determine which requested variables do not exist in the CDF.
    invalid = setdiff(args.Variables, int);
    
    msg = 'The following requested variables are not in this CDF:';
    msg = [msg sprintf('\n\t%s',invalid{:})];
    
    error('MATLAB:spdfcdfread:variableNotFound', '%s', msg)
    
  end

  % Remove unused variables.
  info.Variables = info.Variables(idx2, :);

  % Reorder the variables to match the order of args.Variables.
  [tmp, reorder_idx] = sort(idx1);
  info.Variables = info.Variables(reorder_idx, :);

  if (~structure) 
    if (isempty(args.Records))
      args.Records = find_records(info.Variables);
    elseif (any(args.Records < 0))
      error('MATLAB:spdfcdfread:recordNumber', 'Record values must be nonnegative.')
    end
  end

  %
  % Read each variable.
  %

  if (length(args.Variables) == 1)

    % Special case for single variable.
    if (info.Variables{3} == 0)
      out = [];
      return;
    end
    if (~isempty(args.Slices))
        [args.Slices, msg] = parse_slice_vals(args.Slices, info.Variables);
        if (~isempty(msg))
            error('MATLAB:spdfcdfread:sliceValue', '%s', msg)
        end
    else
        args.Slices = fill_slice_vals([], info.Variables);
    end
    [data, attrs] = spdfcdfreadc(filename, args.Variables{1}, args.Records, ...
                             args.Slices, args.CombineRecords, ...
                             args.ConvertEpochToDatenum, structure, ...
                             args.KeepEpochAsIs, args.CDFEpochToString, ...
                             args.ConvertEpochToDatestr, args.DataOnly);
    if (isequal(lower(info.Variables{4}), 'epoch16') && ...
        (args.KeepEpochAsIs)) data=transpose(data);
    end
    [dataX, dummy] = spdfcdfreadc('to_close', args.Variables{1}, args.Records, ...
                              args.Slices, args.CombineRecords, ...
                              args.ConvertEpochToDatenum, false, ...
                              args.KeepEpochAsIs, args.CDFEpochToString, ...
                              args.ConvertEpochToDatestr, args.DataOnly);

    if (~structure)
      if (isequal(lower(info.Variables{4}), 'tt2000'))
        if (args.CombineRecords || args.ConvertEpochToDatenum || ...
            args.KeepEpochAsIs || args.ConvertEpochToDatestr) 
          out = data;
        else
          if (length(data) > 1)
            for p = 1:length(data)
              if (length(data{p}) > 1)
                for q = 1:length(data{p})
                  databb(q) = cdftt2000(data{p}(q,1));
                end
                dataaa{p,1} = databb;
              else
                dataaa(p,1) = cdftt2000(data{p});
              end
            end
            out = dataaa;
          else
            out = cdftt2000(data);
          end
        end
      elseif (isequal(lower(info.Variables{4}), 'epoch'))
        if (args.ConvertEpochToDatenum || args.CDFEpochToString || ...
            args.KeepEpochAsIs || args.ConvertEpochToDatestr || ...
            args.CombineRecords)
          out = data;
        else
          if (~args.ConvertEpochToDatenum)
            %
            % None option - set up for cdfepoch object
            %
            if (length(data) > 1)
              for p = 1:length(data)
                if (length(data{p}) > 1)
                  for q = 1:length(data{p})
                    databb(q) = cdfepoch(data{p}(q,1));
                  end
                  dataaa{p,1} = databb;
                else
                  dataaa(p,1) = cdfepoch(data{p});
                end
              end
              out = dataaa;
            else
              out = cdfepoch(data);
            end
          else
            out = data;
          end
        end
      elseif (isequal(lower(info.Variables{4}), 'epoch16') && ...
              args.KeepEpochAsIs)
          out = transpose(data);
      else
        out = data;
      end
    else
      out.VariableName = args.Variables{1};
      out.Data = data;
      out.Attributes = attrs;
    end

  elseif ((~isempty(args.Slices)) && (length(args.Variables) ~= 1))

    error('MATLAB:spdfcdfread:sliceValue', 'Specifying variable slices requires just one variable.')

  else
    if (structure)
      % Regular reading.
      out1 = cell(length(args.Variables),3);
      for p = 1:length(args.Variables)
        if (show_progress)
            fprintf ('%d) Reading variable "%s"\n', p, args.Variables{p});
        end
        if (info.Variables{p, 3} == 0)
          continue;
        end
 
        args.Slices = fill_slice_vals([], info.Variables(p,:));
        out1{p,1} = args.Variables{p};
        [datax, attrs]  = spdfcdfreadc(filename, args.Variables{p}, args.Records, ...
                                   args.Slices, args.CombineRecords, ...
                                   args.ConvertEpochToDatenum, true, ...
                                   args.KeepEpochAsIs, ...
                                   args.CDFEpochToString, ...
                                   args.ConvertEpochToDatestr, args.DataOnly);
        if (isequal(lower(info.Variables{p, 4}), 'epoch16'))
          if (args.KeepEpochAsIs)
            out1{p,2} = transpose(datax);
          else
            out1{p,2} = datax;
          end
        else
          out1{p,2} = datax;
        end
        out1{p,3} = attrs;
      end
      [dataX, dummy]  = spdfcdfreadc('to_close', args.Variables{1}, args.Records, ...
                                args.Slices, args.CombineRecords, ...
                                args.ConvertEpochToDatenum, false, ...
                                args.KeepEpochAsIs, ... 
                                args.CDFEpochToString, ...
                                args.ConvertEpochToDatestr, args.DataOnly);

      % Change a cell array to an array of structures.
      fields = {'VariableName', 'Data', 'Attributes'};
      out = cell2struct(out1, fields, 2); 
      if (~structure)
        out = arrayfun(@(x)x.Data,out,'UniformOutput',false);
      end

    else

      if (args.CombineRecords)
          data = cell(1, length(args.Variables));
      else
          data = cell(length(args.Records), length(args.Variables));
      end

      for p = 1:length(args.Variables)
        if (show_progress)
            fprintf ('%d) Reading variable "%s"\n', p, args.Variables{p});
        end
        if (info.Variables{p, 3} == 0)
          continue;
        end

        args.Slices = fill_slice_vals([], info.Variables(p,:));

        if (info.Variables{p, 5}(1) == 'F')
% Non-record variant
            % Special case for variables which don't vary by record.
            [xdata, dummy] = spdfcdfreadc(filename, args.Variables{p}, 0, ...
                                      args.Slices, ...
                                      args.CombineRecords, ...
                                      args.ConvertEpochToDatenum, false, ...
                                      args.KeepEpochAsIs, ...
                                      args.CDFEpochToString, ...
                                      args.ConvertEpochToDatestr, args.DataOnly);
            if (args.CombineRecords)
              if (isequal(lower(info.Variables{p, 4}), 'epoch16'))
                if (args.KeepEpochAsIs)
                  data{p} = transpose(xdata);
                else
                  data{p} = xdata;
                end
              else
                data{p} = xdata;
              end
%              data{p} = xdata;
            else
              data(:,p) = repmat(xdata, length(args.Records), 1);
            end

        else
% Record variant
            [xdata, dummy] = spdfcdfreadc(filename, args.Variables{p}, ...
                                      args.Records, args.Slices, ...
                                      args.CombineRecords, ...
                                      args.ConvertEpochToDatenum, ... 
                                      false, ...
                                      args.KeepEpochAsIs, ...
                                      args.CDFEpochToString, ...
                                      args.ConvertEpochToDatestr, args.DataOnly);
            if (args.CombineRecords)
              if (isequal(lower(info.Variables{p, 4}), 'epoch16') && ...
                  args.KeepEpochAsIs)
                 data{p} = transpose(xdata);
              else
                data{p} = xdata;
              end
            else
              % M-by-N cell array....
              % Convert epoch data.
              if (isequal(lower(info.Variables{p, 4}), 'tt2000'))
                if (args.CombineRecords || args.ConvertEpochToDatenum || ...
                    args.KeepEpochAsIs || args.ConvertEpochToDatestr)
                  data(:,p) = xdata;
                else
                  for q = 1:length(xdata)
                    if (length(xdata{q}) > 1)
                      for r = 1:length(xdata{q})
                        databb(r,1) = cdftt2000(xdata{q}(r,1));
                      end
                      data{q,p} = databb;
                    else
                      data{q,p} = cdftt2000(xdata{q});
                    end
                  end
                end
              elseif (isequal(lower(info.Variables{p, 4}), 'epoch'))
                if (args.CDFEpochToString || args.KeepEpochAsIs || ...
                    args.CombineRecords || ...
                    args.ConvertEpochToDatenum || args.ConvertEpochToDatestr)
                  data(:,p) = xdata;
                elseif (~args.ConvertEpochToDatenum)
                  %
                  % None option case - set up to cdfepoch object
                  %
                  if (length(xdata) > 1)
                    for q = 1:length(xdata)
                      if (length(xdata{q}) > 1)
                        for r = 1:length(xdata{q})
                          databb(r,1) = cdfepoch(xdata{q}(r,1));
                        end
                        data{q,p} = databb;
                      else
                        data{q,p} = cdfepoch(xdata{q});
                      end
                    end
                  end
                else
                  data{1,p} = cdfepoch(xdata);
                end
              elseif (isequal(lower(info.Variables{p, 4}), 'epoch16'))
                if (args.KeepEpochAsIs)
                  data(:,p) = transpose(xdata);
                else
                  data(:,p) = xdata;
                end
              else
                data(:,p) = xdata;
              end
            end

        end

      end
      [dataX, dummy]  = spdfcdfreadc('to_close', args.Variables{1}, args.Records, ...
                               args.Slices, args.CombineRecords, ...
                               args.ConvertEpochToDatenum, false, ...
                               args.KeepEpochAsIs, args.CDFEpochToString, ...
                               args.ConvertEpochToDatestr, args.DataOnly);
      out = data;
    end
  end

end

end  %End of the function spdfcdfread.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%
%%% Function find_records
%%%

function records = find_records(var_details)

% Find which variables to consider.
rec_values = [var_details{:, 3}];
max_record = max(rec_values);

if (isempty(max_record))
  records = [];
else
  records = 0:(max_record - 1);
end

end %End of the function find_records.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%
%%% Function parse_fill_vals
%%%

function [slices, msg] = parse_slice_vals(slices, var_details)

msg = '';

% Find the number of dimensions that the CDF recognizes.  This is given
% explicitly in the variance specification as the number of values to the
% right of the '/' (i.e., the length of the variance string minus two).
vary = var_details{5};
num_cdf_dims = size(vary, 2) - 2;


%
% Check the user-provided slice values.
%

if (num_cdf_dims < size(slices, 1))
    msg = sprintf(['Number of slice rows (%d) exceeds number of' ...
                   ' dimensions (%d) in CDF variable.'], ...
                  size(slices, 1), num_cdf_dims);
    return
end

if (any(slices(:,1) < 0))
    
    msg = 'Slice indices must be nonnegative.';
    return
    
elseif (any(slices(:,2) < 1))
    
    msg = 'Slice interval values must be positive.';
    return
    
elseif (any(slices(:,3) < 1))
    
    msg = 'Slice count values must be positive.';
    return
    
end

for p = 1:size(slices,1)
    
    % Indices are zero-based.
    max_idx = var_details{2}(p) - 1;
    last_requested = slices(p,1) + (slices(p,3) - 1) * slices(p,2);
    
    if (last_requested > max_idx)
        
        msg = sprintf(['Slice values for dimension %d exceed maximum' ...
                       ' index (%d).'], p, max_idx);
        return
        
    end
end

% Append unspecified slice values.
slices = fill_slice_vals(slices, var_details);

end  %End of the function parse_slice_vals.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%
%%% Function fill_slice_vals
%%%

function slices = fill_slice_vals(slices, var_details)

dims = var_details{2};
vary = var_details{5};
num_cdf_dims = size(vary, 2) - 2;

if (num_cdf_dims > size(slices, 1))
    
    % Fill extra dimensions.
    for p = (size(slices, 1) + 1):(num_cdf_dims)
        slices(p, :) = [0 1 dims(p)];
    end
    
elseif (num_cdf_dims == 0)
    
    % Special case for scalar values.
    slices = [0 1 1];
    
end


end  %End of the function fill_slice_vals.m

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Function parse_inputs
%%%

function [args, msg, structure, show_progress] = parse_inputs(varargin)
% Set default values
show_progress = false;
structure = false;
args.CombineRecords = true;
args.ConvertEpochToDatenum = true;
args.ConvertEpochToDatestr = false;
args.KeepEpochAsIs = false;
args.CDFEpochToString = false;
args.DataOnly = false;
args.Validate = false;
args.Records = [];
args.Slices = [];
args.Variables = {};
args.epochtodatenum = 0;
args.epochtodatestr = 0;
args.keepepoch = 0;
args.epochtostring = 0;
msg = '';

% Parse arguments based on their number.
if (nargin > 0)
    paramStrings = {'variables'
                    'records'
                    'slices'
                    'convertepochtodatenum'
                    'convertepochtodatestr'
                    'keepepochasis'
                    'combinerecords'
                    'structure'
                    'cdfepochtostring'
                    'dataonly'
                    'validate'
                    'showprogress'};
    
    % For each pair
    for k = 1:2:length(varargin)
       param = lower(varargin{k});
       
            
       if (~ischar(param))
           msg = 'Parameter name must be a string.';
           return
       end

       idx = strmatch(param, paramStrings);
       
       if (isempty(idx))
           msg = sprintf('Unrecognized parameter name "%s".', param);
           return
       elseif (length(idx) > 1)
           msg = sprintf('Ambiguous parameter name "%s".', param);
           return
       end
    
       switch (paramStrings{idx})
       case 'variables'
           
           if (k == length(varargin))
               msg = 'No variables specified.';
               return
           else
               
               args.Variables = varargin{k + 1};
               
               if (~iscell(args.Variables))
                   args.Variables = {args.Variables};
               end
               
               for p = 1:length(args.Variables)
                   if (~ischar(args.Variables{p}))
                       msg = 'All variable names must be strings.';
                       return
                   end
               end
           end
           
       case 'records'
           
           if (k == length(varargin))
               msg = 'No records specified.';
               return
           else
               
               records = varargin{k + 1};
               
               if ((~isa(records, 'double')) || ...
                   (length(records) ~= numel(records)) || ...
                   (any(rem(records, 1))))
                   
                   msg = 'Record list must be a vector of integers.';
                   
               end
               args.Records = records;
               args.CombineRecords = false;	
           end
           
       case 'slices'
           
           if (k == length(varargin))
               msg = 'No slice values specified.';
               return
           else
               
               slices = varargin{k + 1};
               
               if ((~isa(slices, 'double')) || ...
                   (size(slices, 2) ~= 3) || ...
                   (~isempty(find(rem(slices, 1) ~= 0))))
                   
                   msg = 'Variable slice values must be n-by-3 array of integers.';
                   return
               end
               
               args.Slices = slices;
           end
           
       case 'convertepochtodatenum'
           
           if (k == length(varargin))
               msg = 'No epoch conversion value specified.';
               return
           else
               convert = varargin{k + 1};
               if (numel(convert) ~= 1)
                   msg = 'Epoch conversion value must be a scalar logical.';
               end
               
               if (islogical(convert))
                   args.ConvertEpochToDatenum = convert;
               elseif (isnumeric(convert))
                   args.ConvertEpochToDatenum = logical(convert);
               else
                   msg = 'Epoch conversion value must be a scalar logical.';
               end
               if (args.ConvertEpochToDatenum == 1)
                 args.epochtodatenum=1;
               end
           end

       case 'convertepochtodatestr'

           if (k == length(varargin))
               msg = 'No epoch conversion value specified.';
               return
           else
               convert = varargin{k + 1};
               if (numel(convert) ~= 1)
                   msg = 'Epoch conversion value must be a scalar logical.';
               end

               if (islogical(convert))
                   args.ConvertEpochToDatestr = convert;
               elseif (isnumeric(convert))
                   args.ConvertEpochToDatestr = logical(convert);
               else
                   msg = 'Epoch conversion value must be a scalar logical.';
               end
               if (args.ConvertEpochToDatestr == 1)
                 args.epochtodatestr=1;
               end
           end

       case 'combinerecords'
           
           if (k == length(varargin))
               msg = 'Missing "CombineRecords" value.';
               return
           else
               combine = varargin{k + 1};
               if (numel(combine) ~= 1)
                   msg = 'The "CombineRecords" value must be a scalar logical.';
               end
               
               if (islogical(combine))
                   args.CombineRecords = combine;
               elseif (isnumeric(combine))
                   args.CombineRecords = logical(combine);
               else
                   msg = 'The "CombineRecords" value must be a scalar logical.';
               end
           end

       case 'showprogress'
  
           if (k == length(varargin))
               msg = 'Missing "ShowProgress" value.';
               return
           else
               sp = varargin{k + 1};
               if (numel(sp) ~= 1)
                   msg = 'The "ShowProgress" value must be a scalar logical.';
               end
  
               if (islogical(sp))
                   show_progress = sp;
               elseif (isnumeric(sp))
                   show_progress = logical(sp);
               else
                   msg = 'The "ShowProgress" value must be a scalar logical.';
               end
           end
 
       case 'structure'
  
           if (k == length(varargin))
               msg = 'Missing "Structure" value.';
               return
           else
               sp = varargin{k + 1};
               if (numel(sp) ~= 1)
                   msg = 'The "Structure" value must be a scalar logical.';
               end
  
               if (islogical(sp))
                   structure = sp;
               elseif (isnumeric(sp))
                   structure = logical(sp);
               else
                   msg = 'The "Structure" value must be a scalar logical.';
               end
           end

       case 'keepepochasis'

           if (k == length(varargin))
               msg = 'No KeepEpochAsIs value specified.';
               return
           else
               keepasis = varargin{k + 1};
               if (numel(keepasis) ~= 1)
                   msg = 'KeepEpochAsIs value must be a scalar logical.';
               end
               if (islogical(keepasis))
                   args.KeepEpochAsIs = keepasis;
               elseif (isnumeric(keepasis))
                   args.KeepEpochAsIs = logical(keepasis);
               else
                   msg = 'KeepEpochAsIs value must be a scalar logical.';
               end
               if (args.KeepEpochAsIs ==1)
                 args.keepepoch=1;
               end
           end
 
       case 'dataonly'

           if (k == length(varargin))
               msg = 'No dataonly value specified.';
               return
           else
               dataonly = varargin{k + 1};
               if (numel(dataonly) ~= 1)
                   msg = 'dataonly value must be a scalar logical.';
               end
               if (islogical(dataonly))
                   args.DataOnly = dataonly;
               elseif (isnumeric(dataonly))
                   args.DataOnly = logical(dataonly);
               else
                   msg = 'dataonly value must be a scalar logical.';
               end
	       if (args.DataOnly)
		 args.CombineRecords = true;
		 args.KeepEpochAsIs = true;
		 args.ConvertEpochToDatenum = false;
	       end
           end
 
       case 'validate'

           if (k == length(varargin))
               msg = 'No validate value specified.';
               return
           else
               validate = varargin{k + 1};
               if (numel(validate) ~= 1)
                   msg = 'validate value must be a scalar logical.';
               end
               if (islogical(validate))
                   args.Validate = validate;
               elseif (isnumeric(validate))
                   args.Validate = logical(validate);
               else
                   msg = 'validate value must be a scalar logical.';
               end
           end
 
       case 'cdfepochtostring'

           if (k == length(varargin))
               msg = 'No CDFEpochToString value specified.';
               return
           else
               epochtostring = varargin{k + 1};
               if (numel(epochtostring) ~= 1)
                   msg = 'CDFEpochToString value must be a scalar logical.';
               end

               if (islogical(epochtostring))
                   args.CDFEpochToString = epochtostring;
               elseif (isnumeric(epochtostring))
                   args.CDFEpochToString = logical(epochtostring);
               else
                   msg = 'CDFEpochToString value must be a scalar logical.';
               end
               if (args.CDFEpochToString == 1)
                 args.epochtostring=1;
               end
           end
 
       end  % switch
    end  % for

end  % if (nargin > 1)

end %End of the function parse_inputs.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function epochs = convert_epoch(epoch_nums, convertToDatenum)
%CONVERT_EPOCH   Convert numeric epoch values to CDFEPOCH objects.

% Note: MATLAB datenums are the number of days since 00-Jan-0000, while the
%       CDF epoch is the number of milliseconds since 01-Jan-0000. 

% Convert values from milliseconds to MATLAB serial dates.
ml_nums = (epoch_nums ./ 86400000) + 1;

% Convert MATLAB serial dates to CDFEPOCH objects.
if (convertToDatenum)
    epochs = ml_nums;
else
    epochs = cdfepoch(ml_nums);
end

end %End of the function convert_epoch.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function validate_inputs(args)
%VALIDATE_INPUTS   Ensure that the mutually exclusive options weren't provided.

if ((args.CombineRecords) && (~isempty(args.Records)))
    error('MATLAB:spdfcdfread:combineRecordSubset', '%s\n%s', ...
          'You cannot currently combine a subset of records.', ...
          'Specify only one of ''CombineRecords'' and ''Records''.')
end

if ((args.epochtodatenum == 1) && (args.epochtodatestr == 1))
    error('MATLAB:spdfcdfread:Epochmutualexclusive', '%s\n', ...
          'Specify only one of ''ConvertEpochToDatenum'' and ''ConvertEpochToDatestr'' to true.')
end

if ((args.epochtodatenum == 1) && (args.keepepoch == 1))
    error('MATLAB:spdfcdfread:Epochmutualexclusive', '%s\n', ...
          'Specify only one of ''ConvertEpochToDatenum'' and ''KeepEpochAsIs'' to true.')
end

if ((args.epochtodatestr == 1) && (args.keepepoch == 1))
    error('MATLAB:spdfcdfread:Epochmutualexclusive', '%s\n', ...
          'Specify only one of ''ConvertEpochToDatestr'' and ''KeepEpochAsIs'' to true.')
end

if ((args.epochtostring == 1) && (args.keepepoch == 1))
    error('MATLAB:spdfcdfread:Epochmutualexclusive', '%s\n', ...
          'Specify only one of ''CDFEpochToString'' and ''KeepEpochAsIs'' to true.')
end

if ((args.epochtostring == 1) && (args.epochtodatenum == 1))
    error('MATLAB:spdfcdfread:Epochmutualexclusive', '%s\n', ...
          'Specify only one of ''CDFEpochToString'' and ''ConvertEpochToDatenum'' to true.')
end

if ((args.epochtostring == 1) && (args.epochtodatestr == 1))
    error('MATLAB:spdfcdfread:Epochmutualexclusive', '%s\n', ...
          'Specify only one of ''CDFEpochToString'' and ''ConvertEpochToDatestr'' to true.')
end

end  %End of the function validate_inputs.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
