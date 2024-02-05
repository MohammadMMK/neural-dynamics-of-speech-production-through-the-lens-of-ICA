function [output1, output2, output3] = FWHM(component, srate)
    % Input validation
    if ~isvector(component)
        error('Input must be a vector.');
    end

    % Calculate FWHM
    maxAmplitude = max(abs(component));
    Onset = ((find(abs(component) >= 0.5 * maxAmplitude, 1))*(1000/srate));
    lastIndexAboveHalfMax = numel(component) - find(flip(abs(component)) >= 0.5 * maxAmplitude, 1) + 1;
    offset=lastIndexAboveHalfMax*(1000/srate);
    activityDuration = offset-Onset;
    output1=Onset;
    output2=offset;
    output3 = activityDuration;
end