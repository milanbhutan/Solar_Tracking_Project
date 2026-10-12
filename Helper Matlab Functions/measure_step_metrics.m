function [peak_time, percent_overshoot, settling_time_2pct, steady_state_error] = ...
    measure_step_metrics(y, t, ref)
%MEASURE_STEP_METRICS Measure standard step-response performance metrics.

y = y(:);
t = t(:);

if numel(y) ~= numel(t)
    error('y and t must contain the same number of samples.')
end

% Peak value and peak time
[peak_value, peak_index] = max(y);
peak_time = t(peak_index);

% Percent overshoot
percent_overshoot = max(0, ...
    100 * (peak_value - ref) / abs(ref));

% Steady-state value: average final 10% of samples
tail_length = max(5, round(0.10 * numel(y)));
steady_state_value = mean(y(end-tail_length+1:end));
steady_state_error = ref - steady_state_value;

% 2% settling time
settling_band = 0.02 * abs(ref);
last_outside_index = find(abs(y - ref) > settling_band, 1, 'last');

if isempty(last_outside_index)
    settling_time_2pct = t(1);
elseif last_outside_index == numel(t)
    settling_time_2pct = NaN;
    warning('Response did not settle within the provided time vector.')
else
    settling_time_2pct = t(last_outside_index + 1);
end
end