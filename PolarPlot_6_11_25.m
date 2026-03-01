%% Load your CSV
T = readtable('C:\Users\metal\Downloads\BRL_DATA_PLOT\6-11-25\chicken_impedance_phase_averages_rounded.csv');

%% Extract columns
Z = T.mean_impedance;        % magnitude (radius)
phase_deg = T.mean_phase;    % phase in degrees

%% Convert phase to radians for MATLAB
theta = deg2rad(phase_deg);

%% Create polar scatter plot
figure
pax = polaraxes;
hold on

polarplot(theta, Z, 'o', ...
    'MarkerSize', 8, ...
    'MarkerFaceColor', [0 0.447 0.741], ...
    'MarkerEdgeColor', 'k')

title('Polar Plot of Chicken Impedance Measurements')

%% Label each point with chicken number
for i = 1:length(Z)
    text(theta(i), Z(i), sprintf(' %d', T.chicken_num(i)), ...
        'FontSize', 10)
end

hold off
pax = gca;
pax.ThetaLim = [-10 10];   % adjust depending on your phase spread
pax.RLim = [min(Z)-50 max(Z)+50];