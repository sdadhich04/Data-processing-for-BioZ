%% Load your CSV
T = readtable('C:\Users\metal\Downloads\BRL_DATA_PLOT\6-11-25\chicken_impedance_phase_averages_rounded.csv');

%% Extract columns
Z = T.mean_impedance;
phase = T.mean_phase;
labels = T.chicken_num;

%% Scatter plot
figure
scatter(Z, phase, 90, labels, 'filled')

xlabel('Mean Impedance (Ohms)')
ylabel('Mean Phase (degrees)')
title('Chicken Samples: Impedance vs Phase')
grid on
colormap(parula)

%% Add labels for each point
hold on
for i = 1:length(Z)
    text(Z(i), phase(i), sprintf(' %d', labels(i)), 'FontSize', 10);
end
hold off