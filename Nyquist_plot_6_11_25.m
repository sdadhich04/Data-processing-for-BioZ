%% Load your CSV
T = readtable('C:\Users\metal\Downloads\BRL_DATA_PLOT\6-11-25\chicken_impedance_phase_averages_rounded.csv');

%% Extract values
Zmag = T.mean_impedance;      % magnitude of impedance
phase_deg = T.mean_phase;     % phase in degrees

%% Convert to radians
phase_rad = deg2rad(phase_deg);

%% Convert to real and imaginary components
Zreal = Zmag .* cos(phase_rad);
Zimag = Zmag .* sin(phase_rad);

%% Nyquist plot
figure
scatter(Zreal, -Zimag, 90, T.chicken_num, 'filled')

xlabel('Real(Z)  (Ohms)')
ylabel('-Imag(Z)  (Ohms)')
title('Nyquist Plot of Chicken Bioimpedance Measurements')
grid on
axis equal
colormap(parula)

%% Label each point
hold on
for i = 1:length(Zreal)
    text(Zreal(i), -Zimag(i), sprintf(' %d', T.chicken_num(i)), ...
        'FontSize', 10);
end
hold off