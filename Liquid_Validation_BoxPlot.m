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

%% ---- Compute n per group (for annotations) ----
nSol   = length(solutions);
n_reps = zeros(1, nSol);

for i = 1:nSol
    fkey      = matlab.lang.makeValidName(solutions{i});
    n_reps(i) = length(impedance_values.(fkey));
end

x = 1:nSol;

%% ---- Color palette ----
colors = [0.18 0.45 0.75;   % blue
          0.85 0.33 0.10;   % orange
          0.13 0.63 0.40;   % green
          0.60 0.20 0.75];  % purple
colors = colors(1:nSol, :);

%% ---- Assemble data vectors for boxplot (requires group labels) ----
all_imp    = [];
all_pha    = [];
all_groups = {};

for i = 1:nSol
    fkey       = matlab.lang.makeValidName(solutions{i});
    vals_imp   = impedance_values.(fkey)(:);
    vals_pha   = phase_values.(fkey)(:);
    all_imp    = [all_imp;    vals_imp];
    all_pha    = [all_pha;    vals_pha];
    all_groups = [all_groups; repmat(solutions(i), length(vals_imp), 1)];
end

% Force group order to match solutions{}
grp_cat = categorical(all_groups, solutions);

%% ---- Figure: Impedance + Phase box plots side by side ----
fig = figure('Position', [100 100 1200 520]);

% --- Subplot 1: Impedance (log scale) ---
ax1 = subplot(1, 2, 1);
bp1 = boxplot(all_imp, grp_cat, ...
    'Colors', colors, ...
    'Symbol', '+', ...        % outlier marker
    'Widths', 0.5, ...
    'MedianStyle', 'line');

% Thicken box lines
set(bp1, 'LineWidth', 1.8);

% Fill each box with its color (semi-transparent)
h = findobj(ax1, 'Tag', 'Box');
for i = 1:length(h)
    ci = length(h) - i + 1;   % boxplot draws in reverse order
    patch(get(h(i), 'XData'), get(h(i), 'YData'), ...
        colors(ci,:), 'FaceAlpha', 0.35, 'EdgeColor', 'none');
end

set(ax1, 'YScale', 'log', 'FontSize', 11, 'XTickLabelRotation', 15);
ylabel('Impedance (\Omega)', 'FontSize', 12);
title('Impedance by Solution', 'FontSize', 13, 'FontWeight', 'bold');
grid on; box off;

% Annotate n below each group label
ylims1 = ylim(ax1);
for i = 1:nSol
    text(i, ylims1(1) * 1.3, sprintf('n=%d', n_reps(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', [0.45 0.45 0.45]);
end

% --- Subplot 2: Phase ---
ax2 = subplot(1, 2, 2);
bp2 = boxplot(all_pha, grp_cat, ...
    'Colors', colors, ...
    'Symbol', '+', ...
    'Widths', 0.5, ...
    'MedianStyle', 'line');

set(bp2, 'LineWidth', 1.8);

h2 = findobj(ax2, 'Tag', 'Box');
for i = 1:length(h2)
    ci = length(h2) - i + 1;
    patch(get(h2(i), 'XData'), get(h2(i), 'YData'), ...
        colors(ci,:), 'FaceAlpha', 0.35, 'EdgeColor', 'none');
end

set(ax2, 'FontSize', 11, 'XTickLabelRotation', 15);
ylabel('Phase (°)', 'FontSize', 12);
title('Phase by Solution', 'FontSize', 13, 'FontWeight', 'bold');
grid on; box off;

% Annotate n
ylims2 = ylim(ax2);
pha_pad = (ylims2(2) - ylims2(1)) * 0.05;
for i = 1:nSol
    text(i, ylims2(1) + pha_pad, sprintf('n=%d', n_reps(i)), ...
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
        solutions{i}, mean(impedance_values.(matlab.lang.makeValidName(solutions{i}))), std(impedance_values.(matlab.lang.makeValidName(solutions{i}))), mean(phase_values.(matlab.lang.makeValidName(solutions{i}))), std(phase_values.(matlab.lang.makeValidName(solutions{i}))), n_reps(i));
end
