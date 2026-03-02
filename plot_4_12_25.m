T = readtable('C:\Users\metal\Downloads\BRL_DATA_PLOT\04-12-25\2025-12-04_d6e85c72_ESP32_Impedance_Monitor_TPT_single.csv', ...
    'ReadVariableNames', false);

Zmag = T.Var1;           % impedance magnitude
phaseDeg = T.Var2;       % phase
labels = string(T.Var3); % sample label text

[unique_labels,~,sampleID] = unique(labels);

u = unique(sampleID);
nS = length(u);

meanZ = zeros(nS,1);
sdZ   = zeros(nS,1);

for i = 1:nS
    idx = sampleID == u(i);
    vals = Zmag(idx);
    meanZ(i) = mean(vals);
    sdZ(i)   = std(vals);
end

figure
tiledlayout('flow')
for i = 1:nS
    idx = find(sampleID == u(i));
    nexttile
    plot(1:length(idx), Zmag(idx), 'o-','LineWidth',1.2)
    title(unique_labels(i))
    xlabel('Measurement #')
    ylabel('|Z| (Ohms)')
    grid on
end

figure
boxplot(Zmag, sampleID, 'Labels', unique_labels)
ylabel('|Z| (Ohms)')
title('Impedance Distribution per Chicken Sample')
grid on

figure
errorbar(1:nS, meanZ, sdZ, 'o', 'LineWidth',1.5, 'MarkerSize',8, 'CapSize',10)
xticks(1:nS)
xticklabels(unique_labels)
xtickangle(30)
ylabel('|Z| (Ohms)')
title('Mean Impedance ± SD per Sample')
grid on

hold on
scatter(sampleID, Zmag, 20, 'filled', 'MarkerFaceAlpha',0.25)
hold off

figure
scatter(Zmag, phaseDeg, 40, sampleID, 'filled')
xlabel('|Z| (Ohms)')
ylabel('Phase (deg)')
title('Impedance vs Phase Scatter')
grid on
colorbar

phaseRad = deg2rad(phaseDeg);
Zreal = Zmag .* cos(phaseRad);
Zimag = Zmag .* sin(phaseRad);

figure
scatter(Zreal, -Zimag, 40, sampleID, 'filled')
xlabel('Real(Z) (Ohms)')
ylabel('-Imag(Z) (Ohms)')
title('Nyquist Plot (Single Frequency)')
grid on
axis equal
colorbar