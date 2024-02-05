%% Calculate average of ICA across the trials and excluding basline
srate=512;
datasetname=EEG.setname;
averageICA = mean(EEG.icaact, 3);
%exluding before stimulus
averageICA=averageICA(:,102:end);
averageICABrain=averageICA;

%% computing activity 
% all rows
numRows = size(averageICABrain, 1);
allOnset=zeros(1, numRows);
allOffset=zeros(1, numRows);
allActivityDurations = zeros(1, numRows);
allPeak=zeros(1,numRows);
% Loop through each row
for i = 1:numRows
    component = averageICABrain(i, :);
    
    % Calculate activity duration for each row
    [onset,offset,activityDuration] = FWHM(component, srate);
    allOnset(i)=onset;
    allOffset(i)=offset;
    allActivityDurations(i) = activityDuration;
    [maxValue, maxIndex] = max(abs(component));
    maxTime = (maxIndex - 1) * 1000 / srate;
    allPeak(i)=maxTime;
    % Display or store the result as needed
   % disp(['Activity onset for Row ', num2str(i), ': ', num2str(onset), ' mili seconds']);
    %disp(['Activity offset for Row ', num2str(i), ': ', num2str(offset), ' mili seconds']);
    %disp(['Activity duration for component ', num2str(i), ': ', num2str(activityDuration), ' mili seconds'])
end

%% computing intersection
intersection_times = zeros(numRows, numRows);
intersection_ratios = zeros(numRows, numRows);
% Loop through each pair of subjects

for i = 1:numRows
    for j = 1:numRows
        % Calculate intersection time
        intersection_times(i, j) = max(0, min(allOffset(i), allOffset(j)) - max(allOnset(i), allOnset(j)));
        
        % Calculate intersection time ratio
        intersection_ratios(i, j) = round((intersection_times(i, j) / allActivityDurations(i))*100)/100;
    end
    
end
filename = [datasetname '_in_ratios.txt'];
save(filename, 'intersection_ratios', '-ascii');
% Display or use the intersection_times matrix as needed
%disp('Intersection Times Matrix:');
%disp(intersection_times);
%%
%average
summ = sum(intersection_ratios(:))-numRows;
average=summ/((numRows*numRows)-numRows);
disp(average);
%% heatmap intersection time
% Create a heatmap
h = heatmap(intersection_ratios);
% Modify the colormap
newColormap = jet;  % Replace 'jet' with your desired colormap
h.Colormap = newColormap;
% Add labels and title
xlabel('components');
ylabel('components');
title('Activity overlap ratio  overal Average: 0.76');

% figFilename = [datasetname '_heatmap_intersection_ratios.fig'];
% saveas(h, figFilename);

%%
% Define the number of components per figure
componentsPerFigure = 20;

% Calculate the number of figures needed
numFigures = ceil(numRows / componentsPerFigure);

% Loop through each figure
for fig = 1:numFigures
    figure;
    
    % Calculate the indices of the components to plot in this figure
    startIdx = (fig - 1) * componentsPerFigure + 1;
    endIdx = min(fig * componentsPerFigure, numRows);
    
    % Loop through each component in this figure
    for i = startIdx:endIdx
        subplot(5, 3, i - startIdx + 1);
        component = averageICABrain(i, :);
        
        % Plot the component with time in milliseconds
        timeInMilliseconds = (1:size(averageICABrain, 2)) * 1000 / srate;
        plot(timeInMilliseconds, component, 'LineWidth', 2);
        
        % Add a light line at y = 0
        hold on;
        plot([min(timeInMilliseconds), max(timeInMilliseconds)], [0, 0], '--', 'Color', [0.8, 0.8, 0.8]);
        
        % Highlight the component line between onset and offset with a different color
        onsetTime = allOnset(i);
        offsetTime = allOffset(i);
        highlightSegment = component(timeInMilliseconds >= onsetTime & timeInMilliseconds <= offsetTime);
        timeSegment = timeInMilliseconds(timeInMilliseconds >= onsetTime & timeInMilliseconds <= offsetTime);
        plot(timeSegment, highlightSegment, 'Color', [0, 0.7, 0], 'LineWidth', 2, 'DisplayName', 'Active Segment');
        
        % % Find the position and value of the peak (maximum absolute value)
        % [maxValue, maxIndex] = max(abs(component));
        % maxTime = (maxIndex - 1) * 1000 / srate;
        % 
        % % Draw a vertical line at the peak
        % plot(maxTime, maxValue, 'bx', 'MarkerSize', 10, 'DisplayName', 'Max Value');
        
        % Set y-axis limits symmetrically around zero
        ylim([-max(abs(ylim)), max(abs(ylim))]);
        
        % Add labels and title
        xlabel('Time (milliseconds)');
        ylabel('Amplitude');
        title(['IC ', num2str(i), ' with Active Segment']);
        
        hold off;
    end
    
    % Place the legend outside the loop to create a single legend for the figure
    legend('average component', 'zero line', 'Active Segment');
end
% figFilename = [datasetname '_activation.fig'];
% saveas(gcf, figFilename);
