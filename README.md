# Data Processing for BioZ

MATLAB plotting scripts for bio-impedance chip data in the TPT-Finder project at the UW BioRobotics Lab (PI: Blake Hannaford). This checkout contains seven `.m` scripts and no CSV measurement files.

Unlike the related `Data-for-BioZ` repository, this repository contains analysis and visualization code rather than the raw measurement CSVs.

## Scripts

- `plot_4_12_25.m` reads a specific external, headerless CSV with three data columns (magnitude, phase, and sample label). It groups measurements by label and creates per-sample traces, boxplots, mean-plus-standard-deviation plots, magnitude-versus-phase scatter plots, and a single-frequency Nyquist plot.
- `Liquid_Validation_Plot.m` prompts for a folder of CSV files, reads non-empty headerless files, uses columns 1--3 as impedance, phase, and solution label, and retains labels matching Gatorade, distilled water, drinking water or tap water, and saline or salt. It plots grouped mean and standard-deviation values, writes `Liquid_Validation_Plot.png` to the selected folder, and prints a summary.
- `Liquid_Validation_BoxPlot.m` performs the same folder and label filtering, then makes grouped impedance and phase boxplots. Its save path is also `Liquid_Validation_Plot.png` in the selected folder.
- `ScatterPlot_6_11_25.m`, `PolarPlot_6_11_25.m`, `Nyquist_plot_6_11_25.m`, and `mean_6_11_25.m` read an external chicken-summary CSV with the table variables `mean_impedance`, `mean_phase`, and `chicken_num`. They create, respectively, an impedance-versus-phase scatter plot, a polar plot, a Nyquist plot, and mean impedance by chicken sample.

## How to run

Run the desired script in MATLAB. Before running `plot_4_12_25.m` or the four chicken-summary scripts, update the hard-coded CSV path to an available input file with the expected columns. The liquid-validation scripts prompt for the CSV folder with `uigetdir`.

## Hardware and tools

MATLAB is required. Several script titles identify the source as an `ESP32 Impedance Monitor`; this repository does not include ESP32 firmware or hardware setup files.

## Credits

TPT-Finder, UW BioRobotics Lab — PI: Blake Hannaford. Sparsh Dadhich's role on the project: bioimpedance sensing chip development.

---
