%% ---- Select folder containing CSV files ----
folder = uigetdir;   % choose the 2026-02-12 folder with your CSVs
files = dir(fullfile(folder,'*.csv'));

%% ---- Storage containers ----
solutions        = {};
impedance_values = struct;
phase_values     = struct;

%% ---- Read all CSV files ----
for i = 1:length(files)
    filename = fullfile(folder, files(i).name);

    % Skip empty files
    info = dir(filename);
    if info.bytes == 0
        continue
    end

    T = readtable(filename, 'ReadVariableNames', false);

    Z      = T{:,1};              % impedance magnitude (Ω)
    Ph     = T{:,2};              % phase (°)
    labels = string(T{:,3});      % solution label column

    for j = 1:length(Z)
        label = lower(labels(j));

        if contains(label, "gatorade")
            key = "Gatorade";
        elseif contains(label, "distilled")
            key = "Distilled Water";
        elseif contains(label, "drink") || contains(label, "tap")
            key = "Drinking Water";
        elseif contains(label, "saline") || contains(label, "salt")
            key = "Saline";
        else
            continue
        end

        % Use valid struct fieldname (replace spaces)
        fkey = matlab.lang.makeValidName(char(key));

        if ~isfield(impedance_values, fkey)
            impedance_values.(fkey) = [];
            phase_values.(fkey)     = [];
            solutions{end+1}        = char(key);
        end

        impedance_values.(fkey)(end+1) = Z(j);
        phase_values.(fkey)(end+1)     = Ph(j);
    end
end

%% ---- Compute mean and std ----
nSol     = length(solutions);
imp_mean = zeros(1, nSol);
imp_std  = zeros(1, nSol);
pha_mean = zeros(1, nSol);
pha_std  = zeros(1, nSol);
n_reps   = zeros(1, nSol);

for i = 1:nSol
    fkey         = matlab.lang.makeValidName(solutions{i});
    imp_vals     = impedance_values.(fkey);
    pha_vals     = phase_values.(fkey);
    imp_mean(i)  = mean(imp_vals);
    imp_std(i)   = std(imp_vals);
    pha_mean(i)  = mean(pha_vals);
    pha_std(i)   = std(pha_vals);
    n_reps(i)    = length(imp_vals);
end

x = 1:nSol;

%% ---- Color palette ----
colors = [0.18 0.45 0.75;   % blue
          0.85 0.33 0.10;   % orange
          0.13 0.63 0.40;   % green
          0.60 0.20 0.75];  % purple
colors = colors(1:nSol, :);

%% ---- Figure: Impedance (log scale) + Phase side by side ----
fig = figure('Position', [100 100 1200 500]);

% --- Subplot 1: Impedance ---
ax1 = subplot(1, 2, 1);
hold on;
for i = 1:nSol
    errorbar(x(i), imp_mean(i), imp_std(i), ...
        'o', 'LineWidth', 2, 'MarkerSize', 9, 'CapSize', 8, ...
        'Color', colors(i,:), 'MarkerFaceColor', colors(i,:));
end
plot(x, imp_mean, '-', 'LineWidth', 1.5, 'Color', [0.4 0.4 0.4]);
hold off;

set(ax1, 'YScale', 'log', ...
    'XTick', x, 'XTickLabel', solutions, ...
    'XTickLabelRotation', 15, 'FontSize', 11);
ylabel('Impedance (\Omega)', 'FontSize', 12);
title('Mean Impedance ± SD', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0.5, nSol + 0.5]); grid on; box off;

% Auto y-limits with padding (log scale): extend top by 1 decade above max+std
imp_top = max(imp_mean + imp_std);
imp_bot = min(imp_mean - imp_std);
imp_bot = max(imp_bot * 0.5, 1);   % never go below 1
ylim(ax1, [imp_bot * 0.3, imp_top * 8]);

% Annotate n above each error bar top
for i = 1:nSol
    text(x(i), (imp_mean(i) + imp_std(i)) * 2.2, sprintf('n=%d', n_reps(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', [0.45 0.45 0.45]);
end

% --- Subplot 2: Phase ---
ax2 = subplot(1, 2, 2);
hold on;
for i = 1:nSol
    errorbar(x(i), pha_mean(i), pha_std(i), ...
        's', 'LineWidth', 2, 'MarkerSize', 9, 'CapSize', 8, ...
        'Color', colors(i,:), 'MarkerFaceColor', colors(i,:));
end
plot(x, pha_mean, '-', 'LineWidth', 1.5, 'Color', [0.4 0.4 0.4]);
hold off;

set(ax2, 'XTick', x, 'XTickLabel', solutions, ...
    'XTickLabelRotation', 15, 'FontSize', 11);
ylabel('Phase (°)', 'FontSize', 12);
title('Mean Phase ± SD', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0.5, nSol + 0.5]); grid on; box off;

% Auto y-limits with 25% padding above and below all error bar extents
pha_top = max(pha_mean + pha_std);
pha_bot = min(pha_mean - pha_std);
pha_pad = (pha_top - pha_bot) * 0.30;
ylim(ax2, [pha_bot - pha_pad, pha_top + pha_pad * 2]);  % extra top room for n= labels

% Annotate n above each error bar top
for i = 1:nSol
    text(x(i), pha_mean(i) + pha_std(i) + pha_pad * 0.5, sprintf('n=%d', n_reps(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', [0.45 0.45 0.45]);
end

sgtitle('ESP32 Impedance Monitor — Liquid Validation', ...
    'FontSize', 14, 'FontWeight', 'bold');

%% ---- Save figure ----
savepath = fullfile(folder, 'Liquid_Validation_Plot.png');
exportgraphics(fig, savepath, 'Resolution', 150);
fprintf('Figure saved to: %s\n', savepath);

%% ---- Print summary table ----
fprintf('\n%-18s %12s %10s %10s %8s %6s\n', ...
    'Solution', 'Mean Z (Ω)', 'Std Z', 'Mean Ph°', 'Std Ph', 'n');
fprintf('%s\n', repmat('-', 1, 68));
for i = 1:nSol
    fprintf('%-18s %12.1f %10.1f %10.2f %8.2f %6d\n', ...
        solutions{i}, imp_mean(i), imp_std(i), pha_mean(i), pha_std(i), n_reps(i));
end
