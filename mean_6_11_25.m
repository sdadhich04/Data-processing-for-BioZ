%% Load your CSV
T = readtable('C:\Users\metal\Downloads\BRL_DATA_PLOT\6-11-25\chicken_impedance_phase_averages_rounded.csv');

samples = T.chicken_num;
Z = T.mean_impedance;
phase = T.mean_phase;

%% Plot impedance means
figure
scatter(samples, Z, 90, 'filled')
xlabel('Chicken Sample')
ylabel('Mean Impedance (Ohms)')
title('Mean Impedance per Chicken Sample')
grid on

%% Optional: label each point
hold on
for i = 1:length(samples)
    text(samples(i), Z(i), sprintf(' %d', samples(i)), 'FontSize',10);
end
hold off