
% Initialize a cell array to store the results
AICA_sub = cell(1, 16);

% Loop through each element in EEG and calculate the mean for AICA
for i = 1:16
    AICA_sub{i} = mean(EEG(i).icaact(:,102:end,:), 3);
end

% Assuming your data is stored in a cell array named 'data', where each element is a 9x308 matrix
% The data structure might look like: data = {cell1, cell2, ..., cell16};


% Extract the first row from each cell
first_row_data = cellfun(@(cell) cell(1, :), AICA_sub, 'UniformOutput', false);

% Create a figure
figure;

% Plot each first row
hold on;
for i = 1:numel(first_row_data)
    plotObject(i) = plot(first_row_data{i}, DisplayName='subject-'+string(i));
    set(plotObject(i), 'ButtonDownFcn', {@myLineCallback, plotObject(i)});
end
hold off;

% Add labels and legend
xlabel('time in milliseconds');
ylabel('amplitude');
title('First IC of Each Cell');
legend('show');

