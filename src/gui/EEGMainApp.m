classdef EEGMainApp < matlab.apps.AppBase

    properties (Access = public)
        UIFigure        matlab.ui.Figure

        % Tab group
        TabGroup        matlab.ui.container.TabGroup
        LoadTab         matlab.ui.container.Tab
        FilterTab       matlab.ui.container.Tab
        RereferenceTab  matlab.ui.container.Tab
        ICATab          matlab.ui.container.Tab
        VisualizeTab    matlab.ui.container.Tab
        RunTab          matlab.ui.container.Tab
        SummaryTab          matlab.ui.container.Tab
        WaveletTab          matlab.ui.container.Tab
        AdaptiveTab         matlab.ui.container.Tab
        ComparisonTab       matlab.ui.container.Tab
        MergeTab            matlab.ui.container.Tab

        % ── Adaptive Filtering tab components ────────────────────────────
        AdaptAlgoDropdown   matlab.ui.control.DropDown
        AdaptMuField        matlab.ui.control.NumericEditField
        AdaptOrderField     matlab.ui.control.NumericEditField
        AdaptApplyBtn       matlab.ui.control.Button
        AdaptStatusLabel    matlab.ui.control.Label
        AdaptAxesBefore     matlab.ui.control.UIAxes
        AdaptAxesAfter      matlab.ui.control.UIAxes

        % ── Comparison tab components ─────────────────────────────────────
        CompRunBtn          matlab.ui.control.Button
        CompStatusLabel     matlab.ui.control.Label
        CompAxes            matlab.ui.control.UIAxes
        CompMetricsArea     matlab.ui.control.TextArea
        EEG_original        struct

        % ── Signal Merging tab components ─────────────────────────────────
        MergeChanField      matlab.ui.control.EditField
        MergeAxes           matlab.ui.control.UIAxes
        MergePlotBtn        matlab.ui.control.Button
        MergeStatusLabel    matlab.ui.control.Label

        % ── Wavelet Denoising tab components ─────────────────────────────
        WaveletFamilyDropdown   matlab.ui.control.DropDown
        WaveletLevelField       matlab.ui.control.NumericEditField
        WaveletThreshDropdown   matlab.ui.control.DropDown
        WaveletApplyBtn         matlab.ui.control.Button
        WaveletStatusLabel      matlab.ui.control.Label
        WaveletAxesBefore       matlab.ui.control.UIAxes
        WaveletAxesAfter        matlab.ui.control.UIAxes

        % ── Summary tab components ────────────────────────────────────────
        SummaryStepDropdown     matlab.ui.control.DropDown
        SummaryExplanationArea  matlab.ui.control.TextArea
        SummaryLogArea          matlab.ui.control.TextArea
        ProcessingLog           cell

        % ── Load Data tab components ──────────────────────────────────────
        InputFilePanel  matlab.ui.container.Panel
        InputFileField  matlab.ui.control.EditField
        BrowseFileBtn   matlab.ui.control.Button
        FileTypeLabel   matlab.ui.control.Label
        FileTypeValue   matlab.ui.control.Label

        OutputPanel     matlab.ui.container.Panel
        OutputFolderField matlab.ui.control.EditField
        BrowseFolderBtn matlab.ui.control.Button

        ParamsPanel     matlab.ui.container.Panel
        SamplingRateField matlab.ui.control.NumericEditField
        SamplingRateLabel matlab.ui.control.Label
        NumChannelsLabel  matlab.ui.control.Label
        NumChannelsValue  matlab.ui.control.Label

        StatusPanel     matlab.ui.container.Panel
        StatusLabel     matlab.ui.control.Label
        LoadBtn         matlab.ui.control.Button

        % ── Filter tab components ─────────────────────────────────────────
        FiltPanel           matlab.ui.container.Panel
        FiltLowCutField     matlab.ui.control.NumericEditField
        FiltHighCutField    matlab.ui.control.NumericEditField
        FiltNotchCheck      matlab.ui.control.CheckBox
        FiltNotchFreqField  matlab.ui.control.NumericEditField
        FiltApplyBtn        matlab.ui.control.Button
        FiltStatusLabel     matlab.ui.control.Label

        % ── Re-reference tab components ───────────────────────────────────
        RerefPanel          matlab.ui.container.Panel
        RerefTypeDropdown   matlab.ui.control.DropDown
        RerefChanField      matlab.ui.control.EditField
        RerefApplyBtn       matlab.ui.control.Button
        RerefStatusLabel    matlab.ui.control.Label

        % ── ICA tab components ────────────────────────────────────────────
        ICAPanel            matlab.ui.container.Panel
        ICARunBtn           matlab.ui.control.Button
        ICARejectField      matlab.ui.control.EditField
        ICARejectBtn        matlab.ui.control.Button
        ICAStatusLabel      matlab.ui.control.Label

        % ── Visualize tab components ──────────────────────────────────────
        VizPanel            matlab.ui.container.Panel
        VizPlotBtn          matlab.ui.control.Button
        VizSpecBtn          matlab.ui.control.Button
        VizStatusLabel      matlab.ui.control.Label

        % ── Run & Save tab components ─────────────────────────────────────
        RunPanel            matlab.ui.container.Panel
        RunFilterCheck      matlab.ui.control.CheckBox
        RunRerefCheck       matlab.ui.control.CheckBox
        RunICACheck         matlab.ui.control.CheckBox
        RunAllBtn           matlab.ui.control.Button
        SaveBtn             matlab.ui.control.Button
        RunStatusLabel      matlab.ui.control.Label

        % Shared EEG data
        EEG             struct
        DataLoaded      logical
    end

    % ══════════════════════════════════════════════════════════════════════
    %  Startup
    % ══════════════════════════════════════════════════════════════════════
    methods (Access = private)

        function startupFcn(app)
            movegui(app.UIFigure, 'center');
            app.DataLoaded    = false;
            app.EEG           = struct();
            app.EEG_original  = struct();
            app.ProcessingLog = {};
            app.setStatus('No file loaded. Please select an EEG file to begin.', 'idle');
        end

    end

    % ══════════════════════════════════════════════════════════════════════
    %  Callbacks
    % ══════════════════════════════════════════════════════════════════════
    methods (Access = private)

        % ── Load tab ──────────────────────────────────────────────────────

        function BrowseFileBtnPushed(app, ~)
            [file, path] = uigetfile( ...
                {'*.csv','CSV Files (*.csv)'; ...
                 '*.mat','MATLAB Files (*.mat)'; ...
                 '*.edf','EDF Files (*.edf)'; ...
                 '*.*','All Files (*.*)'}, ...
                'Select EEG File');
            if isequal(file, 0); return; end
            fullpath = fullfile(path, file);
            app.InputFileField.Value = fullpath;
            [~, ~, ext] = fileparts(file);
            switch lower(ext)
                case '.csv'; typeStr = 'CSV  (comma-separated values)';
                case '.mat'; typeStr = 'MAT  (MATLAB data file)';
                case '.edf'; typeStr = 'EDF  (European Data Format)';
                otherwise;   typeStr = 'Unknown format';
            end
            app.FileTypeValue.Text = typeStr;
            app.setStatus(['File selected: ' file '  –  Click "Load File" to import.'], 'idle');
        end

        function BrowseFolderBtnPushed(app, ~)
            folder = uigetdir('', 'Select Output Folder');
            if isequal(folder, 0); return; end
            app.OutputFolderField.Value = folder;
        end

        function LoadBtnPushed(app, ~)
            filepath = app.InputFileField.Value;
            if isempty(filepath)
                app.setStatus('Error: No file selected.', 'error'); return;
            end
            if ~isfile(filepath)
                app.setStatus('Error: File not found. Check the path.', 'error'); return;
            end
            app.setStatus('Loading file…', 'busy'); drawnow;
            try
                [~, ~, ext] = fileparts(filepath);
                switch lower(ext)
                    case '.edf'
                        app.EEG = pop_biosig(filepath);
                    case '.mat'
                        S = load(filepath);
                        fields = fieldnames(S);
                        if isfield(S, 'EEG')
                            app.EEG = S.EEG;
                        elseif isfield(S, 'eeg')
                            app.EEG = eeg_emptyset();
                            app.EEG.data   = S.eeg;
                            app.EEG.srate  = app.SamplingRateField.Value;
                            app.EEG.nbchan = size(S.eeg, 1);
                            app.EEG.pnts   = size(S.eeg, 2);
                            app.EEG.trials = 1;
                        else
                            found = false;
                            for i = 1:numel(fields)
                                val = S.(fields{i});
                                if isnumeric(val) && ismatrix(val)
                                    app.EEG = eeg_emptyset();
                                    app.EEG.data   = val;
                                    app.EEG.srate  = app.SamplingRateField.Value;
                                    app.EEG.nbchan = size(val,1);
                                    app.EEG.pnts   = size(val,2);
                                    app.EEG.trials = 1;
                                    found = true; break;
                                end
                            end
                            if ~found; error('No numeric EEG matrix found in .mat file.'); end
                        end
                    case '.csv'
                        raw = readmatrix(filepath);
                        if size(raw,1) > size(raw,2); raw = raw'; end
                        app.EEG = eeg_emptyset();
                        app.EEG.data   = raw;
                        app.EEG.srate  = app.SamplingRateField.Value;
                        app.EEG.nbchan = size(raw,1);
                        app.EEG.pnts   = size(raw,2);
                        app.EEG.trials = 1;
                    otherwise
                        error('Unsupported file format: %s', ext);
                end
                app.EEG = eeg_checkset(app.EEG);
                app.DataLoaded   = true;
                app.EEG_original = app.EEG;
                app.NumChannelsValue.Text = sprintf('%d channels  ·  %d samples  ·  %.1f s', ...
                    app.EEG.nbchan, app.EEG.pnts, app.EEG.pnts/app.EEG.srate);
                app.setStatus(sprintf('✔  Loaded – %d channels, %.1f s @ %d Hz', ...
                    app.EEG.nbchan, app.EEG.pnts/app.EEG.srate, app.EEG.srate), 'ok');
                app.addLog(sprintf('Data Loaded: %d channels, %.1f s @ %d Hz', ...
                    app.EEG.nbchan, app.EEG.pnts/app.EEG.srate, app.EEG.srate));
            catch ME
                app.setStatus(['Error loading file: ' ME.message], 'error');
            end
        end

        % ── Filter tab ────────────────────────────────────────────────────

        function FiltApplyBtnPushed(app, ~)
            if ~app.DataLoaded
                app.FiltStatusLabel.Text = 'Load a file first.';
                app.FiltStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            lo  = app.FiltLowCutField.Value;
            hi  = app.FiltHighCutField.Value;
            app.FiltStatusLabel.Text = 'Applying bandpass filter…';
            app.FiltStatusLabel.FontColor = [0.65 0.45 0.00]; drawnow;
            try
                app.EEG = pop_eegfiltnew(app.EEG, lo, hi);
                if app.FiltNotchCheck.Value
                    nf = app.FiltNotchFreqField.Value;
                    app.EEG = pop_eegfiltnew(app.EEG, nf-2, nf+2, [], 1);
                end
                app.EEG = eeg_checkset(app.EEG);
                app.FiltStatusLabel.Text = sprintf('✔  Bandpass [%.1f–%.1f Hz] applied.', lo, hi);
                app.FiltStatusLabel.FontColor = [0.10 0.55 0.25];
                if app.FiltNotchCheck.Value
                    app.addLog(sprintf('Bandpass Filter: %.1f–%.1f Hz + Notch @ %.0f Hz', lo, hi, app.FiltNotchFreqField.Value));
                else
                    app.addLog(sprintf('Bandpass Filter: %.1f–%.1f Hz', lo, hi));
                end
            catch ME
                app.FiltStatusLabel.Text = ['Error: ' ME.message];
                app.FiltStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        % ── Re-reference tab ──────────────────────────────────────────────

        function RerefApplyBtnPushed(app, ~)
            if ~app.DataLoaded
                app.RerefStatusLabel.Text = 'Load a file first.';
                app.RerefStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            app.RerefStatusLabel.Text = 'Applying re-reference…';
            app.RerefStatusLabel.FontColor = [0.65 0.45 0.00]; drawnow;
            try
                refType = app.RerefTypeDropdown.Value;
                switch refType
                    case 'Average reference'
                        app.EEG = pop_reref(app.EEG, []);
                    case 'Specific channel(s)'
                        chanStr = app.RerefChanField.Value;
                        chanNums = str2num(chanStr); %#ok<ST2NM>
                        if isempty(chanNums); error('Enter valid channel number(s).'); end
                        app.EEG = pop_reref(app.EEG, chanNums);
                    case 'Linked mastoids (TP9/TP10)'
                        idx = find(ismember({app.EEG.chanlocs.labels}, {'TP9','TP10'}));
                        if isempty(idx); error('TP9/TP10 channels not found in dataset.'); end
                        app.EEG = pop_reref(app.EEG, idx);
                end
                app.EEG = eeg_checkset(app.EEG);
                app.RerefStatusLabel.Text = ['✔  Re-referenced to: ' refType];
                app.RerefStatusLabel.FontColor = [0.10 0.55 0.25];
                app.addLog(['Re-reference: ' refType]);
            catch ME
                app.RerefStatusLabel.Text = ['Error: ' ME.message];
                app.RerefStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        function RerefTypeChanged(app, ~)
            if strcmp(app.RerefTypeDropdown.Value, 'Specific channel(s)')
                app.RerefChanField.Enable = 'on';
            else
                app.RerefChanField.Enable = 'off';
            end
        end

        % ── ICA tab ───────────────────────────────────────────────────────

        function ICARunBtnPushed(app, ~)
            if ~app.DataLoaded
                app.ICAStatusLabel.Text = 'Load a file first.';
                app.ICAStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            app.ICAStatusLabel.Text = 'Running ICA – this may take a few minutes…';
            app.ICAStatusLabel.FontColor = [0.65 0.45 0.00]; drawnow;
            try
                app.EEG = pop_runica(app.EEG, 'icatype', 'runica', 'extended', 1);
                app.EEG = eeg_checkset(app.EEG);
                app.ICAStatusLabel.Text = '✔  ICA complete. Enter component numbers to reject below.';
                app.ICAStatusLabel.FontColor = [0.10 0.55 0.25];
                app.addLog(sprintf('ICA: decomposition complete (%d components)', size(app.EEG.icawinv,2)));
                pop_topoplot(app.EEG, 0, 1:min(20, size(app.EEG.icawinv,2)), 'ICA Components');
            catch ME
                app.ICAStatusLabel.Text = ['Error: ' ME.message];
                app.ICAStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        function ICARejectBtnPushed(app, ~)
            if ~isfield(app.EEG, 'icawinv') || isempty(app.EEG.icawinv)
                app.ICAStatusLabel.Text = 'Run ICA first.';
                app.ICAStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            compStr = app.ICARejectField.Value;
            compNums = str2num(compStr); %#ok<ST2NM>
            if isempty(compNums)
                app.ICAStatusLabel.Text = 'Enter valid component numbers (e.g. 1 3 5).';
                app.ICAStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            try
                app.EEG = pop_subcomp(app.EEG, compNums, 0);
                app.EEG = eeg_checkset(app.EEG);
                app.ICAStatusLabel.Text = sprintf('✔  Components [%s] removed.', compStr);
                app.ICAStatusLabel.FontColor = [0.10 0.55 0.25];
                app.addLog(sprintf('ICA Rejection: removed components [%s]', compStr));
            catch ME
                app.ICAStatusLabel.Text = ['Error: ' ME.message];
                app.ICAStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        % ── Visualize tab ─────────────────────────────────────────────────

        function VizPlotBtnPushed(app, ~)
            if ~app.DataLoaded
                app.VizStatusLabel.Text = 'Load a file first.';
                app.VizStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            try
                pop_eegplot(app.EEG, 1, 1, 1);
                app.VizStatusLabel.Text = '✔  EEG signal plot opened.';
                app.VizStatusLabel.FontColor = [0.10 0.55 0.25];
            catch ME
                app.VizStatusLabel.Text = ['Error: ' ME.message];
                app.VizStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        function VizSpecBtnPushed(app, ~)
            if ~app.DataLoaded
                app.VizStatusLabel.Text = 'Load a file first.';
                app.VizStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            try
                pop_spectopo(app.EEG, 1, [], 'EEG');
                app.VizStatusLabel.Text = '✔  Power spectrum plot opened.';
                app.VizStatusLabel.FontColor = [0.10 0.55 0.25];
            catch ME
                app.VizStatusLabel.Text = ['Error: ' ME.message];
                app.VizStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        % ── Run & Save tab ────────────────────────────────────────────────

        function RunAllBtnPushed(app, ~)
            if ~app.DataLoaded
                app.RunStatusLabel.Text = 'Load a file first.';
                app.RunStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            app.RunStatusLabel.Text = 'Running pipeline…';
            app.RunStatusLabel.FontColor = [0.65 0.45 0.00]; drawnow;
            try
                if app.RunFilterCheck.Value
                    lo = app.FiltLowCutField.Value;
                    hi = app.FiltHighCutField.Value;
                    app.EEG = pop_eegfiltnew(app.EEG, lo, hi);
                    if app.FiltNotchCheck.Value
                        nf = app.FiltNotchFreqField.Value;
                        app.EEG = pop_eegfiltnew(app.EEG, nf-2, nf+2, [], 1);
                    end
                end
                if app.RunRerefCheck.Value
                    app.EEG = pop_reref(app.EEG, []);
                end
                if app.RunICACheck.Value
                    app.EEG = pop_runica(app.EEG, 'icatype', 'runica', 'extended', 1);
                end
                app.EEG = eeg_checkset(app.EEG);
                app.RunStatusLabel.Text = '✔  Pipeline complete. Click Save to export.';
                app.RunStatusLabel.FontColor = [0.10 0.55 0.25];
            catch ME
                app.RunStatusLabel.Text = ['Error: ' ME.message];
                app.RunStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        function SaveBtnPushed(app, ~)
            if ~app.DataLoaded
                app.RunStatusLabel.Text = 'Nothing to save.';
                app.RunStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            outDir = app.OutputFolderField.Value;
            if isempty(outDir) || ~isfolder(outDir)
                app.RunStatusLabel.Text = 'Set a valid output folder in the Load Data tab.';
                app.RunStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            try
                outFile = fullfile(outDir, ['processed_' datestr(now,'yyyymmdd_HHMMSS') '.mat']);
                EEG = app.EEG; %#ok<PROPLC>
                save(outFile, 'EEG');
                app.RunStatusLabel.Text = ['✔  Saved to: ' outFile];
                app.RunStatusLabel.FontColor = [0.10 0.55 0.25];
                app.addLog(['File Saved: ' outFile]);
            catch ME
                app.RunStatusLabel.Text = ['Error saving: ' ME.message];
                app.RunStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        % ── Adaptive Filtering tab ────────────────────────────────────────

        function AdaptApplyBtnPushed(app, ~)
            if ~app.DataLoaded
                app.AdaptStatusLabel.Text = 'Load a file first.';
                app.AdaptStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            app.AdaptStatusLabel.Text = 'Applying adaptive filter…';
            app.AdaptStatusLabel.FontColor = [0.65 0.45 0.00]; drawnow;
            try
                algo  = app.AdaptAlgoDropdown.Value;
                mu    = app.AdaptMuField.Value;
                order = app.AdaptOrderField.Value;

                ch = 1;
                t  = (0:app.EEG.pnts-1) / app.EEG.srate;
                plot(app.AdaptAxesBefore, t, app.EEG.data(ch,:), 'b', 'LineWidth', 0.5);
                title(app.AdaptAxesBefore,'Before Adaptive Filter (Ch 1)');
                xlabel(app.AdaptAxesBefore,'Time (s)'); ylabel(app.AdaptAxesBefore,'Amplitude (µV)');

                denoised = zeros(size(app.EEG.data));
                for c = 1:app.EEG.nbchan
                    x = double(app.EEG.data(c,:));
                    N = length(x);
                    w = zeros(order, 1);
                    y = zeros(1, N);
                    switch algo
                        case 'LMS'
                            for n = order:N
                                xv    = x(n:-1:n-order+1)';
                                y(n)  = w' * xv;
                                e     = x(n) - y(n);
                                w     = w + 2*mu*e*xv;
                            end
                        case 'RLS'
                            lambda = 0.99;
                            P_mat  = (1/mu) * eye(order);
                            for n = order:N
                                xv    = x(n:-1:n-order+1)';
                                k     = (P_mat*xv) / (lambda + xv'*P_mat*xv);
                                y(n)  = w' * xv;
                                e     = x(n) - y(n);
                                w     = w + k*e;
                                P_mat = (P_mat - k*xv'*P_mat) / lambda;
                            end
                    end
                    denoised(c,:) = x - y;
                end

                plot(app.AdaptAxesAfter, t, denoised(ch,:), 'r', 'LineWidth', 0.5);
                title(app.AdaptAxesAfter,'After Adaptive Filter (Ch 1)');
                xlabel(app.AdaptAxesAfter,'Time (s)'); ylabel(app.AdaptAxesAfter,'Amplitude (µV)');

                app.EEG.data = denoised;
                app.EEG = eeg_checkset(app.EEG);
                app.AdaptStatusLabel.Text = sprintf('✔  %s filter applied (mu=%.4f, order=%d)', algo, mu, order);
                app.AdaptStatusLabel.FontColor = [0.10 0.55 0.25];
                app.addLog(sprintf('Adaptive Filter: %s, mu=%.4f, order=%d', algo, mu, order));
            catch ME
                app.AdaptStatusLabel.Text = ['Error: ' ME.message];
                app.AdaptStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        % ── Comparison tab ────────────────────────────────────────────────

        function CompRunBtnPushed(app, ~)
            if ~app.DataLoaded
                app.CompStatusLabel.Text = 'Load and process a file first.';
                app.CompStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            if ~isfield(app.EEG_original,'data') || isempty(fieldnames(app.EEG_original))
                app.CompStatusLabel.Text = 'No original data to compare against.';
                app.CompStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            app.CompStatusLabel.Text = 'Computing metrics…';
            app.CompStatusLabel.FontColor = [0.65 0.45 0.00]; drawnow;
            try
                orig = double(app.EEG_original.data);
                proc = double(app.EEG.data);

                % Use min size in case channels changed
                nch = min(size(orig,1), size(proc,1));
                npt = min(size(orig,2), size(proc,2));
                orig = orig(1:nch, 1:npt);
                proc = proc(1:nch, 1:npt);

                % Metrics per channel then average
                snr_vals  = zeros(1,nch);
                mse_vals  = zeros(1,nch);
                corr_vals = zeros(1,nch);
                for c = 1:nch
                    o = orig(c,:); p = proc(c,:);
                    noise        = o - p;
                    sig_pow      = mean(p.^2);
                    noise_pow    = mean(noise.^2);
                    snr_vals(c)  = 10*log10(sig_pow / max(noise_pow, eps));
                    mse_vals(c)  = mean(noise.^2);
                    r            = corrcoef(o, p);
                    corr_vals(c) = r(1,2);
                end

                snr_mean  = mean(snr_vals);
                mse_mean  = mean(mse_vals);
                corr_mean = mean(corr_vals);

                % Plot SNR per channel (first 32 max)
                plotN = min(nch, 32);
                bar(app.CompAxes, 1:plotN, snr_vals(1:plotN));
                title(app.CompAxes, 'SNR per Channel (dB)');
                xlabel(app.CompAxes, 'Channel'); ylabel(app.CompAxes, 'SNR (dB)');

                % Metrics text
                app.CompMetricsArea.Value = {
                    '── Performance Metrics (averaged across all channels) ──'
                    ''
                    sprintf('SNR   (Signal-to-Noise Ratio)  :  %.4f dB', snr_mean)
                    '  → Higher = cleaner signal relative to noise'
                    ''
                    sprintf('MSE   (Mean Squared Error)      :  %.6f', mse_mean)
                    '  → Lower = less distortion from original'
                    ''
                    sprintf('Corr  (Correlation Coefficient) :  %.4f', corr_mean)
                    '  → Closer to 1.0 = processed signal matches original shape'
                    ''
                    sprintf('Channels analysed : %d', nch)
                    sprintf('Samples per channel: %d', npt)
                };

                app.CompStatusLabel.Text = sprintf('✔  SNR: %.2f dB  |  MSE: %.4f  |  Corr: %.4f', snr_mean, mse_mean, corr_mean);
                app.CompStatusLabel.FontColor = [0.10 0.55 0.25];
                app.addLog(sprintf('Comparison: SNR=%.2f dB, MSE=%.4f, Corr=%.4f', snr_mean, mse_mean, corr_mean));
            catch ME
                app.CompStatusLabel.Text = ['Error: ' ME.message];
                app.CompStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        % ── Signal Merging tab ────────────────────────────────────────────

        function MergePlotBtnPushed(app, ~)
            if ~app.DataLoaded
                app.MergeStatusLabel.Text = 'Load a file first.';
                app.MergeStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            chanStr = app.MergeChanField.Value;
            if isempty(strtrim(chanStr))
                chans = 1:min(6, app.EEG.nbchan);
            else
                chans = str2num(chanStr); %#ok<ST2NM>
                if isempty(chans)
                    app.MergeStatusLabel.Text = 'Enter valid channel numbers.';
                    app.MergeStatusLabel.FontColor = [0.75 0.10 0.10]; return;
                end
                chans = chans(chans >= 1 & chans <= app.EEG.nbchan);
            end
            try
                t = (0:app.EEG.pnts-1) / app.EEG.srate;
                cla(app.MergeAxes);
                hold(app.MergeAxes, 'on');
                colors = lines(length(chans));
                legendEntries = cell(1, length(chans));
                for i = 1:length(chans)
                    c = chans(i);
                    % Offset each channel vertically for clarity
                    offset = (i-1) * 50;
                    plot(app.MergeAxes, t, app.EEG.data(c,:) + offset, ...
                        'Color', colors(i,:), 'LineWidth', 0.8);
                    if ~isempty(app.EEG.chanlocs) && c <= length(app.EEG.chanlocs) && ~isempty(app.EEG.chanlocs(c).labels)
                        legendEntries{i} = app.EEG.chanlocs(c).labels;
                    else
                        legendEntries{i} = sprintf('Ch %d', c);
                    end
                end
                hold(app.MergeAxes, 'off');
                legend(app.MergeAxes, legendEntries, 'Location', 'eastoutside', 'FontSize', 9);
                title(app.MergeAxes, 'Merged Channel View');
                xlabel(app.MergeAxes, 'Time (s)');
                ylabel(app.MergeAxes, 'Amplitude + offset (µV)');
                app.MergeStatusLabel.Text = sprintf('✔  Showing %d channels overlaid.', length(chans));
                app.MergeStatusLabel.FontColor = [0.10 0.55 0.25];
                app.addLog(sprintf('Signal Merge: channels [%s]', num2str(chans)));
            catch ME
                app.MergeStatusLabel.Text = ['Error: ' ME.message];
                app.MergeStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        % ── Wavelet Denoising tab ─────────────────────────────────────────

        function WaveletApplyBtnPushed(app, ~)
            if ~app.DataLoaded
                app.WaveletStatusLabel.Text = 'Load a file first.';
                app.WaveletStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            app.WaveletStatusLabel.Text = 'Applying wavelet denoising…';
            app.WaveletStatusLabel.FontColor = [0.65 0.45 0.00]; drawnow;
            try
                wname  = app.WaveletFamilyDropdown.Value;
                level  = app.WaveletLevelField.Value;
                ttype  = app.WaveletThreshDropdown.Value;

                % Plot channel 1 before
                ch = min(1, app.EEG.nbchan);
                t  = (0:app.EEG.pnts-1) / app.EEG.srate;
                plot(app.WaveletAxesBefore, t, app.EEG.data(ch,:), 'b', 'LineWidth', 0.5);
                title(app.WaveletAxesBefore, 'Before Denoising (Ch 1)');
                xlabel(app.WaveletAxesBefore, 'Time (s)');
                ylabel(app.WaveletAxesBefore, 'Amplitude (µV)');

                % Apply wavelet denoising channel by channel
                denoised = zeros(size(app.EEG.data));
                for c = 1:app.EEG.nbchan
                    sig = double(app.EEG.data(c,:));
                    [C, L] = wavedec(sig, level, wname);
                    % Threshold selection
                    sigma = median(abs(C)) / 0.6745;
                    thr   = sigma * sqrt(2 * log(length(sig)));
                    switch ttype
                        case 'Soft'
                            C_thresh = wthresh(C, 's', thr);
                        case 'Hard'
                            C_thresh = wthresh(C, 'h', thr);
                        case 'Minimax'
                            thr_mm   = sigma * 0.3936 + 0.1829 * log(length(sig)) / log(2);
                            C_thresh = wthresh(C, 's', thr_mm);
                    end
                    denoised(c,:) = waverec(C_thresh, L, wname);
                end

                % Plot channel 1 after
                plot(app.WaveletAxesAfter, t, denoised(ch,:), 'r', 'LineWidth', 0.5);
                title(app.WaveletAxesAfter, 'After Denoising (Ch 1)');
                xlabel(app.WaveletAxesAfter, 'Time (s)');
                ylabel(app.WaveletAxesAfter, 'Amplitude (µV)');

                % Compute SNR for channel 1
                signal_power = mean(denoised(ch,:).^2);
                noise_power  = mean((app.EEG.data(ch,:) - denoised(ch,:)).^2);
                if noise_power > 0
                    snr_val = 10*log10(signal_power/noise_power);
                    snr_str = sprintf('  |  SNR improvement: %.2f dB', snr_val);
                else
                    snr_str = '';
                end

                app.EEG.data = denoised;
                app.EEG = eeg_checkset(app.EEG);
                app.WaveletStatusLabel.Text = sprintf('✔  Wavelet denoising done (%s, level %d, %s threshold)%s', wname, level, ttype, snr_str);
                app.WaveletStatusLabel.FontColor = [0.10 0.55 0.25];
                app.addLog(sprintf('Wavelet Denoising: %s, level %d, %s threshold', wname, level, ttype));
            catch ME
                app.WaveletStatusLabel.Text = ['Error: ' ME.message];
                app.WaveletStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        % ── Shared helper ─────────────────────────────────────────────────

        function addLog(app, entry)
            timestamp = datestr(now, 'HH:MM:SS');
            app.ProcessingLog{end+1} = sprintf('[%s] %s', timestamp, entry);
            app.SummaryLogArea.Value = app.ProcessingLog;
        end

        function SummaryStepChanged(app, ~)
            step = app.SummaryStepDropdown.Value;
            explanations = struct();
            explanations.load = ...
                ['LOADING EEG DATA' newline newline ...
                 'EEG (Electroencephalography) data is recorded as electrical signals from electrodes placed on the scalp. ' ...
                 'Each channel represents one electrode capturing voltage fluctuations caused by neural activity.' newline newline ...
                 'Supported formats:' newline ...
                 '  CSV  – raw data matrix, rows = channels, columns = timepoints' newline ...
                 '  MAT  – MATLAB format, often already structured as an EEGLAB EEG struct' newline ...
                 '  EDF  – European Data Format, standard clinical EEG format with metadata' newline newline ...
                 'The sampling rate tells the system how many data points were recorded per second (e.g. 256 Hz = 256 samples/sec/channel).'];
            explanations.filter = ...
                ['BANDPASS FILTERING' newline newline ...
                 'Raw EEG signals contain noise from many sources. Filtering keeps only the frequency range we care about.' newline newline ...
                 'Low cutoff (e.g. 1 Hz): removes slow drifts caused by sweat, electrode movement, or DC offset.' newline ...
                 'High cutoff (e.g. 40 Hz): removes high-frequency noise like muscle activity (EMG) or electrical interference.' newline newline ...
                 'Notch filter (50 Hz in Pakistan/Europe, 60 Hz in USA): removes power line interference that couples into EEG electrodes.' newline newline ...
                 'Typical clinical EEG band: 0.5–70 Hz. For motor imagery/BCI: 8–30 Hz (alpha + beta bands).'];
            explanations.reref = ...
                ['RE-REFERENCING' newline newline ...
                 'EEG signals are always measured relative to a reference electrode. The choice of reference affects what your data looks like.' newline newline ...
                 'Average reference: subtracts the mean of all channels from each channel. Best for high-density EEG (64+ channels). Assumes the average of all electrodes ≈ 0.' newline newline ...
                 'Specific channel: uses one electrode (e.g. Cz, mastoid) as the reference. Common in clinical settings.' newline newline ...
                 'Linked mastoids (TP9/TP10): uses the average of both mastoid electrodes behind the ears. Electrically neutral region, widely used in research.'];
            explanations.ica = ...
                ['INDEPENDENT COMPONENT ANALYSIS (ICA)' newline newline ...
                 'ICA is a blind source separation technique. It assumes the recorded EEG is a mixture of independent sources — brain signals, eye blinks, heartbeat, muscle noise — and mathematically separates them.' newline newline ...
                 'After running ICA, each "component" represents one estimated source. You inspect the topoplots (scalp maps) and time courses to identify which components are artifacts.' newline newline ...
                 'Common artifacts to remove:' newline ...
                 '  Eye blinks – large amplitude, frontal electrodes, slow' newline ...
                 '  Eye movements – horizontal dipole pattern at front' newline ...
                 '  Heartbeat (ECG) – rhythmic, ~1 Hz, often at neck electrodes' newline ...
                 '  Muscle (EMG) – high frequency, peripheral electrodes' newline newline ...
                 'Once identified, those components are subtracted from the data, leaving cleaner brain signals.'];
            explanations.save = ...
                ['SAVING RESULTS' newline newline ...
                 'The processed EEG dataset is saved as a .mat file in EEGLAB format. This preserves all processing history, channel locations, and the cleaned data matrix.' newline newline ...
                 'The file is timestamped automatically so you never overwrite a previous result.' newline newline ...
                 'You can reload this .mat file directly into EEGLAB or back into this tool for further analysis.'];

            explanations.wavelet = ...
                ['WAVELET-BASED DENOISING' newline newline ...
                 'Wavelet denoising decomposes the EEG signal into multiple frequency bands using the Discrete Wavelet Transform (DWT), then removes noise by thresholding the wavelet coefficients.' newline newline ...
                 'Wavelet families:' newline ...
                 '  db4/db6/db8  – Daubechies wavelets, good general-purpose choice for EEG' newline ...
                 '  sym5/sym8    – Symlets, similar to Daubechies but more symmetric' newline ...
                 '  coif3/coif5  – Coiflets, better for signals with smooth features' newline newline ...
                 'Decomposition level: how many times the signal is split into sub-bands. Higher = more aggressive denoising but risk of distorting real signal.' newline newline ...
                 'Threshold types:' newline ...
                 '  Soft  – shrinks all coefficients toward zero, smoother result' newline ...
                 '  Hard  – zeros out coefficients below threshold, keeps others unchanged' newline ...
                 '  Minimax – balances between soft and hard, minimizes worst-case error'];

            switch step
                case 'Load Data';          app.SummaryExplanationArea.Value = explanations.load;
                case 'Filtering';          app.SummaryExplanationArea.Value = explanations.filter;
                case 'Re-reference';       app.SummaryExplanationArea.Value = explanations.reref;
                case 'ICA';                app.SummaryExplanationArea.Value = explanations.ica;
                case 'Wavelet Denoising';  app.SummaryExplanationArea.Value = explanations.wavelet;
                case 'Run & Save';         app.SummaryExplanationArea.Value = explanations.save;
            end
        end

        function setStatus(app, msg, state)
            app.StatusLabel.Text = msg;
            switch state
                case 'ok';    app.StatusLabel.FontColor = [0.10 0.55 0.25];
                case 'error'; app.StatusLabel.FontColor = [0.75 0.10 0.10];
                case 'busy';  app.StatusLabel.FontColor = [0.65 0.45 0.00];
                otherwise;    app.StatusLabel.FontColor = [0.40 0.40 0.40];
            end
        end

    end

    % ══════════════════════════════════════════════════════════════════════
    %  UI Construction
    % ══════════════════════════════════════════════════════════════════════
    methods (Access = private)

        function createComponents(app)

            BG  = [0.94 0.94 0.94];
            PNL = [1.00 1.00 1.00];
            ACC = [0.20 0.20 0.20];
            TXT = [0.10 0.10 0.10];
            SUB = [0.45 0.45 0.45];
            W   = 1000; H = 680;

            % Figure
            app.UIFigure = uifigure('Visible','off');
            app.UIFigure.Position = [100 100 W H];
            app.UIFigure.Name = 'EEG Preprocessor';
            app.UIFigure.Color = BG;

            % Tab group
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [0 0 W H];

            tabNames = {'  Load Data  ','  Filtering  ','  Re-reference  ', ...
                        '  ICA  ','  Visualize  ','  Run & Save  ', ...
                        '  Wavelet Denoising  ','  Adaptive Filtering  ', ...
                        '  Comparison  ','  Signal Merging  ','  Results & Summary  '};
            tabProps = {'LoadTab','FilterTab','RereferenceTab','ICATab','VisualizeTab','RunTab', ...
                        'WaveletTab','AdaptiveTab','ComparisonTab','MergeTab','SummaryTab'};
            for i = 1:11
                app.(tabProps{i}) = uitab(app.TabGroup);
                app.(tabProps{i}).Title = tabNames{i};
                app.(tabProps{i}).BackgroundColor = BG;
            end

            % ══════════════════════════════════════════════════════════════
            %  LOAD DATA TAB
            % ══════════════════════════════════════════════════════════════
            P = app.LoadTab;

            hdr = uilabel(P);
            hdr.Position = [30 610 400 30]; hdr.Text = 'Load EEG Data';
            hdr.FontSize = 20; hdr.FontWeight = 'bold'; hdr.FontColor = TXT;

            sub = uilabel(P);
            sub.Position = [30 590 600 20];
            sub.Text = 'Select an EEG file (CSV, MAT or EDF) and an output folder.';
            sub.FontSize = 12; sub.FontColor = SUB;

            app.InputFilePanel = uipanel(P);
            app.InputFilePanel.Position = [30 480 920 105];
            app.InputFilePanel.Title = '  EEG File';
            app.InputFilePanel.FontSize = 12; app.InputFilePanel.FontWeight = 'bold';
            app.InputFilePanel.ForegroundColor = ACC; app.InputFilePanel.BackgroundColor = PNL;

            uilabel(app.InputFilePanel,'Position',[15 62 80 20],'Text','File path','FontColor',SUB,'FontSize',11);
            app.InputFileField = uieditfield(app.InputFilePanel,'text');
            app.InputFileField.Position = [15 32 760 28]; app.InputFileField.Placeholder = 'Select a file…';
            app.InputFileField.FontSize = 11; app.InputFileField.BackgroundColor = PNL;

            app.BrowseFileBtn = uibutton(app.InputFilePanel,'push');
            app.BrowseFileBtn.Position = [790 32 105 28]; app.BrowseFileBtn.Text = 'Browse…';
            app.BrowseFileBtn.BackgroundColor = [0.86 0.86 0.86];
            app.BrowseFileBtn.ButtonPushedFcn = createCallbackFcn(app,@BrowseFileBtnPushed,true);

            uilabel(app.InputFilePanel,'Position',[15 8 70 18],'Text','Detected type:','FontColor',SUB,'FontSize',10);
            app.FileTypeValue = uilabel(app.InputFilePanel);
            app.FileTypeValue.Position = [95 8 400 18]; app.FileTypeValue.Text = '–';
            app.FileTypeValue.FontSize = 10; app.FileTypeValue.FontColor = ACC;

            app.OutputPanel = uipanel(P);
            app.OutputPanel.Position = [30 360 920 105]; app.OutputPanel.Title = '  Output Folder';
            app.OutputPanel.FontSize = 12; app.OutputPanel.FontWeight = 'bold';
            app.OutputPanel.ForegroundColor = ACC; app.OutputPanel.BackgroundColor = PNL;

            uilabel(app.OutputPanel,'Position',[15 62 120 20],'Text','Save results to','FontColor',SUB,'FontSize',11);
            app.OutputFolderField = uieditfield(app.OutputPanel,'text');
            app.OutputFolderField.Position = [15 32 760 28]; app.OutputFolderField.Placeholder = 'Select output folder…';
            app.OutputFolderField.FontSize = 11; app.OutputFolderField.BackgroundColor = PNL;

            app.BrowseFolderBtn = uibutton(app.OutputPanel,'push');
            app.BrowseFolderBtn.Position = [790 32 105 28]; app.BrowseFolderBtn.Text = 'Browse…';
            app.BrowseFolderBtn.BackgroundColor = [0.86 0.86 0.86];
            app.BrowseFolderBtn.ButtonPushedFcn = createCallbackFcn(app,@BrowseFolderBtnPushed,true);

            app.ParamsPanel = uipanel(P);
            app.ParamsPanel.Position = [30 240 920 105]; app.ParamsPanel.Title = '  EEG Parameters';
            app.ParamsPanel.FontSize = 12; app.ParamsPanel.FontWeight = 'bold';
            app.ParamsPanel.ForegroundColor = ACC; app.ParamsPanel.BackgroundColor = PNL;

            uilabel(app.ParamsPanel,'Position',[15 62 300 20],'Text','Sampling Rate (Hz) – required for CSV/MAT','FontColor',SUB,'FontSize',11);
            app.SamplingRateField = uieditfield(app.ParamsPanel,'numeric');
            app.SamplingRateField.Position = [15 28 120 28]; app.SamplingRateField.Value = 256;
            app.SamplingRateField.Limits = [1 100000]; app.SamplingRateField.FontSize = 13;

            uilabel(app.ParamsPanel,'Position',[155 28 30 28],'Text','Hz','FontColor',SUB,'FontSize',12);
            uilabel(app.ParamsPanel,'Position',[250 62 200 20],'Text','Dataset info (after loading)','FontColor',SUB,'FontSize',11);
            app.NumChannelsValue = uilabel(app.ParamsPanel);
            app.NumChannelsValue.Position = [250 28 600 28]; app.NumChannelsValue.Text = '–';
            app.NumChannelsValue.FontSize = 12; app.NumChannelsValue.FontColor = ACC;

            app.StatusPanel = uipanel(P);
            app.StatusPanel.Position = [30 140 920 85]; app.StatusPanel.Title = '  Status';
            app.StatusPanel.FontSize = 12; app.StatusPanel.FontWeight = 'bold';
            app.StatusPanel.ForegroundColor = ACC; app.StatusPanel.BackgroundColor = PNL;

            app.StatusLabel = uilabel(app.StatusPanel);
            app.StatusLabel.Position = [15 12 760 40]; app.StatusLabel.Text = 'Ready.';
            app.StatusLabel.FontSize = 12; app.StatusLabel.FontColor = SUB; app.StatusLabel.WordWrap = 'on';

            app.LoadBtn = uibutton(app.StatusPanel,'push');
            app.LoadBtn.Position = [790 20 105 38]; app.LoadBtn.Text = 'Load File';
            app.LoadBtn.FontSize = 13; app.LoadBtn.FontWeight = 'bold';
            app.LoadBtn.BackgroundColor = [0.86 0.86 0.86];
            app.LoadBtn.ButtonPushedFcn = createCallbackFcn(app,@LoadBtnPushed,true);

            % ══════════════════════════════════════════════════════════════
            %  FILTERING TAB
            % ══════════════════════════════════════════════════════════════
            P = app.FilterTab;

            hdr = uilabel(P); hdr.Position = [30 610 400 30]; hdr.Text = 'Bandpass Filtering';
            hdr.FontSize = 20; hdr.FontWeight = 'bold'; hdr.FontColor = TXT;
            sub = uilabel(P); sub.Position = [30 590 700 20];
            sub.Text = 'Set low and high cutoff frequencies. Optionally apply a notch filter to remove power line noise.';
            sub.FontSize = 12; sub.FontColor = SUB;

            app.FiltPanel = uipanel(P);
            app.FiltPanel.Position = [30 380 920 200]; app.FiltPanel.Title = '  Filter Settings';
            app.FiltPanel.FontSize = 12; app.FiltPanel.FontWeight = 'bold';
            app.FiltPanel.ForegroundColor = ACC; app.FiltPanel.BackgroundColor = PNL;

            uilabel(app.FiltPanel,'Position',[15 148 150 22],'Text','Low cutoff (Hz)','FontColor',SUB,'FontSize',12);
            app.FiltLowCutField = uieditfield(app.FiltPanel,'numeric');
            app.FiltLowCutField.Position = [15 118 120 28]; app.FiltLowCutField.Value = 1;
            app.FiltLowCutField.Limits = [0 1000];

            uilabel(app.FiltPanel,'Position',[180 148 150 22],'Text','High cutoff (Hz)','FontColor',SUB,'FontSize',12);
            app.FiltHighCutField = uieditfield(app.FiltPanel,'numeric');
            app.FiltHighCutField.Position = [180 118 120 28]; app.FiltHighCutField.Value = 40;
            app.FiltHighCutField.Limits = [0 10000];

            app.FiltNotchCheck = uicheckbox(app.FiltPanel);
            app.FiltNotchCheck.Position = [15 70 200 22]; app.FiltNotchCheck.Text = 'Apply notch filter';
            app.FiltNotchCheck.FontSize = 12; app.FiltNotchCheck.Value = true;

            uilabel(app.FiltPanel,'Position',[15 40 150 22],'Text','Notch frequency (Hz)','FontColor',SUB,'FontSize',11);
            app.FiltNotchFreqField = uieditfield(app.FiltPanel,'numeric');
            app.FiltNotchFreqField.Position = [180 38 80 26]; app.FiltNotchFreqField.Value = 50;
            app.FiltNotchFreqField.Limits = [0 1000];

            app.FiltApplyBtn = uibutton(P,'push');
            app.FiltApplyBtn.Position = [30 320 160 38]; app.FiltApplyBtn.Text = 'Apply Filter';
            app.FiltApplyBtn.FontSize = 13; app.FiltApplyBtn.FontWeight = 'bold';
            app.FiltApplyBtn.FontColor = [1 1 1]; app.FiltApplyBtn.BackgroundColor = [0.15 0.15 0.15];
            app.FiltApplyBtn.ButtonPushedFcn = createCallbackFcn(app,@FiltApplyBtnPushed,true);

            app.FiltStatusLabel = uilabel(P);
            app.FiltStatusLabel.Position = [210 320 700 38]; app.FiltStatusLabel.Text = 'Ready.';
            app.FiltStatusLabel.FontSize = 12; app.FiltStatusLabel.FontColor = SUB; app.FiltStatusLabel.WordWrap = 'on';

            % ══════════════════════════════════════════════════════════════
            %  RE-REFERENCE TAB
            % ══════════════════════════════════════════════════════════════
            P = app.RereferenceTab;

            hdr = uilabel(P); hdr.Position = [30 610 400 30]; hdr.Text = 'Re-referencing';
            hdr.FontSize = 20; hdr.FontWeight = 'bold'; hdr.FontColor = TXT;
            sub = uilabel(P); sub.Position = [30 590 700 20];
            sub.Text = 'Choose a reference scheme and apply it to the loaded EEG data.';
            sub.FontSize = 12; sub.FontColor = SUB;

            app.RerefPanel = uipanel(P);
            app.RerefPanel.Position = [30 380 920 200]; app.RerefPanel.Title = '  Reference Settings';
            app.RerefPanel.FontSize = 12; app.RerefPanel.FontWeight = 'bold';
            app.RerefPanel.ForegroundColor = ACC; app.RerefPanel.BackgroundColor = PNL;

            uilabel(app.RerefPanel,'Position',[15 148 200 22],'Text','Reference type','FontColor',SUB,'FontSize',12);
            app.RerefTypeDropdown = uidropdown(app.RerefPanel);
            app.RerefTypeDropdown.Position = [15 118 260 28];
            app.RerefTypeDropdown.Items = {'Average reference','Specific channel(s)','Linked mastoids (TP9/TP10)'};
            app.RerefTypeDropdown.FontSize = 12;
            app.RerefTypeDropdown.ValueChangedFcn = createCallbackFcn(app,@RerefTypeChanged,true);

            uilabel(app.RerefPanel,'Position',[15 80 300 22],'Text','Channel number(s) – if specific channel selected','FontColor',SUB,'FontSize',11);
            app.RerefChanField = uieditfield(app.RerefPanel,'text');
            app.RerefChanField.Position = [15 52 200 28]; app.RerefChanField.Placeholder = 'e.g. 1 2';
            app.RerefChanField.FontSize = 12; app.RerefChanField.Enable = 'off';

            app.RerefApplyBtn = uibutton(P,'push');
            app.RerefApplyBtn.Position = [30 320 160 38]; app.RerefApplyBtn.Text = 'Apply Reference';
            app.RerefApplyBtn.FontSize = 13; app.RerefApplyBtn.FontWeight = 'bold';
            app.RerefApplyBtn.FontColor = [1 1 1]; app.RerefApplyBtn.BackgroundColor = [0.15 0.15 0.15];
            app.RerefApplyBtn.ButtonPushedFcn = createCallbackFcn(app,@RerefApplyBtnPushed,true);

            app.RerefStatusLabel = uilabel(P);
            app.RerefStatusLabel.Position = [210 320 700 38]; app.RerefStatusLabel.Text = 'Ready.';
            app.RerefStatusLabel.FontSize = 12; app.RerefStatusLabel.FontColor = SUB; app.RerefStatusLabel.WordWrap = 'on';

            % ══════════════════════════════════════════════════════════════
            %  ICA TAB
            % ══════════════════════════════════════════════════════════════
            P = app.ICATab;

            hdr = uilabel(P); hdr.Position = [30 610 500 30]; hdr.Text = 'ICA Artifact Removal';
            hdr.FontSize = 20; hdr.FontWeight = 'bold'; hdr.FontColor = TXT;
            sub = uilabel(P); sub.Position = [30 590 800 20];
            sub.Text = 'Run Independent Component Analysis, inspect the component topoplots, then reject artifact components by number.';
            sub.FontSize = 12; sub.FontColor = SUB;

            app.ICAPanel = uipanel(P);
            app.ICAPanel.Position = [30 350 920 230]; app.ICAPanel.Title = '  ICA Settings';
            app.ICAPanel.FontSize = 12; app.ICAPanel.FontWeight = 'bold';
            app.ICAPanel.ForegroundColor = ACC; app.ICAPanel.BackgroundColor = PNL;

            uilabel(app.ICAPanel,'Position',[15 178 700 22], ...
                'Text','Step 1: Run ICA decomposition (uses runica – extended infomax)', ...
                'FontColor',SUB,'FontSize',12);

            app.ICARunBtn = uibutton(app.ICAPanel,'push');
            app.ICARunBtn.Position = [15 140 160 34]; app.ICARunBtn.Text = 'Run ICA';
            app.ICARunBtn.FontSize = 13; app.ICARunBtn.FontWeight = 'bold';
            app.ICARunBtn.FontColor = [1 1 1]; app.ICARunBtn.BackgroundColor = [0.15 0.15 0.15];
            app.ICARunBtn.ButtonPushedFcn = createCallbackFcn(app,@ICARunBtnPushed,true);

            uilabel(app.ICAPanel,'Position',[15 95 700 22], ...
                'Text','Step 2: Enter component numbers to remove (space-separated, e.g. 1 3)', ...
                'FontColor',SUB,'FontSize',12);

            app.ICARejectField = uieditfield(app.ICAPanel,'text');
            app.ICARejectField.Position = [15 62 300 28]; app.ICARejectField.Placeholder = 'e.g. 1 2 5';
            app.ICARejectField.FontSize = 12;

            app.ICARejectBtn = uibutton(app.ICAPanel,'push');
            app.ICARejectBtn.Position = [330 62 180 28]; app.ICARejectBtn.Text = 'Remove Components';
            app.ICARejectBtn.FontSize = 12; app.ICARejectBtn.FontWeight = 'bold';
            app.ICARejectBtn.FontColor = [1 1 1]; app.ICARejectBtn.BackgroundColor = [0.60 0.15 0.15];
            app.ICARejectBtn.ButtonPushedFcn = createCallbackFcn(app,@ICARejectBtnPushed,true);

            app.ICAStatusLabel = uilabel(P);
            app.ICAStatusLabel.Position = [30 310 880 30]; app.ICAStatusLabel.Text = 'Ready.';
            app.ICAStatusLabel.FontSize = 12; app.ICAStatusLabel.FontColor = SUB; app.ICAStatusLabel.WordWrap = 'on';

            % ══════════════════════════════════════════════════════════════
            %  VISUALIZE TAB
            % ══════════════════════════════════════════════════════════════
            P = app.VisualizeTab;

            hdr = uilabel(P); hdr.Position = [30 610 400 30]; hdr.Text = 'Visualize EEG';
            hdr.FontSize = 20; hdr.FontWeight = 'bold'; hdr.FontColor = TXT;
            sub = uilabel(P); sub.Position = [30 590 700 20];
            sub.Text = 'Plot the raw/processed EEG signal or view the power spectrum.';
            sub.FontSize = 12; sub.FontColor = SUB;

            app.VizPanel = uipanel(P);
            app.VizPanel.Position = [30 380 920 200]; app.VizPanel.Title = '  Plot Options';
            app.VizPanel.FontSize = 12; app.VizPanel.FontWeight = 'bold';
            app.VizPanel.ForegroundColor = ACC; app.VizPanel.BackgroundColor = PNL;

            uilabel(app.VizPanel,'Position',[15 148 600 22], ...
                'Text','EEG Signal Plot – scrollable channel-by-channel view', ...
                'FontColor',SUB,'FontSize',12);
            app.VizPlotBtn = uibutton(app.VizPanel,'push');
            app.VizPlotBtn.Position = [15 108 200 34]; app.VizPlotBtn.Text = 'Plot EEG Signal';
            app.VizPlotBtn.FontSize = 13; app.VizPlotBtn.FontWeight = 'bold';
            app.VizPlotBtn.FontColor = [1 1 1]; app.VizPlotBtn.BackgroundColor = [0.15 0.15 0.15];
            app.VizPlotBtn.ButtonPushedFcn = createCallbackFcn(app,@VizPlotBtnPushed,true);

            uilabel(app.VizPanel,'Position',[15 72 600 22], ...
                'Text','Power Spectrum – frequency domain view per channel', ...
                'FontColor',SUB,'FontSize',12);
            app.VizSpecBtn = uibutton(app.VizPanel,'push');
            app.VizSpecBtn.Position = [15 34 200 34]; app.VizSpecBtn.Text = 'Plot Power Spectrum';
            app.VizSpecBtn.FontSize = 13; app.VizSpecBtn.FontWeight = 'bold';
            app.VizSpecBtn.FontColor = [1 1 1]; app.VizSpecBtn.BackgroundColor = [0.15 0.35 0.55];
            app.VizSpecBtn.ButtonPushedFcn = createCallbackFcn(app,@VizSpecBtnPushed,true);

            app.VizStatusLabel = uilabel(P);
            app.VizStatusLabel.Position = [30 340 880 30]; app.VizStatusLabel.Text = 'Ready.';
            app.VizStatusLabel.FontSize = 12; app.VizStatusLabel.FontColor = SUB;

            % ══════════════════════════════════════════════════════════════
            %  RUN & SAVE TAB
            % ══════════════════════════════════════════════════════════════
            P = app.RunTab;

            hdr = uilabel(P); hdr.Position = [30 610 400 30]; hdr.Text = 'Run Pipeline & Save';
            hdr.FontSize = 20; hdr.FontWeight = 'bold'; hdr.FontColor = TXT;
            sub = uilabel(P); sub.Position = [30 590 800 20];
            sub.Text = 'Select which steps to run in sequence, then export the processed dataset.';
            sub.FontSize = 12; sub.FontColor = SUB;

            app.RunPanel = uipanel(P);
            app.RunPanel.Position = [30 380 920 200]; app.RunPanel.Title = '  Pipeline Steps';
            app.RunPanel.FontSize = 12; app.RunPanel.FontWeight = 'bold';
            app.RunPanel.ForegroundColor = ACC; app.RunPanel.BackgroundColor = PNL;

            uilabel(app.RunPanel,'Position',[15 158 700 22], ...
                'Text','Select steps to include (uses settings from each tab):','FontColor',SUB,'FontSize',12);

            app.RunFilterCheck = uicheckbox(app.RunPanel);
            app.RunFilterCheck.Position = [15 124 300 24]; app.RunFilterCheck.Value = true;
            app.RunFilterCheck.Text = 'Bandpass filter (settings from Filtering tab)';
            app.RunFilterCheck.FontSize = 12;

            app.RunRerefCheck = uicheckbox(app.RunPanel);
            app.RunRerefCheck.Position = [15 92 300 24]; app.RunRerefCheck.Value = true;
            app.RunRerefCheck.Text = 'Re-reference (average reference)';
            app.RunRerefCheck.FontSize = 12;

            app.RunICACheck = uicheckbox(app.RunPanel);
            app.RunICACheck.Position = [15 60 300 24]; app.RunICACheck.Value = false;
            app.RunICACheck.Text = 'Run ICA (slow – uncheck for quick runs)';
            app.RunICACheck.FontSize = 12;

            app.RunAllBtn = uibutton(P,'push');
            app.RunAllBtn.Position = [30 320 160 38]; app.RunAllBtn.Text = 'Run Pipeline';
            app.RunAllBtn.FontSize = 13; app.RunAllBtn.FontWeight = 'bold';
            app.RunAllBtn.FontColor = [1 1 1]; app.RunAllBtn.BackgroundColor = [0.10 0.40 0.20];
            app.RunAllBtn.ButtonPushedFcn = createCallbackFcn(app,@RunAllBtnPushed,true);

            app.SaveBtn = uibutton(P,'push');
            app.SaveBtn.Position = [210 320 160 38]; app.SaveBtn.Text = 'Save Results';
            app.SaveBtn.FontSize = 13; app.SaveBtn.FontWeight = 'bold';
            app.SaveBtn.FontColor = [1 1 1]; app.SaveBtn.BackgroundColor = [0.15 0.15 0.55];
            app.SaveBtn.ButtonPushedFcn = createCallbackFcn(app,@SaveBtnPushed,true);

            app.RunStatusLabel = uilabel(P);
            app.RunStatusLabel.Position = [390 320 560 38]; app.RunStatusLabel.Text = 'Ready.';
            app.RunStatusLabel.FontSize = 12; app.RunStatusLabel.FontColor = SUB; app.RunStatusLabel.WordWrap = 'on';

            % ══════════════════════════════════════════════════════════════
            %  WAVELET DENOISING TAB
            % ══════════════════════════════════════════════════════════════
            P = app.WaveletTab;

            hdr = uilabel(P); hdr.Position = [30 610 400 30]; hdr.Text = 'Wavelet Denoising';
            hdr.FontSize = 20; hdr.FontWeight = 'bold'; hdr.FontColor = TXT;
            sub = uilabel(P); sub.Position = [30 590 800 20];
            sub.Text = 'Decompose EEG using discrete wavelet transform and remove noise via coefficient thresholding.';
            sub.FontSize = 12; sub.FontColor = SUB;

            wPanel = uipanel(P);
            wPanel.Position = [30 440 920 140]; wPanel.Title = '  Wavelet Settings';
            wPanel.FontSize = 12; wPanel.FontWeight = 'bold';
            wPanel.ForegroundColor = ACC; wPanel.BackgroundColor = PNL;

            uilabel(wPanel,'Position',[15 95 150 22],'Text','Wavelet family','FontColor',SUB,'FontSize',12);
            app.WaveletFamilyDropdown = uidropdown(wPanel);
            app.WaveletFamilyDropdown.Position = [15 65 160 28];
            app.WaveletFamilyDropdown.Items = {'db4','db6','db8','sym5','sym8','coif3','coif5'};
            app.WaveletFamilyDropdown.FontSize = 12;

            uilabel(wPanel,'Position',[210 95 150 22],'Text','Decomposition level','FontColor',SUB,'FontSize',12);
            app.WaveletLevelField = uieditfield(wPanel,'numeric');
            app.WaveletLevelField.Position = [210 65 100 28];
            app.WaveletLevelField.Value = 5; app.WaveletLevelField.Limits = [1 10];
            app.WaveletLevelField.FontSize = 12;

            uilabel(wPanel,'Position',[345 95 150 22],'Text','Threshold type','FontColor',SUB,'FontSize',12);
            app.WaveletThreshDropdown = uidropdown(wPanel);
            app.WaveletThreshDropdown.Position = [345 65 140 28];
            app.WaveletThreshDropdown.Items = {'Soft','Hard','Minimax'};
            app.WaveletThreshDropdown.FontSize = 12;

            app.WaveletApplyBtn = uibutton(P,'push');
            app.WaveletApplyBtn.Position = [30 390 180 38]; app.WaveletApplyBtn.Text = 'Apply Wavelet Denoising';
            app.WaveletApplyBtn.FontSize = 12; app.WaveletApplyBtn.FontWeight = 'bold';
            app.WaveletApplyBtn.FontColor = [1 1 1]; app.WaveletApplyBtn.BackgroundColor = [0.15 0.15 0.15];
            app.WaveletApplyBtn.ButtonPushedFcn = createCallbackFcn(app,@WaveletApplyBtnPushed,true);

            app.WaveletStatusLabel = uilabel(P);
            app.WaveletStatusLabel.Position = [225 390 700 38]; app.WaveletStatusLabel.Text = 'Ready.';
            app.WaveletStatusLabel.FontSize = 12; app.WaveletStatusLabel.FontColor = SUB; app.WaveletStatusLabel.WordWrap = 'on';

            % Before/after plots
            app.WaveletAxesBefore = uiaxes(P);
            app.WaveletAxesBefore.Position = [30 170 440 210];
            title(app.WaveletAxesBefore,'Before Denoising (Ch 1)');
            xlabel(app.WaveletAxesBefore,'Time (s)'); ylabel(app.WaveletAxesBefore,'Amplitude (µV)');

            app.WaveletAxesAfter = uiaxes(P);
            app.WaveletAxesAfter.Position = [510 170 440 210];
            title(app.WaveletAxesAfter,'After Denoising (Ch 1)');
            xlabel(app.WaveletAxesAfter,'Time (s)'); ylabel(app.WaveletAxesAfter,'Amplitude (µV)');

            % ══════════════════════════════════════════════════════════════
            %  ADAPTIVE FILTERING TAB
            % ══════════════════════════════════════════════════════════════
            P = app.AdaptiveTab;

            hdr = uilabel(P); hdr.Position = [30 610 400 30]; hdr.Text = 'Adaptive Filtering';
            hdr.FontSize = 20; hdr.FontWeight = 'bold'; hdr.FontColor = TXT;
            sub = uilabel(P); sub.Position = [30 590 800 20];
            sub.Text = 'Apply LMS or RLS adaptive filtering to suppress noise by learning the noise pattern from the signal.';
            sub.FontSize = 12; sub.FontColor = SUB;

            aPanel = uipanel(P);
            aPanel.Position = [30 440 920 140]; aPanel.Title = '  Adaptive Filter Settings';
            aPanel.FontSize = 12; aPanel.FontWeight = 'bold';
            aPanel.ForegroundColor = ACC; aPanel.BackgroundColor = PNL;

            uilabel(aPanel,'Position',[15 95 120 22],'Text','Algorithm','FontColor',SUB,'FontSize',12);
            app.AdaptAlgoDropdown = uidropdown(aPanel);
            app.AdaptAlgoDropdown.Position = [15 65 120 28];
            app.AdaptAlgoDropdown.Items = {'LMS','RLS'};
            app.AdaptAlgoDropdown.FontSize = 12;

            uilabel(aPanel,'Position',[165 95 180 22],'Text','Step size / mu','FontColor',SUB,'FontSize',12);
            app.AdaptMuField = uieditfield(aPanel,'numeric');
            app.AdaptMuField.Position = [165 65 110 28];
            app.AdaptMuField.Value = 0.01; app.AdaptMuField.Limits = [1e-6 1];
            app.AdaptMuField.FontSize = 12;

            uilabel(aPanel,'Position',[310 95 120 22],'Text','Filter order','FontColor',SUB,'FontSize',12);
            app.AdaptOrderField = uieditfield(aPanel,'numeric');
            app.AdaptOrderField.Position = [310 65 100 28];
            app.AdaptOrderField.Value = 8; app.AdaptOrderField.Limits = [1 64];
            app.AdaptOrderField.FontSize = 12;

            app.AdaptApplyBtn = uibutton(P,'push');
            app.AdaptApplyBtn.Position = [30 390 190 38]; app.AdaptApplyBtn.Text = 'Apply Adaptive Filter';
            app.AdaptApplyBtn.FontSize = 12; app.AdaptApplyBtn.FontWeight = 'bold';
            app.AdaptApplyBtn.FontColor = [1 1 1]; app.AdaptApplyBtn.BackgroundColor = [0.15 0.15 0.15];
            app.AdaptApplyBtn.ButtonPushedFcn = createCallbackFcn(app,@AdaptApplyBtnPushed,true);

            app.AdaptStatusLabel = uilabel(P);
            app.AdaptStatusLabel.Position = [235 390 680 38]; app.AdaptStatusLabel.Text = 'Ready.';
            app.AdaptStatusLabel.FontSize = 12; app.AdaptStatusLabel.FontColor = SUB; app.AdaptStatusLabel.WordWrap = 'on';

            app.AdaptAxesBefore = uiaxes(P);
            app.AdaptAxesBefore.Position = [30 170 440 210];
            title(app.AdaptAxesBefore,'Before (Ch 1)');
            xlabel(app.AdaptAxesBefore,'Time (s)'); ylabel(app.AdaptAxesBefore,'Amplitude (µV)');

            app.AdaptAxesAfter = uiaxes(P);
            app.AdaptAxesAfter.Position = [510 170 440 210];
            title(app.AdaptAxesAfter,'After (Ch 1)');
            xlabel(app.AdaptAxesAfter,'Time (s)'); ylabel(app.AdaptAxesAfter,'Amplitude (µV)');

            % ══════════════════════════════════════════════════════════════
            %  COMPARISON TAB
            % ══════════════════════════════════════════════════════════════
            P = app.ComparisonTab;

            hdr = uilabel(P); hdr.Position = [30 610 500 30]; hdr.Text = 'Method Comparison & Metrics';
            hdr.FontSize = 20; hdr.FontWeight = 'bold'; hdr.FontColor = TXT;
            sub = uilabel(P); sub.Position = [30 590 800 20];
            sub.Text = 'Compare original vs processed EEG using SNR, MSE, and Correlation Coefficient across all channels.';
            sub.FontSize = 12; sub.FontColor = SUB;

            app.CompRunBtn = uibutton(P,'push');
            app.CompRunBtn.Position = [30 545 200 38]; app.CompRunBtn.Text = 'Compute Metrics';
            app.CompRunBtn.FontSize = 13; app.CompRunBtn.FontWeight = 'bold';
            app.CompRunBtn.FontColor = [1 1 1]; app.CompRunBtn.BackgroundColor = [0.15 0.15 0.15];
            app.CompRunBtn.ButtonPushedFcn = createCallbackFcn(app,@CompRunBtnPushed,true);

            app.CompStatusLabel = uilabel(P);
            app.CompStatusLabel.Position = [245 545 680 38]; app.CompStatusLabel.Text = 'Load a file and apply processing first, then compute metrics.';
            app.CompStatusLabel.FontSize = 12; app.CompStatusLabel.FontColor = SUB; app.CompStatusLabel.WordWrap = 'on';

            app.CompAxes = uiaxes(P);
            app.CompAxes.Position = [30 270 560 260];
            title(app.CompAxes,'SNR per Channel (dB)');
            xlabel(app.CompAxes,'Channel'); ylabel(app.CompAxes,'SNR (dB)');

            metricsPanel = uipanel(P);
            metricsPanel.Position = [610 270 340 260]; metricsPanel.Title = '  Quantitative Results';
            metricsPanel.FontSize = 12; metricsPanel.FontWeight = 'bold';
            metricsPanel.ForegroundColor = ACC; metricsPanel.BackgroundColor = PNL;

            app.CompMetricsArea = uitextarea(metricsPanel);
            app.CompMetricsArea.Position = [10 10 315 220];
            app.CompMetricsArea.FontSize = 11; app.CompMetricsArea.Editable = 'off';
            app.CompMetricsArea.BackgroundColor = PNL;
            app.CompMetricsArea.Value = 'Metrics will appear here after computing.';

            % ══════════════════════════════════════════════════════════════
            %  SIGNAL MERGING TAB
            % ══════════════════════════════════════════════════════════════
            P = app.MergeTab;

            hdr = uilabel(P); hdr.Position = [30 610 400 30]; hdr.Text = 'Signal Merging';
            hdr.FontSize = 20; hdr.FontWeight = 'bold'; hdr.FontColor = TXT;
            sub = uilabel(P); sub.Position = [30 590 800 20];
            sub.Text = 'Overlay and compare multiple EEG channels in a single plot with vertical offsets for clarity.';
            sub.FontSize = 12; sub.FontColor = SUB;

            uilabel(P,'Position',[30 555 300 22],'Text','Channels to merge (e.g. 1 2 3 4 5 6)','FontColor',SUB,'FontSize',12);
            app.MergeChanField = uieditfield(P,'text');
            app.MergeChanField.Position = [30 525 300 30]; app.MergeChanField.Placeholder = 'Leave blank for first 6';
            app.MergeChanField.FontSize = 12;

            app.MergePlotBtn = uibutton(P,'push');
            app.MergePlotBtn.Position = [350 525 160 32]; app.MergePlotBtn.Text = 'Plot Merged';
            app.MergePlotBtn.FontSize = 12; app.MergePlotBtn.FontWeight = 'bold';
            app.MergePlotBtn.FontColor = [1 1 1]; app.MergePlotBtn.BackgroundColor = [0.15 0.15 0.15];
            app.MergePlotBtn.ButtonPushedFcn = createCallbackFcn(app,@MergePlotBtnPushed,true);

            app.MergeStatusLabel = uilabel(P);
            app.MergeStatusLabel.Position = [530 525 420 32]; app.MergeStatusLabel.Text = 'Ready.';
            app.MergeStatusLabel.FontSize = 12; app.MergeStatusLabel.FontColor = SUB;

            app.MergeAxes = uiaxes(P);
            app.MergeAxes.Position = [30 80 940 430];
            title(app.MergeAxes,'Merged Channel View');
            xlabel(app.MergeAxes,'Time (s)'); ylabel(app.MergeAxes,'Amplitude + offset (µV)');

            % ══════════════════════════════════════════════════════════════
            %  RESULTS & SUMMARY TAB
            % ══════════════════════════════════════════════════════════════
            P = app.SummaryTab;

            hdr = uilabel(P); hdr.Position = [30 610 500 30]; hdr.Text = 'Results & Summary';
            hdr.FontSize = 20; hdr.FontWeight = 'bold'; hdr.FontColor = TXT;
            sub = uilabel(P); sub.Position = [30 590 800 20];
            sub.Text = 'Select a processing step from the dropdown to learn what it does and why it matters.';
            sub.FontSize = 12; sub.FontColor = SUB;

            % Dropdown
            uilabel(P,'Position',[30 555 200 22],'Text','Select a step to explain:','FontColor',SUB,'FontSize',12);
            app.SummaryStepDropdown = uidropdown(P);
            app.SummaryStepDropdown.Position = [30 525 280 30];
            app.SummaryStepDropdown.Items = {'Load Data','Filtering','Re-reference','ICA','Wavelet Denoising','Run & Save'};
            app.SummaryStepDropdown.FontSize = 13;
            app.SummaryStepDropdown.ValueChangedFcn = createCallbackFcn(app,@SummaryStepChanged,true);

            % Explanation panel
            explPanel = uipanel(P);
            explPanel.Position = [30 300 920 215]; explPanel.Title = '  What this step does';
            explPanel.FontSize = 12; explPanel.FontWeight = 'bold';
            explPanel.ForegroundColor = ACC; explPanel.BackgroundColor = PNL;

            app.SummaryExplanationArea = uitextarea(explPanel);
            app.SummaryExplanationArea.Position = [10 10 895 175];
            app.SummaryExplanationArea.FontSize = 12;
            app.SummaryExplanationArea.Editable = 'off';
            app.SummaryExplanationArea.BackgroundColor = PNL;
            app.SummaryExplanationArea.Value = 'Select a step above to see its explanation.';

            % Processing log panel
            logPanel = uipanel(P);
            logPanel.Position = [30 50 920 235]; logPanel.Title = '  Processing Log (this session)';
            logPanel.FontSize = 12; logPanel.FontWeight = 'bold';
            logPanel.ForegroundColor = ACC; logPanel.BackgroundColor = PNL;

            app.SummaryLogArea = uitextarea(logPanel);
            app.SummaryLogArea.Position = [10 10 895 195];
            app.SummaryLogArea.FontSize = 11;
            app.SummaryLogArea.Editable = 'off';
            app.SummaryLogArea.BackgroundColor = [0.97 0.97 0.97];
            app.SummaryLogArea.Value = 'No steps applied yet.';

            app.UIFigure.Visible = 'on';
        end
    end

    % ══════════════════════════════════════════════════════════════════════
    %  Constructor / Destructor
    % ══════════════════════════════════════════════════════════════════════
    methods (Access = public)

        function app = EEGMainApp(filepath)
            createComponents(app);
            registerApp(app, app.UIFigure);
            runStartupFcn(app, @startupFcn);
            if nargin > 0 && ~isempty(filepath) && isfile(filepath)
                app.InputFileField.Value = filepath;
                [~,~,ext] = fileparts(filepath);
                switch lower(ext)
                    case '.csv'; app.FileTypeValue.Text = 'CSV  (comma-separated values)';
                    case '.mat'; app.FileTypeValue.Text = 'MAT  (MATLAB data file)';
                    case '.edf'; app.FileTypeValue.Text = 'EDF  (European Data Format)';
                end
                app.setStatus(['File selected: ' filepath '  –  Click "Load File" to import.'], 'idle');
            end
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end
end
