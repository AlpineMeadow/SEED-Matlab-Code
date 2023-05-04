function [leftEdge, totalWidth, subplotHeight, bottom] = getSubplotPositions(numSubplots);
  %This function will return the left, width, height and bottom values for
  %various numbers of subplots made. 

  %These values will not change so lets leave them up here at the top.  If
  %necessary a single change will take care of these values.
  leftEdge = 0.1;
  totalWidth = 0.8;

  if(numSubplots == 2)
	  subplotHeight = 0.39;
	  bottom = [0.53, 0.1];
  end

  if(numSubplots == 3)
	  subplotHeight = 0.25;
	  bottom = [0.71, 0.40, 0.08];
  end

  if(numSubplots == 4)
	  subplotHeight = 0.20;
	  bottom = [0.73, 0.52, 0.31, 0.1];
  end

  if(numSubplots == 5)
	  height = 0.15;
	  bottom = [0.78, 0.62, 0.46, 0.30, 0.14];
  end

  

end  %End of the function getSubplotPositions.m