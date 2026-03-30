% Add EEGLAB to path if not already there
addpath('/Users/aatikashaikh/matlab/eeglab2026.0.0');
eeglab;

% Load the EDF file
% EEG = pop_biosig('S001R01.edf');

% Extract a single channel (e.g., Channel 1) for the denoising demo
% raw_signal = EEG.data(1, :);
% fs = EEG.srate; % Sampling frequency
% t = (0:length(raw_signal)-1)/fs;

% save('raw_data.mat', 'raw_signal', 'fs', 't');