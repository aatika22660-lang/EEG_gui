classdef EEGMainApp < matlab.apps.AppBase

    properties (Access = public)
        UIFigure        matlab.ui.Figure
        FiltChanSpinner     matlab.ui.control.Spinner
        PipelineTab         matlab.ui.container.Tab

        % Tab group
        TabGroup        matlab.ui.container.TabGroup
        LoadTab         matlab.ui.container.Tab
        FilterTab       matlab.ui.container.Panel   % overlay panel inside PipelineTab
        RereferenceTab  matlab.ui.container.Panel   % overlay panel inside PipelineTab
        ICATab          matlab.ui.container.Panel   % overlay panel inside PipelineTab
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

        ConfirmFileBtn         matlab.ui.control.Button
        RejectFileBtn          matlab.ui.control.Button
        FileInfoPanel          matlab.ui.container.Panel
        FileNameValueLabel     matlab.ui.control.Label
        FileFormatValueLabel   matlab.ui.control.Label
        FileChanValueLabel     matlab.ui.control.Label
        FileSRateValueLabel    matlab.ui.control.Label
        FileDurValueLabel      matlab.ui.control.Label
        FileSamplesValueLabel  matlab.ui.control.Label
        RawEEGPanel            matlab.ui.container.Panel
        RawEEGAxes             matlab.ui.control.UIAxes

        StatusPanel     matlab.ui.container.Panel
        StatusLabel     matlab.ui.control.Label
        LoadBtn         matlab.ui.control.Button
        ContinueBtn     matlab.ui.control.Button

        % ── Filter tab components ─────────────────────────────────────────────
        FiltPanel           matlab.ui.container.Panel
        FiltLowCutField     matlab.ui.control.NumericEditField
        FiltHighCutField    matlab.ui.control.NumericEditField
        FiltNotchCheck      matlab.ui.control.CheckBox
        FiltNotchFreqField  matlab.ui.control.NumericEditField
        FiltApplyBtn        matlab.ui.control.Button
        FiltStatusLabel     matlab.ui.control.Label
        PresetDropdown      matlab.ui.control.DropDown
        FiltAxesBefore      matlab.ui.control.UIAxes
        FiltAxesAfter       matlab.ui.control.UIAxes
        FiltRMSLabel        matlab.ui.control.Label
        FiltPowerLabel      matlab.ui.control.Label
        FiltSNRLabel        matlab.ui.control.Label
        FiltChanLabel       matlab.ui.control.Label
        RerefNextBtn        matlab.ui.control.Button

        % ── Re-reference tab components ───────────────────────────────────
        RerefSettingsPanel  matlab.ui.container.Panel
        RerefTypeDropdown   matlab.ui.control.DropDown
        RerefChanField      matlab.ui.control.EditField
        RerefApplyBtn       matlab.ui.control.Button
        RerefStatusLabel    matlab.ui.control.Label
        RerefAxesBefore     matlab.ui.control.UIAxes
        RerefAxesAfter      matlab.ui.control.UIAxes
        RerefRMSLabel       matlab.ui.control.Label
        RerefSNRLabel       matlab.ui.control.Label
        RerefCorrLabel      matlab.ui.control.Label
        RerefChanSpinner    matlab.ui.control.Spinner
        RerefChanLabel      matlab.ui.control.Label
        RerefICANextBtn     matlab.ui.control.Button

        % ── ICA tab components ────────────────────────────────────────────
        ICAPanel            matlab.ui.container.Panel
        ICARunBtn           matlab.ui.control.Button
        ICAGuideDropdown    matlab.ui.control.DropDown
        ICARejectField      matlab.ui.control.EditField
        ICARejectBtn        matlab.ui.control.Button
        ICAStatusLabel      matlab.ui.control.Label
        ICAAxesBefore       matlab.ui.control.UIAxes
        ICAAxesAfter        matlab.ui.control.UIAxes
        ICAVizBtn           matlab.ui.control.Button
        ICAChanSpinner      matlab.ui.control.Spinner
        ICAChanLabel        matlab.ui.control.Label
        ICATopoAxes         matlab.ui.control.UIAxes
        ICATopoPanel        matlab.ui.container.Panel
        ICAOverlayAxes      matlab.ui.control.UIAxes
        ICAOverlayPanel     matlab.ui.container.Panel

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

    methods (Access = private)

        function startupFcn(app)
            movegui(app.UIFigure, 'center');
            app.DataLoaded    = false;
            app.EEG           = struct();
            app.EEG_original  = struct();
            app.ProcessingLog = {};
            app.setStatus('No file loaded. Please select an EEG file to begin.', 'idle');

            eeglabRoot = '/Users/aatikashaikh/project_gui/documents/eeglab2026.0.0';
            if ~exist('eeg_emptyset', 'file')
                if isfolder(eeglabRoot)
                    addpath(genpath(eeglabRoot));
                else
                    eeglabFcn = which('eeglab');
                    if ~isempty(eeglabFcn)
                        addpath(genpath(fileparts(eeglabFcn)));
                    end
                end
            end
        end

    end

    methods (Access = private)

        function RejectFileBtnPushed(app, ~)
            app.InputFileField.Value  = '';
            app.FileTypeValue.Text    = '–';
            app.FileNameValueLabel.Text    = '–';
            app.FileFormatValueLabel.Text  = '–';
            app.FileChanValueLabel.Text    = '–';
            app.FileSRateValueLabel.Text   = '–';
            app.FileDurValueLabel.Text     = '–';
            app.FileSamplesValueLabel.Text = '–';
            cla(app.RawEEGAxes);
            title(app.RawEEGAxes, 'Load an EEG file to preview the raw signal');
            app.DataLoaded          = false;
            app.ContinueBtn.Visible = 'off';
            app.setStatus('File cleared – please select a new EEG file.', 'idle');
            app.BrowseFileBtnPushed([]);
        end

        function FiltChanChanged(app, ~)
            if ~app.DataLoaded; return; end
            if ~isfield(app.EEG_original, 'data') || isempty(fieldnames(app.EEG_original)); return; end
            ch = round(app.FiltChanSpinner.Value);
            t  = (0:app.EEG.pnts-1) / app.EEG.srate;
            plot(app.FiltAxesBefore, t, double(app.EEG_original.data(ch,:)), ...
                'Color', [0.20 0.45 0.75], 'LineWidth', 0.6);
            title(app.FiltAxesBefore, sprintf('Before Filtering (Ch %d)', ch));
            xlabel(app.FiltAxesBefore, 'Time (s)');
            ylabel(app.FiltAxesBefore, 'Amplitude (µV)');
            plot(app.FiltAxesAfter, t, double(app.EEG.data(ch,:)), ...
                'Color', [0.10 0.55 0.25], 'LineWidth', 0.6);
            title(app.FiltAxesAfter, sprintf('After Filtering (Ch %d)', ch));
            xlabel(app.FiltAxesAfter, 'Time (s)');
            ylabel(app.FiltAxesAfter, 'Amplitude (µV)');
            raw  = double(app.EEG_original.data(ch,:));
            filt = double(app.EEG.data(ch,:));
            rms_before = sqrt(mean(raw.^2));
            rms_after  = sqrt(mean(filt.^2));
            pwr_before = mean(raw.^2);
            pwr_after  = mean(filt.^2);
            noise      = raw - filt;
            snr_val    = 10*log10(pwr_after / max(mean(noise.^2), eps));
            app.FiltRMSLabel.Text        = sprintf('RMS:  %.2f → %.2f µV', rms_before, rms_after);
            app.FiltPowerLabel.Text      = sprintf('Power:  %.2f → %.2f µV²', pwr_before, pwr_after);
            app.FiltSNRLabel.Text        = sprintf('SNR improvement:  %.2f dB', snr_val);
            app.FiltRMSLabel.FontColor   = [0.85 0.85 0.85];
            app.FiltPowerLabel.FontColor = [0.85 0.85 0.85];
            app.FiltSNRLabel.FontColor   = [0.10 0.55 0.25];
        end

        function BrowseFileBtnPushed(app, ~)
            app.UIFigure.Visible = 'off';
            drawnow;
            [file, path] = uigetfile( ...
                {'*.csv','CSV Files (*.csv)'; ...
                 '*.mat','MATLAB Files (*.mat)'; ...
                 '*.edf','EDF Files (*.edf)'; ...
                 '*.*','All Files (*.*)'}, ...
                'Select EEG File');
            app.UIFigure.Visible = 'on';
            figure(app.UIFigure);
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
            app.UIFigure.Visible = 'off';
            drawnow;
            folder = uigetdir('', 'Select Output Folder');
            app.UIFigure.Visible = 'on';
            figure(app.UIFigure);
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
                app.DataLoaded    = true;
                app.EEG_original  = app.EEG;

                durationSec = app.EEG.pnts / app.EEG.srate;
                [~, fname, fext] = fileparts(filepath);
                switch lower(fext)
                    case '.csv'; fmtStr = 'CSV  (comma-separated values)';
                    case '.mat'; fmtStr = 'MAT  (MATLAB data file)';
                    case '.edf'; fmtStr = 'EDF  (European Data Format)';
                    otherwise;   fmtStr = ['Unknown (' fext ')'];
                end

                app.FileNameValueLabel.Text    = [fname fext];
                app.FileFormatValueLabel.Text  = fmtStr;
                app.FileChanValueLabel.Text    = sprintf('%d', app.EEG.nbchan);
                app.FileSRateValueLabel.Text   = sprintf('%d Hz', app.EEG.srate);
                app.FileDurValueLabel.Text     = sprintf('%.2f s  (%.1f min)', durationSec, durationSec/60);
                app.FileSamplesValueLabel.Text = sprintf('%d  (%d per channel)', ...
                    app.EEG.nbchan * app.EEG.pnts, app.EEG.pnts);

                try
                    CH_COLS = [0.791 0.425 0.410; 0.818 0.527 0.276; 0.387 0.700 0.444;
                               0.334 0.634 0.486; 0.359 0.516 0.753; 0.470 0.501 0.845;
                               0.640 0.546 0.923; 0.45  0.45  0.45 ];
                    t     = (0:app.EEG.pnts-1) / app.EEG.srate;
                    plotN = min(8, app.EEG.nbchan);
                    cla(app.RawEEGAxes);
                    hold(app.RawEEGAxes, 'on');
                    allMax = 0;
                    for c = 1:plotN
                        allMax = max(allMax, max(abs(double(app.EEG.data(c,:)))));
                    end
                    rowSpacing = allMax * 2.5 + eps;
                    for c = 1:plotN
                        sig    = double(app.EEG.data(c,:));
                        isDead = (var(sig) < 1e-6);
                        col    = CH_COLS(min(c, size(CH_COLS,1)), :);
                        offset = (plotN - c) * rowSpacing;
                        if isDead
                            plot(app.RawEEGAxes, [t(1) t(end)], [offset offset], ...
                                '--', 'Color', [0.45 0.45 0.45], 'LineWidth', 0.8);
                        else
                            plot(app.RawEEGAxes, t, sig + offset, ...
                                'Color', col, 'LineWidth', 0.7);
                        end
                    end
                    hold(app.RawEEGAxes, 'off');
                    chanNames = cell(1, plotN);
                    for c = 1:plotN
                        if isfield(app.EEG, 'chanlocs') && ~isempty(app.EEG.chanlocs) ...
                                && c <= numel(app.EEG.chanlocs) ...
                                && ~isempty(app.EEG.chanlocs(c).labels)
                            chanNames{c} = app.EEG.chanlocs(c).labels;
                        else
                            chanNames{c} = sprintf('Ch%d', c);
                        end
                    end
                    app.RawEEGAxes.YTick      = (0:(plotN-1)) * rowSpacing;
                    app.RawEEGAxes.YTickLabel = flip(chanNames);
                    app.RawEEGAxes.YColor     = [0.40 0.40 0.40];
                    app.RawEEGAxes.XLim       = [t(1) t(end)];
                    title(app.RawEEGAxes, ...
                        sprintf('RAW EEG SIGNAL  –  first %d of %d channels', plotN, app.EEG.nbchan), ...
                        'FontSize', 10, 'Color', [0.286 0.392 0.569], 'FontWeight', 'bold');
                    xlabel(app.RawEEGAxes, 'Time (s)', 'Color', [0.45 0.45 0.45]);
                    ylabel(app.RawEEGAxes, '', 'Color', [0.45 0.45 0.45]);
                catch
                end

                try
                    WARN_O  = [0.658 0.340 0.336];
                    SEP_C   = [0.20 0.20 0.20];
                    CH_COLS2 = [0.791 0.425 0.410; 0.818 0.527 0.276; 0.387 0.700 0.444;
                                0.334 0.634 0.486; 0.359 0.516 0.753; 0.470 0.501 0.845;
                                0.640 0.546 0.923; 0.45  0.45  0.45 ];
                    DEAD_R  = [0.747 0.404 0.393];
                    plotN2 = min(8, app.EEG.nbchan);
                    allPanels = findobj(app.LoadTab, 'Type', 'uipanel');
                    cdPnl = [];
                    for pi = 1:numel(allPanels)
                        kids = allPanels(pi).Children;
                        for ki = 1:numel(kids)
                            if isprop(kids(ki),'Text') && strcmp(kids(ki).Text,'CHANNELS DETECTED')
                                cdPnl = allPanels(pi); break;
                            end
                        end
                        if ~isempty(cdPnl); break; end
                    end
                    if ~isempty(cdPnl)
                        existKids = cdPnl.Children;
                        for ki = 1:numel(existKids)
                            if isprop(existKids(ki),'Tag') && strcmp(existKids(ki).Tag,'chrow')
                                delete(existKids(ki));
                            end
                        end
                        cdH   = cdPnl.Position(4);
                        rowH2 = 26; startY2 = cdH - 56;
                        deadChs = {};
                        for c = 1:plotN2
                            sig2   = double(app.EEG.data(c,:));
                            isDead = (var(sig2) < 1e-6);
                            col2   = CH_COLS2(min(c, size(CH_COLS2,1)), :);
                            yy     = startY2 - (c-1)*rowH2;
                            if yy < 4; break; end
                            if isfield(app.EEG,'chanlocs') && ~isempty(app.EEG.chanlocs) ...
                                    && c <= numel(app.EEG.chanlocs) && ~isempty(app.EEG.chanlocs(c).labels)
                                cname = app.EEG.chanlocs(c).labels;
                            else
                                cname = sprintf('Ch%d', c);
                            end
                            if isDead; dotCol = DEAD_R; else; dotCol = col2; end
                            uilabel(cdPnl,'Position',[14 yy 14 18],'Text','●', ...
                                'FontSize',10,'FontColor', dotCol, 'Tag','chrow');
                            uilabel(cdPnl,'Position',[30 yy 80 18],'Text',cname, ...
                                'FontSize',11,'FontColor',[0.85 0.85 0.85],'Tag','chrow');
                            if isDead
                                uilabel(cdPnl,'Position',[110 yy 200 18],'Text','△ Dead – flat line', ...
                                    'FontSize',9,'FontColor',WARN_O,'Tag','chrow');
                                deadChs{end+1} = cname;
                            end
                            if c < plotN2
                                uilabel(cdPnl,'Position',[14 yy-1 cdPnl.Position(3)-28 1], ...
                                    'Text','','BackgroundColor',SEP_C,'Tag','chrow');
                            end
                        end
                        if ~isempty(deadChs)
                            deadList = strjoin(deadChs, ', ');
                            app.StatusLabel.Text = sprintf('△ Bad channel(s) detected: %s – flat line (dead electrode).', deadList);
                            app.StatusLabel.FontColor = [0.747 0.404 0.393];
                            app.StatusPanel.HighlightColor = [0.747 0.404 0.393];
                            app.StatusPanel.BackgroundColor = [0.095 0.057 0.056];
                        end
                    end
                catch
                end

                app.NumChannelsValue.Text = sprintf('%d channels  ·  %d samples  ·  %.1f s', ...
                    app.EEG.nbchan, app.EEG.pnts, durationSec);
                app.FileTypeValue.Text = fmtStr;
                app.FileTypeValue.Visible = 'off';

                app.FiltChanSpinner.Limits = [1 app.EEG.nbchan];
                app.FiltChanLabel.Text     = sprintf('/ %d ch', app.EEG.nbchan);
                app.ICAChanSpinner.Limits  = [1 app.EEG.nbchan];
                app.ICAChanLabel.Text      = sprintf('/ %d ch', app.EEG.nbchan);

                app.setStatus(sprintf('✔  Loaded – %d channels, %.1f s @ %d Hz', ...
                    app.EEG.nbchan, durationSec, app.EEG.srate), 'ok');
                app.addLog(sprintf('Data Loaded: %d channels, %.1f s @ %d Hz', ...
                    app.EEG.nbchan, durationSec, app.EEG.srate));
                app.ContinueBtn.Visible = 'on';

            catch ME
                app.setStatus(['Error loading file: ' ME.message], 'error');
            end
        end

        function FiltApplyBtnPushed(app, ~)
            if ~app.DataLoaded
                app.FiltStatusLabel.Text      = 'Load a file first.';
                app.FiltStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            lo = app.FiltLowCutField.Value;
            hi = app.FiltHighCutField.Value;
            app.FiltStatusLabel.Text      = 'Applying bandpass filter…';
            app.FiltStatusLabel.FontColor = [0.65 0.45 0.00]; drawnow;
            try
                t = (0:app.EEG.pnts-1) / app.EEG.srate;
                raw = double(app.EEG.data(1,:));
                plot(app.FiltAxesBefore, t, raw, 'Color', [0.20 0.45 0.75], 'LineWidth', 0.6);
                title(app.FiltAxesBefore, 'Before Filtering (Ch 1)');
                xlabel(app.FiltAxesBefore, 'Time (s)');
                ylabel(app.FiltAxesBefore, 'Amplitude (µV)');
                rms_before = sqrt(mean(raw.^2));
                pwr_before = mean(raw.^2);
                app.EEG = pop_eegfiltnew(app.EEG, lo, hi);
                if app.FiltNotchCheck.Value
                    nf = app.FiltNotchFreqField.Value;
                    app.EEG = pop_eegfiltnew(app.EEG, nf-2, nf+2, [], 1);
                end
                app.EEG = eeg_checkset(app.EEG);
                filt = double(app.EEG.data(1,:));
                plot(app.FiltAxesAfter, t, filt, 'Color', [0.10 0.55 0.25], 'LineWidth', 0.6);
                title(app.FiltAxesAfter, 'After Filtering (Ch 1)');
                xlabel(app.FiltAxesAfter, 'Time (s)');
                ylabel(app.FiltAxesAfter, 'Amplitude (µV)');
                rms_after = sqrt(mean(filt.^2));
                pwr_after = mean(filt.^2);
                noise     = raw - filt;
                snr_val   = 10*log10(pwr_after / max(mean(noise.^2), eps));
                if app.FiltNotchCheck.Value
                    nf      = app.FiltNotchFreqField.Value;
                    filtStr = sprintf('Bandpass [%.1f–%.1f Hz] + Notch @ %.0f Hz applied', lo, hi, nf);
                    app.addLog(sprintf('Bandpass Filter: %.1f–%.1f Hz + Notch @ %.0f Hz', lo, hi, nf));
                else
                    filtStr = sprintf('Bandpass [%.1f–%.1f Hz] applied', lo, hi);
                    app.addLog(sprintf('Bandpass Filter: %.1f–%.1f Hz', lo, hi));
                end
                app.FiltStatusLabel.Text      = filtStr;
                app.FiltStatusLabel.FontColor = [0.10 0.55 0.25];
                app.FiltRMSLabel.Text         = sprintf('RMS:  %.2f → %.2f µV', rms_before, rms_after);
                app.FiltPowerLabel.Text       = sprintf('Power:  %.2f → %.2f µV²', pwr_before, pwr_after);
                app.FiltSNRLabel.Text         = sprintf('SNR improvement:  %.2f dB', snr_val);
                app.FiltRMSLabel.FontColor    = [0.85 0.85 0.85];
                app.FiltPowerLabel.FontColor  = [0.85 0.85 0.85];
                app.FiltSNRLabel.FontColor    = [0.10 0.55 0.25];
                app.RerefNextBtn.Visible      = 'on';
            catch ME
                app.FiltStatusLabel.Text      = ['Error: ' ME.message];
                app.FiltStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        function PresetChanged(app, ~)
            val = app.PresetDropdown.Value;
            if contains(val, 'General EEG')
                app.FiltLowCutField.Value = 1; app.FiltHighCutField.Value = 40;
                app.FiltNotchCheck.Value = true; app.FiltNotchFreqField.Value = 50;
            elseif contains(val, 'Sleep Analysis')
                app.FiltLowCutField.Value = 0.5; app.FiltHighCutField.Value = 35;
                app.FiltNotchCheck.Value = true; app.FiltNotchFreqField.Value = 50;
            elseif contains(val, 'Motor Imagery')
                app.FiltLowCutField.Value = 8; app.FiltHighCutField.Value = 30;
                app.FiltNotchCheck.Value = true; app.FiltNotchFreqField.Value = 50;
            elseif contains(val, 'Emotion')
                app.FiltLowCutField.Value = 4; app.FiltHighCutField.Value = 45;
                app.FiltNotchCheck.Value = true; app.FiltNotchFreqField.Value = 50;
            elseif contains(val, 'Epilepsy')
                app.FiltLowCutField.Value = 0.5; app.FiltHighCutField.Value = 70;
                app.FiltNotchCheck.Value = true; app.FiltNotchFreqField.Value = 50;
            end
            if ~contains(val, 'Select') && ~contains(val, 'Custom')
                app.FiltStatusLabel.Text = 'Preset loaded – click Apply Filter when ready.';
                app.FiltStatusLabel.FontColor = [0.65 0.45 0.00];
            end
        end

        function RerefChanChanged(app, ~)
            if ~app.DataLoaded; return; end
            if ~isfield(app.EEG_original,'data') || isempty(fieldnames(app.EEG_original)); return; end
            ch  = round(app.RerefChanSpinner.Value);
            t   = (0:app.EEG.pnts-1) / app.EEG.srate;
            raw   = double(app.EEG_original.data(ch,:));
            reref = double(app.EEG.data(ch,:));
            plot(app.RerefAxesBefore, t, raw,   'Color',[0.20 0.45 0.75],'LineWidth',0.6);
            title(app.RerefAxesBefore, sprintf('Before Re-reference (Ch %d)', ch));
            xlabel(app.RerefAxesBefore,'Time (s)'); ylabel(app.RerefAxesBefore,'Amplitude (µV)');
            plot(app.RerefAxesAfter,  t, reref, 'Color',[0.10 0.55 0.25],'LineWidth',0.6);
            title(app.RerefAxesAfter,  sprintf('After Re-reference (Ch %d)', ch));
            xlabel(app.RerefAxesAfter,'Time (s)');  ylabel(app.RerefAxesAfter,'Amplitude (µV)');
            rms_before = sqrt(mean(raw.^2));
            rms_after  = sqrt(mean(reref.^2));
            noise      = raw - reref;
            snr_val    = 10*log10(mean(reref.^2) / max(mean(noise.^2), eps));
            cc         = corrcoef(raw, reref);
            app.RerefRMSLabel.Text  = sprintf('RMS:  %.2f → %.2f µV', rms_before, rms_after);
            app.RerefSNRLabel.Text  = sprintf('SNR change:  %.2f dB', snr_val);
            app.RerefCorrLabel.Text = sprintf('Correlation with original:  %.4f', cc(1,2));
            app.RerefRMSLabel.FontColor  = [0.85 0.85 0.85];
            app.RerefSNRLabel.FontColor  = [0.10 0.55 0.25];
            app.RerefCorrLabel.FontColor = [0.85 0.85 0.85];
        end

        function RerefApplyBtnPushed(app, ~)
            if ~app.DataLoaded
                app.RerefStatusLabel.Text = 'Load a file first.';
                app.RerefStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            app.RerefStatusLabel.Text = 'Applying re-reference…';
            app.RerefStatusLabel.FontColor = [0.65 0.45 0.00]; drawnow;
            try
                raw = double(app.EEG_original.data(1,:));
                t   = (0:app.EEG.pnts-1) / app.EEG.srate;
                plot(app.RerefAxesBefore, t, raw, 'Color', [0.20 0.45 0.75], 'LineWidth', 0.6);
                title(app.RerefAxesBefore, 'Before Re-reference (Ch 1)');
                xlabel(app.RerefAxesBefore,'Time (s)');
                ylabel(app.RerefAxesBefore,'Amplitude (µV)');
                refType = app.RerefTypeDropdown.Value;
                switch refType
                    case 'Average reference'
                        app.EEG = pop_reref(app.EEG, []);
                    case 'Specific channel(s)'
                        chanStr  = app.RerefChanField.Value;
                        chanNums = str2num(chanStr); %#ok<ST2NM>
                        if isempty(chanNums); error('Enter valid channel number(s).'); end
                        app.EEG = pop_reref(app.EEG, chanNums);
                    case 'Linked mastoids (TP9/TP10)'
                        idx = find(ismember({app.EEG.chanlocs.labels}, {'TP9','TP10'}));
                        if isempty(idx); error('TP9/TP10 channels not found in dataset.'); end
                        app.EEG = pop_reref(app.EEG, idx);
                end
                app.EEG = eeg_checkset(app.EEG);
                reref = double(app.EEG.data(1,:));
                plot(app.RerefAxesAfter, t, reref, 'Color', [0.10 0.55 0.25], 'LineWidth', 0.6);
                title(app.RerefAxesAfter, 'After Re-reference (Ch 1)');
                xlabel(app.RerefAxesAfter,'Time (s)');
                ylabel(app.RerefAxesAfter,'Amplitude (µV)');
                rms_before = sqrt(mean(raw.^2));
                rms_after  = sqrt(mean(reref.^2));
                noise      = raw - reref;
                snr_val    = 10*log10(mean(reref.^2) / max(mean(noise.^2), eps));
                cc         = corrcoef(raw, reref);
                app.RerefRMSLabel.Text  = sprintf('RMS:  %.2f → %.2f µV', rms_before, rms_after);
                app.RerefSNRLabel.Text  = sprintf('SNR change:  %.2f dB', snr_val);
                app.RerefCorrLabel.Text = sprintf('Correlation with original:  %.4f', cc(1,2));
                app.RerefRMSLabel.FontColor  = [0.85 0.85 0.85];
                app.RerefSNRLabel.FontColor  = [0.10 0.55 0.25];
                app.RerefCorrLabel.FontColor = [0.85 0.85 0.85];
                app.RerefStatusLabel.Text      = ['✔  Re-referenced to: ' refType];
                app.RerefStatusLabel.FontColor = [0.10 0.55 0.25];
                app.addLog(['Re-reference: ' refType]);
                app.RerefChanSpinner.Limits = [1 app.EEG.nbchan];
                app.RerefChanLabel.Text     = sprintf('/ %d ch', app.EEG.nbchan);
                app.RerefICANextBtn.Visible = 'on';
            catch ME
                app.RerefStatusLabel.Text      = ['Error: ' ME.message];
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
                try
                    app.EEG = pop_chanedit(app.EEG, 'lookup', which('standard-10-5-cap385.elp'));
                    app.EEG = eeg_checkset(app.EEG);
                catch
                    app.EEG.chanlocs = makeUniformChanlocs(app, app.EEG.nbchan);
                end
                assignin('base', 'EEG_debug', app.EEG);
                nComp = size(app.EEG.icawinv, 2);
                app.ICAStatusLabel.Text = sprintf('✔  ICA complete – %d components found. Inspect topoplots below, identify artifacts, then enter component numbers in Step 2.', nComp);
                app.ICAStatusLabel.FontColor = [0.10 0.55 0.25];
                app.addLog(sprintf('ICA: decomposition complete (%d components)', nComp));
                app.ICAChanSpinner.Limits = [1 app.EEG.nbchan];
                app.ICAChanLabel.Text = sprintf('/ %d ch', app.EEG.nbchan);
                delete(app.ICATopoPanel.Children);
                app.ICATopoPanel.Scrollable = 'on';
                rowH    = 110; topoW = 110; sigW = 760; padX = 10; padY = 6;
                canvasH = nComp * (rowH + padY) + 20;
                panelInner = uipanel(app.ICATopoPanel);
                panelInner.Position        = [0 0 900 canvasH];
                panelInner.BorderType      = 'none';
                panelInner.BackgroundColor = [0.102 0.102 0.102];
                panelInner.Scrollable      = 'on';
                chanlocs = app.EEG.chanlocs;
                icawinv  = app.EEG.icawinv;
                icaact   = app.EEG.icaact;
                t        = (0:app.EEG.pnts-1) / app.EEG.srate;
                for ci = 1:nComp
                    yPos = canvasH - ci*(rowH + padY) + padY;
                    lbl = uilabel(panelInner);
                    lbl.Position  = [padX, yPos + rowH - 18, 50, 16];
                    lbl.Text      = sprintf('n. %d', ci);
                    lbl.FontSize  = 9; lbl.FontWeight = 'bold';
                    lbl.FontColor = [0.80 0.80 0.80];
                    topoAx = uiaxes(panelInner);
                    topoAx.Position = [padX, yPos, topoW, rowH - 20];
                    topoAx.Color    = [0.102 0.102 0.102];
                    topoAx.XAxis.Visible = 'off'; topoAx.YAxis.Visible = 'off';
                    topoAx.Box = 'off';
                    disableDefaultInteractivity(topoAx);
                    try
                        tmpFig = figure('Visible','off');
                        tmpAx  = axes(tmpFig);
                        topoplot(icawinv(:,ci), chanlocs, 'electrodes', 'off', 'shading', 'interp', 'style', 'map');
                        kids = get(tmpAx, 'Children');
                        copyobj(kids, topoAx);
                        topoAx.XLim = tmpAx.XLim; topoAx.YLim = tmpAx.YLim;
                        close(tmpFig);
                    catch ME
                        text(topoAx, 0.5, 0.5, ME.message(1:min(30,numel(ME.message))), ...
                            'HorizontalAlignment','center','Units','normalized','FontSize',7,'Color',[0.8 0.1 0.1]);
                    end
                    sigAx = uiaxes(panelInner);
                    sigAx.Position = [padX + topoW + 10, yPos, sigW, rowH - 20];
                    sigAx.Color    = [0.102 0.102 0.102];
                    sigAx.XAxis.FontSize = 7; sigAx.YAxis.FontSize = 7;
                    sigAx.Box = 'off';
                    sigAx.XColor = [0.50 0.50 0.50]; sigAx.YColor = [0.50 0.50 0.50];
                    disableDefaultInteractivity(sigAx);
                    try
                        sig = double(icaact(ci,:));
                        plot(sigAx, t, sig, 'Color', [0.20 0.45 0.75], 'LineWidth', 0.5);
                        sigAx.XLim = [t(1) t(end)];
                        ymax = max(abs(sig));
                        if ymax > 0; sigAx.YLim = [-ymax*1.2 ymax*1.2]; end
                    catch
                        text(sigAx, 0.5, 0.5, 'No activation data', 'HorizontalAlignment','center','Units','normalized','FontSize',8,'Color',[0.6 0.6 0.6]);
                    end
                    if ci < nComp
                        sep = uilabel(panelInner);
                        sep.Position = [0 yPos-3 900 1];
                        sep.Text = ''; sep.BackgroundColor = [0.20 0.20 0.20];
                    end
                end
                app.ICATopoPanel.Title = sprintf('  Component Topoplots  (%d components)', nComp);
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
                ch  = round(app.ICAChanSpinner.Value);
                t   = (0:app.EEG.pnts-1) / app.EEG.srate;
                preRemoval = double(app.EEG.data(ch,:));
                figsBefore = findall(0, 'Type', 'figure');
                app.EEG = pop_subcomp(app.EEG, compNums, 0);
                app.EEG = eeg_checkset(app.EEG);
                figsAfter = findall(0, 'Type', 'figure');
                newFigs = setdiff(figsAfter, figsBefore);
                delete(newFigs);
                app.ICAStatusLabel.Text = sprintf('✔  Components [%s] removed. Pre-processing complete.', compStr);
                app.ICAStatusLabel.FontColor = [0.10 0.55 0.25];
                app.addLog(sprintf('ICA Rejection: removed components [%s]', compStr));
                clean = double(app.EEG.data(ch,:));
                plot(app.ICAAxesAfter, t, clean, 'Color', [0.10 0.55 0.25], 'LineWidth', 0.6);
                title(app.ICAAxesAfter, 'After ICA');
                xlabel(app.ICAAxesAfter,'Time (s)'); ylabel(app.ICAAxesAfter,'Amplitude (µV)');
                artifactSig = preRemoval - clean;
                cla(app.ICAOverlayAxes);
                hold(app.ICAOverlayAxes, 'on');
                plot(app.ICAOverlayAxes, t, preRemoval, 'Color', [0.80 0.10 0.10], 'LineWidth', 0.7);
                plot(app.ICAOverlayAxes, t, artifactSig, 'Color', [0.20 0.45 0.75], 'LineWidth', 0.7, 'LineStyle', '--');
                hold(app.ICAOverlayAxes, 'off');
                title(app.ICAOverlayAxes, sprintf('Overlay – Ch %d  (red = pre-removal | blue dashed = artifact)', ch), 'FontSize', 9);
                xlabel(app.ICAOverlayAxes,'Time (s)'); ylabel(app.ICAOverlayAxes,'µV');
                app.ICAOverlayAxes.YLim = [-max(abs(preRemoval))*1.2, max(abs(preRemoval))*1.2];
                app.ICAOverlayPanel.Visible = 'on';
                app.ICAVizBtn.Visible = 'on';
            catch ME
                app.ICAStatusLabel.Text = ['Error: ' ME.message];
                app.ICAStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        function ICAChanChanged(app, ~)
            if ~app.DataLoaded; return; end
            ch = round(app.ICAChanSpinner.Value);
            t  = (0:app.EEG.pnts-1) / app.EEG.srate;
            if isfield(app.EEG_original,'data') && ~isempty(fieldnames(app.EEG_original))
                raw = double(app.EEG_original.data(ch,:));
                plot(app.ICAAxesBefore, t, raw, 'Color', [0.20 0.45 0.75], 'LineWidth', 0.6);
                title(app.ICAAxesBefore, 'Before ICA');
                xlabel(app.ICAAxesBefore,'Time (s)'); ylabel(app.ICAAxesBefore,'Amplitude (µV)');
            end
            clean = double(app.EEG.data(ch,:));
            plot(app.ICAAxesAfter, t, clean, 'Color', [0.10 0.55 0.25], 'LineWidth', 0.6);
            title(app.ICAAxesAfter, 'After ICA');
            xlabel(app.ICAAxesAfter,'Time (s)'); ylabel(app.ICAAxesAfter,'Amplitude (µV)');
        end

        function locs = makeUniformChanlocs(~, nChan)
            locs = struct();
            angles = linspace(0, 360, nChan+1); angles(end) = [];
            for k = 1:nChan
                locs(k).labels = sprintf('Ch%d', k);
                locs(k).theta  = angles(k); locs(k).radius = 0.4;
                locs(k).X = 0.4*cosd(angles(k)); locs(k).Y = 0.4*sind(angles(k)); locs(k).Z = 0;
                locs(k).sph_theta = angles(k); locs(k).sph_phi = 0; locs(k).sph_radius = 0.4;
                locs(k).type = ''; locs(k).ref = ''; locs(k).urchan = k;
            end
        end

        function VizPlotBtnPushed(app, ~)
            if ~app.DataLoaded
                app.ICAStatusLabel.Text = 'Load a file first.';
                app.ICAStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            try
                pop_eegplot(app.EEG, 1, 1, 1);
                app.ICAStatusLabel.Text = '✔  EEG signal plot opened.';
                app.ICAStatusLabel.FontColor = [0.10 0.55 0.25];
            catch ME
                app.ICAStatusLabel.Text = ['Error: ' ME.message];
                app.ICAStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        function VizSpecBtnPushed(app, ~)
            if ~app.DataLoaded
                app.ICAStatusLabel.Text = 'Load a file first.';
                app.ICAStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            try
                pop_spectopo(app.EEG, 1, [], 'EEG');
                app.ICAStatusLabel.Text = '✔  Power spectrum plot opened.';
                app.ICAStatusLabel.FontColor = [0.10 0.55 0.25];
            catch ME
                app.ICAStatusLabel.Text = ['Error: ' ME.message];
                app.ICAStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        function RunAllBtnPushed(app, ~)
            if ~app.DataLoaded
                app.RunStatusLabel.Text = 'Load a file first.';
                app.RunStatusLabel.FontColor = [0.75 0.10 0.10]; return;
            end
            app.RunStatusLabel.Text = 'Running pipeline…';
            app.RunStatusLabel.FontColor = [0.65 0.45 0.00]; drawnow;
            try
                if app.RunFilterCheck.Value
                    lo = app.FiltLowCutField.Value; hi = app.FiltHighCutField.Value;
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
            % If no folder set, ask the user right now
            outDir = strtrim(app.OutputFolderField.Value);
            if isempty(outDir) || ~isfolder(outDir)
                app.UIFigure.Visible = 'off'; drawnow;
                outDir = uigetdir('', 'Select folder to save processed EEG');
                app.UIFigure.Visible = 'on'; figure(app.UIFigure);
                if isequal(outDir, 0)
                    app.RunStatusLabel.Text = 'Save cancelled – no folder selected.';
                    app.RunStatusLabel.FontColor = [0.65 0.45 0.00]; return;
                end
                app.OutputFolderField.Value = outDir;
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
                plot(app.AdaptAxesBefore, t, app.EEG.data(ch,:), 'Color',[0.20 0.45 0.75], 'LineWidth', 0.5);
                title(app.AdaptAxesBefore,'Before Adaptive Filter (Ch 1)');
                xlabel(app.AdaptAxesBefore,'Time (s)'); ylabel(app.AdaptAxesBefore,'Amplitude (µV)');
                denoised = zeros(size(app.EEG.data));
                for c = 1:app.EEG.nbchan
                    x = double(app.EEG.data(c,:));
                    N = length(x); w = zeros(order, 1); y = zeros(1, N);
                    switch algo
                        case 'LMS'
                            for n = order:N
                                 xv = x(n:-1:n-order+1)';
                                 y(n) = w'*xv;
                                 e = x(n) - y(n);
                                 power = xv'*xv + 1e-8;
                                 w = w + (mu / power) * e * xv;
                            end
                        case 'RLS'
                            lambda = 0.99; P_mat = (1/mu)*eye(order);
                            for n = order:N
                                xv = x(n:-1:n-order+1)';
                                k = (P_mat*xv)/(lambda+xv'*P_mat*xv);
                                y(n) = w'*xv; e = x(n)-y(n);
                                w = w+k*e; P_mat = (P_mat-k*xv'*P_mat)/lambda;
                            end
                    end
                    denoised(c,:) = x - y;
                    if max(abs(denoised(c,:))) > 1e6
                        denoised(c,:) = x;  % fallback to original if filter blew up
                    end
                end
                plot(app.AdaptAxesAfter, t, denoised(ch,:), 'Color',[0.10 0.55 0.25], 'LineWidth', 0.5);
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
                nch = min(size(orig,1), size(proc,1));
                npt = min(size(orig,2), size(proc,2));
                orig = orig(1:nch, 1:npt); proc = proc(1:nch, 1:npt);
                snr_vals  = zeros(1,nch); mse_vals = zeros(1,nch); corr_vals = zeros(1,nch);
                for c = 1:nch
                    o = orig(c,:); p = proc(c,:);
                    noise = o-p; sig_pow = mean(p.^2); noise_pow = mean(noise.^2);
                    snr_vals(c)  = 10*log10(sig_pow/max(noise_pow,eps));
                    mse_vals(c)  = mean(noise.^2);
                    r = corrcoef(o,p); corr_vals(c) = r(1,2);
                end
                snr_mean = mean(snr_vals); mse_mean = mean(mse_vals); corr_mean = mean(corr_vals);
                plotN = min(nch, 32);
                bar(app.CompAxes, 1:plotN, snr_vals(1:plotN));
                app.CompAxes.Color   = [0.078 0.078 0.078];
                app.CompAxes.XColor  = [0.85 0.85 0.85];
                app.CompAxes.YColor  = [0.85 0.85 0.85];
                app.CompAxes.Title.Color  = [0.85 0.85 0.85];
                app.CompAxes.XLabel.Color = [0.85 0.85 0.85];
                app.CompAxes.YLabel.Color = [0.85 0.85 0.85];
                title(app.CompAxes, 'SNR per Channel (dB)');
                xlabel(app.CompAxes, 'Channel'); ylabel(app.CompAxes, 'SNR (dB)');
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
                app.CompMetricsArea.FontColor = [0.85 0.85 0.85];
                app.CompStatusLabel.Text = sprintf('✔  SNR: %.2f dB  |  MSE: %.4f  |  Corr: %.4f', snr_mean, mse_mean, corr_mean);
                app.CompStatusLabel.FontColor = [0.10 0.55 0.25];
                app.addLog(sprintf('Comparison: SNR=%.2f dB, MSE=%.4f, Corr=%.4f', snr_mean, mse_mean, corr_mean));
            catch ME
                app.CompStatusLabel.Text = ['Error: ' ME.message];
                app.CompStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

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
                cla(app.MergeAxes); hold(app.MergeAxes, 'on');
                colors = lines(length(chans));
                legendEntries = cell(1, length(chans));
                for i = 1:length(chans)
                    c = chans(i); offset = (i-1)*50;
                    plot(app.MergeAxes, t, app.EEG.data(c,:)+offset, 'Color', colors(i,:), 'LineWidth', 0.8);
                    if ~isempty(app.EEG.chanlocs) && c <= length(app.EEG.chanlocs) && ~isempty(app.EEG.chanlocs(c).labels)
                        legendEntries{i} = app.EEG.chanlocs(c).labels;
                    else
                        legendEntries{i} = sprintf('Ch %d', c);
                    end
                end
                hold(app.MergeAxes, 'off');
                legend(app.MergeAxes, legendEntries, 'Location', 'eastoutside', 'FontSize', 9, 'TextColor', [0.85 0.85 0.85]);
                app.MergeAxes.Color   = [0.078 0.078 0.078];
                app.MergeAxes.XColor  = [0.85 0.85 0.85];
                app.MergeAxes.YColor  = [0.85 0.85 0.85];
                app.MergeAxes.Title.Color  = [0.85 0.85 0.85];
                app.MergeAxes.XLabel.Color = [0.85 0.85 0.85];
                app.MergeAxes.YLabel.Color = [0.85 0.85 0.85];
                title(app.MergeAxes, 'Merged Channel View');
                xlabel(app.MergeAxes, 'Time (s)'); ylabel(app.MergeAxes, 'Amplitude + offset (µV)');
                app.MergeStatusLabel.Text = sprintf('✔  Showing %d channels overlaid.', length(chans));
                app.MergeStatusLabel.FontColor = [0.10 0.55 0.25];
                app.addLog(sprintf('Signal Merge: channels [%s]', num2str(chans)));
            catch ME
                app.MergeStatusLabel.Text = ['Error: ' ME.message];
                app.MergeStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

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
                ch = min(1, app.EEG.nbchan);
                t  = (0:app.EEG.pnts-1) / app.EEG.srate;
                plot(app.WaveletAxesBefore, t, app.EEG.data(ch,:), 'Color',[0.20 0.45 0.75], 'LineWidth', 0.5);
                title(app.WaveletAxesBefore, 'Before Denoising (Ch 1)');
                xlabel(app.WaveletAxesBefore, 'Time (s)'); ylabel(app.WaveletAxesBefore, 'Amplitude (µV)');
                denoised = zeros(size(app.EEG.data));
                for c = 1:app.EEG.nbchan
                    sig = double(app.EEG.data(c,:));
                    [C, L] = wavedec(sig, level, wname);
                    sigma = median(abs(C)) / 0.6745;
                    thr   = sigma * sqrt(2 * log(length(sig)));
                    switch ttype
                        case 'Soft';    C_thresh = wthresh(C, 's', thr);
                        case 'Hard';    C_thresh = wthresh(C, 'h', thr);
                        case 'Minimax'; thr_mm = sigma*0.3936+0.1829*log(length(sig))/log(2);
                                        C_thresh = wthresh(C, 's', thr_mm);
                    end
                    denoised(c,:) = waverec(C_thresh, L, wname);
                end
                plot(app.WaveletAxesAfter, t, denoised(ch,:), 'Color',[0.10 0.55 0.25], 'LineWidth', 0.5);
                title(app.WaveletAxesAfter, 'After Denoising (Ch 1)');
                xlabel(app.WaveletAxesAfter, 'Time (s)'); ylabel(app.WaveletAxesAfter, 'Amplitude (µV)');
                % Apply dark theme to wavelet axes
                for axObj = [app.WaveletAxesBefore, app.WaveletAxesAfter]
                    axObj.Color = [0.078 0.078 0.078];
                    axObj.XColor = [0.85 0.85 0.85]; axObj.YColor = [0.85 0.85 0.85];
                    axObj.Title.Color = [0.85 0.85 0.85];
                    axObj.XLabel.Color = [0.85 0.85 0.85]; axObj.YLabel.Color = [0.85 0.85 0.85];
                end
                signal_power = mean(denoised(ch,:).^2);
                noise_power  = mean((app.EEG.data(ch,:) - denoised(ch,:)).^2);
                if noise_power > 0
                    snr_str = sprintf('  |  SNR improvement: %.2f dB', 10*log10(signal_power/noise_power));
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

        function addLog(app, entry)
            timestamp = datestr(now, 'HH:MM:SS');
            app.ProcessingLog{end+1} = sprintf('[%s] %s', timestamp, entry);
            app.SummaryLogArea.Value = app.ProcessingLog;
            app.SummaryLogArea.FontColor = [0.85 0.85 0.85];
        end

        function SummaryStepChanged(app, ~)
            step = app.SummaryStepDropdown.Value;
            explanations = struct();
            explanations.load = ['LOADING EEG DATA' newline newline ...
                'EEG data is recorded as electrical signals from electrodes on the scalp. ' ...
                'Each channel represents one electrode capturing voltage fluctuations from neural activity.' newline newline ...
                'Supported formats:' newline ...
                '  CSV  – raw data matrix, rows = channels, columns = timepoints' newline ...
                '  MAT  – MATLAB format, often structured as an EEGLAB EEG struct' newline ...
                '  EDF  – European Data Format, standard clinical EEG format with metadata' newline newline ...
                'The sampling rate tells the system how many data points were recorded per second (e.g. 256 Hz).'];
            explanations.filter = ['BANDPASS FILTERING' newline newline ...
                'Raw EEG contains noise from many sources. Filtering keeps only the frequency range we care about.' newline newline ...
                'Low cutoff (e.g. 1 Hz): removes slow drifts caused by sweat or electrode movement.' newline ...
                'High cutoff (e.g. 40 Hz): removes high-frequency noise like muscle activity (EMG).' newline newline ...
                'Notch filter (50 Hz in Pakistan/Europe, 60 Hz in USA): removes power line interference.' newline newline ...
                'Typical clinical EEG band: 0.5–70 Hz. For motor imagery/BCI: 8–30 Hz.'];
            explanations.reref = ['RE-REFERENCING' newline newline ...
                'EEG signals are always measured relative to a reference electrode. The choice of reference affects your data.' newline newline ...
                'Average reference: subtracts the mean of all channels. Best for high-density EEG (64+ channels).' newline newline ...
                'Specific channel: uses one electrode (e.g. Cz, mastoid) as the reference.' newline newline ...
                'Linked mastoids (TP9/TP10): uses the average of both mastoid electrodes. Widely used in research.'];
            explanations.ica = ['INDEPENDENT COMPONENT ANALYSIS (ICA)' newline newline ...
                'ICA is a blind source separation technique that mathematically separates the EEG into independent sources.' newline newline ...
                'After running ICA, each component represents one estimated source. You inspect the topoplots and time courses to identify which are artifacts.' newline newline ...
                'Common artifacts:' newline ...
                '  Eye Blinks – large amplitude, frontal electrodes' newline ...
                '  Eye Movements – horizontal dipole pattern at front' newline ...
                '  Heartbeat (ECG) – rhythmic, ~1 Hz' newline ...
                '  Muscle (EMG) – high frequency, peripheral electrodes'];
            explanations.wavelet = ['WAVELET-BASED DENOISING' newline newline ...
                'Wavelet denoising decomposes the EEG signal into multiple frequency bands using the Discrete Wavelet Transform (DWT), then removes noise by thresholding wavelet coefficients.' newline newline ...
                'Wavelet families:' newline ...
                '  db4/db6/db8  – Daubechies wavelets, good general-purpose choice for EEG' newline ...
                '  sym5/sym8    – Symlets, similar to Daubechies but more symmetric' newline ...
                '  coif3/coif5  – Coiflets, better for signals with smooth features' newline newline ...
                'Threshold types: Soft (smooth result), Hard (keeps large coefficients), Minimax (balanced).'];
            explanations.save = ['SAVING RESULTS' newline newline ...
                'The processed EEG dataset is saved as a .mat file in EEGLAB format.' newline newline ...
                'The file is timestamped automatically so you never overwrite a previous result.' newline newline ...
                'You can reload this .mat file back into EEGLAB or this tool for further analysis.'];
            switch step
                case 'Load Data';          app.SummaryExplanationArea.Value = explanations.load;
                case 'Filtering';          app.SummaryExplanationArea.Value = explanations.filter;
                case 'Re-reference';       app.SummaryExplanationArea.Value = explanations.reref;
                case 'ICA';                app.SummaryExplanationArea.Value = explanations.ica;
                case 'Wavelet Denoising';  app.SummaryExplanationArea.Value = explanations.wavelet;
                case 'Run & Save';         app.SummaryExplanationArea.Value = explanations.save;
            end
            app.SummaryExplanationArea.FontColor = [0.85 0.85 0.85];
        end

        function setStatus(app, msg, state)
            app.StatusLabel.Text = msg;
            switch state
                case 'ok'
                    app.StatusLabel.FontColor       = [0.305 0.496 0.334];
                    app.StatusPanel.BackgroundColor = [0.0055 0.0055 0.0055];
                    app.StatusPanel.HighlightColor  = [0.305 0.496 0.334];
                case 'error'
                    app.StatusLabel.FontColor       = [0.747 0.404 0.393];
                    app.StatusPanel.BackgroundColor = [0.095 0.057 0.056];
                    app.StatusPanel.HighlightColor  = [0.747 0.404 0.393];
                case 'busy'
                    app.StatusLabel.FontColor       = [0.658 0.340 0.336];
                    app.StatusPanel.BackgroundColor = [0.078 0.078 0.078];
                    app.StatusPanel.HighlightColor  = [0.658 0.340 0.336];
                otherwise
                    app.StatusLabel.FontColor       = [0.45 0.45 0.45];
                    app.StatusPanel.BackgroundColor = [0.095 0.057 0.056];
                    app.StatusPanel.HighlightColor  = [0.45 0.45 0.45];
            end
        end

    end

    methods (Access = private)

        function createComponents(app)

            BG  = [0.106 0.106 0.106];
            PNL = [0.122 0.122 0.122];
            ACC = [0.78 0.78 0.78];
            TXT = [0.92 0.92 0.92];
            SUB = [0.60 0.60 0.60];
            W   = 1100; H = 680;

            app.UIFigure = uifigure('Visible','off');
            app.UIFigure.Position = [100 100 W H];
            app.UIFigure.Name = 'EEG Preprocessor';
            app.UIFigure.Color = BG;
            app.UIFigure.Resize = 'off';

            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [0 0 W H];

            tabNames = {'  Load Data  ','  Pre-Processing  ','  Run & Save  ', ...
                '  Wavelet Denoising  ','  Adaptive Filtering  ', ...
                '  Comparison  ','  Signal Merging  ','  Results & Summary  '};
            tabProps = {'LoadTab','PipelineTab','RunTab', ...
                'WaveletTab','AdaptiveTab','ComparisonTab','MergeTab','SummaryTab'};
            for i = 1:8
                app.(tabProps{i}) = uitab(app.TabGroup);
                app.(tabProps{i}).Title = tabNames{i};
                app.(tabProps{i}).BackgroundColor = BG;
            end
            app.VisualizeTab = uitab(app.TabGroup);
            app.VisualizeTab.Title = '';
            app.VisualizeTab.BackgroundColor = BG;
            app.TabGroup.SelectedTab = app.LoadTab;

            % ══════════════════════════════════════════════════════════════
            %  LOAD DATA TAB
            % ══════════════════════════════════════════════════════════════
            P = app.LoadTab;
            TEAL    = [0.286 0.392 0.569];
            LBLGREY = [0.45  0.45  0.45 ];
            WHITE   = [0.706 0.706 0.706];
            PLT_BG  = [0.0055 0.0055 0.0055];
            CARD_BG = [0.102 0.102 0.102];
            SEP_CLR = [0.20  0.20  0.20 ];

            SB_X = 10; SB_W = 330;

            app.InputFilePanel = uipanel(P);
            app.InputFilePanel.Position        = [SB_X 600 SB_W 42];
            app.InputFilePanel.BorderType      = 'none';
            app.InputFilePanel.BackgroundColor = CARD_BG;

            app.InputFileField = uieditfield(app.InputFilePanel, 'text');
            app.InputFileField.Position        = [6 8 200 26];
            app.InputFileField.Placeholder     = 'Select an EEG file…';
            app.InputFileField.FontSize        = 10;
            app.InputFileField.BackgroundColor = PLT_BG;
            app.InputFileField.FontColor       = WHITE;

            app.BrowseFileBtn = uibutton(app.InputFilePanel, 'push');
            app.BrowseFileBtn.Position        = [212 8 60 26];
            app.BrowseFileBtn.Text            = 'Browse';
            app.BrowseFileBtn.FontSize        = 10;
            app.BrowseFileBtn.FontColor       = WHITE;
            app.BrowseFileBtn.BackgroundColor = [0.22 0.22 0.22];
            app.BrowseFileBtn.ButtonPushedFcn = createCallbackFcn(app, @BrowseFileBtnPushed, true);

            app.RejectFileBtn = uibutton(app.InputFilePanel, 'push');
            app.RejectFileBtn.Position        = [276 8 24 26];
            app.RejectFileBtn.Text            = '✗';
            app.RejectFileBtn.FontSize        = 12; app.RejectFileBtn.FontWeight = 'bold';
            app.RejectFileBtn.FontColor       = [1 1 1];
            app.RejectFileBtn.BackgroundColor = [0.50 0.10 0.10];
            app.RejectFileBtn.ButtonPushedFcn = createCallbackFcn(app, @RejectFileBtnPushed, true);

            app.ConfirmFileBtn = uibutton(app.InputFilePanel, 'push');
            app.ConfirmFileBtn.Position        = [303 8 24 26];
            app.ConfirmFileBtn.Text            = '✓';
            app.ConfirmFileBtn.FontSize        = 12; app.ConfirmFileBtn.FontWeight = 'bold';
            app.ConfirmFileBtn.FontColor       = [1 1 1];
            app.ConfirmFileBtn.BackgroundColor = [0.08 0.42 0.18];
            app.ConfirmFileBtn.ButtonPushedFcn = createCallbackFcn(app, @LoadBtnPushed, true);

            FI_Y = 390; FI_H = 204;
            fiCard = uipanel(P);
            fiCard.Position        = [SB_X FI_Y SB_W FI_H];
            fiCard.BorderType      = 'line';
            fiCard.HighlightColor  = SEP_CLR;
            fiCard.BackgroundColor = CARD_BG;

            lbl = uilabel(fiCard);
            lbl.Position  = [14 FI_H-26 200 18];
            lbl.Text      = 'FILE INFORMATION';
            lbl.FontSize  = 10; lbl.FontWeight = 'bold';
            lbl.FontColor = TEAL;
            uilabel(fiCard,'Position',[0 FI_H-30 SB_W 1],'Text','','BackgroundColor',SEP_CLR);

            fiLabels = {'Filename','Format','Channels','Sampling Rate','Duration','Total Samples'};
            fiProps  = {'FileNameValueLabel','FileFormatValueLabel','FileChanValueLabel', ...
                'FileSRateValueLabel','FileDurValueLabel','FileSamplesValueLabel'};
            rowH = 28; startY = FI_H - 52;
            for ri = 1:6
                yy = startY - (ri-1)*rowH;
                uilabel(fiCard,'Position',[14 yy 120 20],'Text',fiLabels{ri}, ...
                    'FontSize',11,'FontColor',LBLGREY);
                app.(fiProps{ri}) = uilabel(fiCard);
                app.(fiProps{ri}).Position  = [140 yy 176 20];
                app.(fiProps{ri}).Text      = '–';
                app.(fiProps{ri}).FontSize  = 11;
                app.(fiProps{ri}).FontColor = WHITE;
                app.(fiProps{ri}).HorizontalAlignment = 'right';
                if ri < 6
                    uilabel(fiCard,'Position',[14 yy-2 SB_W-28 1],'Text','','BackgroundColor',SEP_CLR);
                end
            end

            CD_Y = 60; CD_H = FI_Y - CD_Y - 6;
            cdCard = uipanel(P);
            cdCard.Position        = [SB_X CD_Y SB_W CD_H];
            cdCard.BorderType      = 'line';
            cdCard.HighlightColor  = SEP_CLR;
            cdCard.BackgroundColor = CARD_BG;

            lbl2 = uilabel(cdCard);
            lbl2.Position  = [14 CD_H-26 200 18];
            lbl2.Text      = 'CHANNELS DETECTED';
            lbl2.FontSize  = 10; lbl2.FontWeight = 'bold';
            lbl2.FontColor = TEAL;
            uilabel(cdCard,'Position',[0 CD_H-30 SB_W 1],'Text','','BackgroundColor',SEP_CLR);

            app.FileTypeValue = uilabel(cdCard);
            app.FileTypeValue.Position  = [14 CD_H-48 SB_W-28 16];
            app.FileTypeValue.Text      = '–';
            app.FileTypeValue.FontSize  = 9;
            app.FileTypeValue.FontColor = LBLGREY;

            app.FileInfoPanel = uipanel(P);
            app.FileInfoPanel.Position  = [0 -500 10 10];
            app.FileInfoPanel.Visible   = 'off';

            RX = 352; RW = W - RX - 10;

            sigHdr = uilabel(P);
            sigHdr.Position  = [RX 620 RW 22];
            sigHdr.Text      = 'RAW EEG SIGNAL';
            sigHdr.FontSize  = 11; sigHdr.FontWeight = 'bold';
            sigHdr.FontColor = [0.286 0.392 0.569];

            app.RawEEGPanel = uipanel(P);
            app.RawEEGPanel.Position        = [RX 60 RW 558];
            app.RawEEGPanel.BorderType      = 'line';
            app.RawEEGPanel.HighlightColor  = SEP_CLR;
            app.RawEEGPanel.BackgroundColor = [0.0055 0.0055 0.0055];

            app.RawEEGAxes = uiaxes(app.RawEEGPanel);
            app.RawEEGAxes.Position   = [10 32 RW-20 506];
            app.RawEEGAxes.Color      = [0.0055 0.0055 0.0055];
            app.RawEEGAxes.XColor     = [0.35 0.35 0.35];
            app.RawEEGAxes.YColor     = [0.35 0.35 0.35];
            app.RawEEGAxes.GridColor  = [0.18 0.18 0.18];
            app.RawEEGAxes.Box        = 'off';
            app.RawEEGAxes.YTick      = [];
            title(app.RawEEGAxes, 'Load a file to preview the raw signal', 'Color', [0.286 0.392 0.569], 'FontSize', 10);
            xlabel(app.RawEEGAxes, 'Time (s)', 'Color', LBLGREY);
            ylabel(app.RawEEGAxes, '', 'Color', LBLGREY);
            disableDefaultInteractivity(app.RawEEGAxes);

            uilabel(app.RawEEGPanel, 'Position', [10 8 RW-20 18], ...
                'Text', '0s', 'FontSize', 9, 'FontColor', LBLGREY);

            app.StatusPanel = uipanel(P);
            app.StatusPanel.Position        = [SB_X 14 W-20 40];
            app.StatusPanel.BorderType      = 'line';
            app.StatusPanel.HighlightColor  = [0.747 0.404 0.393];
            app.StatusPanel.BackgroundColor = [0.095 0.057 0.056];

            app.StatusLabel = uilabel(app.StatusPanel);
            app.StatusLabel.Position  = [14 8 W-50 22];
            app.StatusLabel.Text      = 'No file loaded. Please select an EEG file to begin.';
            app.StatusLabel.FontSize  = 11;
            app.StatusLabel.FontColor = [0.45 0.45 0.45];
            app.StatusLabel.WordWrap  = 'on';

            app.ContinueBtn = uibutton(P, 'push');
            app.ContinueBtn.Position        = [W-220 14 210 40];
            app.ContinueBtn.Text            = 'PROCEED TO PREPROCESSING  →';
            app.ContinueBtn.FontSize        = 11; app.ContinueBtn.FontWeight = 'bold';
            app.ContinueBtn.FontColor       = [1 1 1];
            app.ContinueBtn.BackgroundColor = [0.169 0.302 0.816];
            app.ContinueBtn.Visible         = 'off';
            app.ContinueBtn.ButtonPushedFcn = @(~,~) set(app.TabGroup, 'SelectedTab', app.PipelineTab);

            app.LoadBtn = uibutton(P, 'push');
            app.LoadBtn.Position  = [0 -200 10 10];
            app.LoadBtn.Text      = '';
            app.LoadBtn.Visible   = 'off';
            app.LoadBtn.ButtonPushedFcn = createCallbackFcn(app, @LoadBtnPushed, true);

            % Hidden output folder controls (will be re-parented to RunTab)
            app.OutputPanel = uipanel(P);
            app.OutputPanel.Position = [0 -300 400 60];
            app.OutputPanel.Visible  = 'off';
            app.BrowseFolderBtn = uibutton(app.OutputPanel, 'push');
            app.BrowseFolderBtn.Position        = [210 5 100 26];
            app.BrowseFolderBtn.Text            = 'Browse…';
            app.BrowseFolderBtn.ButtonPushedFcn = createCallbackFcn(app, @BrowseFolderBtnPushed, true);
            app.OutputFolderField = uieditfield(app.OutputPanel, 'text');
            app.OutputFolderField.Position = [5 5 200 26];

            app.ParamsPanel = uipanel(P);
            app.ParamsPanel.Position = [0 -400 400 80];
            app.ParamsPanel.Visible  = 'off';
            app.SamplingRateField = uieditfield(app.ParamsPanel, 'numeric');
            app.SamplingRateField.Position = [5 5 120 28];
            app.SamplingRateField.Value    = 256;
            app.SamplingRateField.Limits   = [1 100000];
            app.SamplingRateLabel = uilabel(app.ParamsPanel);
            app.SamplingRateLabel.Position = [5 36 200 20];
            app.SamplingRateLabel.Text     = 'Sampling Rate (Hz)';
            app.NumChannelsLabel = uilabel(app.ParamsPanel);
            app.NumChannelsLabel.Position  = [5 58 200 20];
            app.NumChannelsLabel.Text      = 'Channels';
            app.NumChannelsValue = uilabel(app.ParamsPanel);
            app.NumChannelsValue.Position  = [5 78 300 20];
            app.NumChannelsValue.Text      = '–';

            % ══════════════════════════════════════════════════════════════
            %  PRE-PROCESSING PIPELINE TAB
            % ══════════════════════════════════════════════════════════════
             P = app.PipelineTab;

            % FIX 1: reduced font size and adjusted positions to prevent overlap
            hdr = uilabel(P);
            hdr.Position = [20 618 600 11]; hdr.Text = 'Pre-Processing Pipeline';
            hdr.FontSize = 18; hdr.FontWeight = 'bold'; hdr.FontColor = TXT;

            sub = uilabel(P);
            sub.Position = [30 570 940 20];
            sub.Text = 'Follow these three steps in order to clean your EEG data. Click any step to open it.';
            sub.FontSize = 11; sub.FontColor = SUB;

            cardW = 240; cardH = 320; cardY = 240;
            startX = 120; arrowGap = 55;
            t_demo = linspace(0, 2*pi, 200);

            % Card 1
            card1 = uipanel(P);
            card1.Position = [startX cardY cardW cardH];
            card1.BackgroundColor = [0.122 0.122 0.122]; card1.BorderType = 'line';
            badge1 = uibutton(card1, 'push'); badge1.Position = [10 272 36 36];
            badge1.Text = '1'; badge1.FontSize = 16; badge1.FontWeight = 'bold';
            badge1.FontColor = [1 1 1]; badge1.BackgroundColor = [0.25 0.25 0.25]; badge1.Enable = 'off';
            lbl1 = uilabel(card1); lbl1.Position = [54 278 175 28];
            lbl1.Text = 'Bandpass Filtering'; lbl1.FontSize = 14; lbl1.FontWeight = 'bold'; lbl1.FontColor = TXT;
            iconPanel1 = uipanel(card1); iconPanel1.Position = [10 160 220 108];
            iconPanel1.BackgroundColor = [0.08 0.11 0.16]; iconPanel1.BorderType = 'none';
            ax1 = uiaxes(iconPanel1); ax1.Position = [0 0 220 108]; ax1.Color = [0.08 0.11 0.16];
            ax1.XAxis.Visible = 'off'; ax1.YAxis.Visible = 'off'; ax1.Box = 'off';
            disableDefaultInteractivity(ax1);
            noisy = sin(t_demo) + 0.6*sin(8*t_demo) + 0.3*randn(1,200); clean_sig = sin(t_demo);
            hold(ax1,'on'); plot(ax1,t_demo,noisy,'Color',[0.45 0.45 0.45],'LineWidth',0.8);
            plot(ax1,t_demo,clean_sig,'Color',[0.20 0.45 0.75],'LineWidth',2); hold(ax1,'off');
            ax1.XLim=[0 2*pi]; ax1.YLim=[-2.5 2.5];
            desc1 = uilabel(card1); desc1.Position = [10 80 220 78];
            desc1.Text = sprintf('Remove noise outside your frequency band of interest.\n\nKeeps: delta, theta, alpha, beta.\nRemoves: drift, muscle noise, power line hum.');
            desc1.FontSize = 10; desc1.FontColor = SUB; desc1.WordWrap = 'on';
            openBtn1 = uibutton(card1, 'push'); openBtn1.Position = [10 10 220 42];
            openBtn1.Text = 'Open Filtering →'; openBtn1.FontSize = 13; openBtn1.FontWeight = 'bold';
            openBtn1.FontColor = [1 1 1]; openBtn1.BackgroundColor = [0.20 0.20 0.20];
            openBtn1.ButtonPushedFcn = @(~,~) set(app.FilterTab, 'Visible', 'on');

            arrowX1 = startX + cardW + 8; arrowMidY = cardY + cardH/2;
            arrowLbl1 = uilabel(P); arrowLbl1.Position = [arrowX1 arrowMidY-30 arrowGap 60];
            arrowLbl1.Text = '→'; arrowLbl1.FontSize = 36; arrowLbl1.FontColor = [0.75 0.75 0.75];
            arrowLbl1.HorizontalAlignment = 'center';
            thenLbl1 = uilabel(P); thenLbl1.Position = [arrowX1 arrowMidY-50 arrowGap 20];
            thenLbl1.Text = 'then'; thenLbl1.FontSize = 10; thenLbl1.FontColor = SUB;
            thenLbl1.HorizontalAlignment = 'center';

            % Card 2
            card2X = startX + cardW + arrowGap + 15;
            card2 = uipanel(P); card2.Position = [card2X cardY cardW cardH];
            card2.BackgroundColor = [0.122 0.122 0.122]; card2.BorderType = 'line';
            badge2 = uibutton(card2,'push'); badge2.Position = [10 272 36 36];
            badge2.Text='2'; badge2.FontSize=16; badge2.FontWeight='bold';
            badge2.FontColor=[1 1 1]; badge2.BackgroundColor=[0.10 0.38 0.55]; badge2.Enable='off';
            lbl2=uilabel(card2); lbl2.Position=[54 278 175 28];
            lbl2.Text='Re-referencing'; lbl2.FontSize=14; lbl2.FontWeight='bold'; lbl2.FontColor=TXT;
            iconPanel2=uipanel(card2); iconPanel2.Position=[10 160 220 108];
            iconPanel2.BackgroundColor=[0.07 0.12 0.09]; iconPanel2.BorderType='none';
            ax2=uiaxes(iconPanel2); ax2.Position=[0 0 220 108]; ax2.Color=[0.07 0.12 0.09];
            ax2.XAxis.Visible='off'; ax2.YAxis.Visible='off'; ax2.Box='off';
            disableDefaultInteractivity(ax2);
            hold(ax2,'on');
            for c=1:4; offset=(c-1)*1.2; sig=sin(t_demo+c*0.3)+offset;
                plot(ax2,t_demo,sig,'Color',[0.10 0.55 0.25],'LineWidth',1.2); end
            hold(ax2,'off'); ax2.XLim=[0 2*pi]; ax2.YLim=[-1 6];
            desc2=uilabel(card2); desc2.Position=[10 80 220 78];
            desc2.Text=sprintf('Remove bias from the recording reference electrode.\n\nOptions: average, specific channel, or linked mastoids (TP9/TP10).');
            desc2.FontSize=10; desc2.FontColor=SUB; desc2.WordWrap='on';
            openBtn2=uibutton(card2,'push'); openBtn2.Position=[10 10 220 42];
            openBtn2.Text='Open Re-reference →'; openBtn2.FontSize=13; openBtn2.FontWeight='bold';
            openBtn2.FontColor=[1 1 1]; openBtn2.BackgroundColor=[0.10 0.35 0.55];
            openBtn2.ButtonPushedFcn=@(~,~) set(app.RereferenceTab,'Visible','on');

            arrowX2 = card2X + cardW + 8;
            arrowLbl2=uilabel(P); arrowLbl2.Position=[arrowX2 arrowMidY-30 arrowGap 60];
            arrowLbl2.Text='→'; arrowLbl2.FontSize=36; arrowLbl2.FontColor=[0.75 0.75 0.75];
            arrowLbl2.HorizontalAlignment='center';
            thenLbl2=uilabel(P); thenLbl2.Position=[arrowX2 arrowMidY-50 arrowGap 20];
            thenLbl2.Text='then'; thenLbl2.FontSize=10; thenLbl2.FontColor=SUB;
            thenLbl2.HorizontalAlignment='center';

            % Card 3
            card3X = card2X + cardW + arrowGap + 15;
            card3=uipanel(P); card3.Position=[card3X cardY cardW cardH];
            card3.BackgroundColor=[0.122 0.122 0.122]; card3.BorderType='line';
            badge3=uibutton(card3,'push'); badge3.Position=[10 272 36 36];
            badge3.Text='3'; badge3.FontSize=16; badge3.FontWeight='bold';
            badge3.FontColor=[1 1 1]; badge3.BackgroundColor=[0.45 0.12 0.12]; badge3.Enable='off';
            lbl3=uilabel(card3); lbl3.Position=[54 278 175 28];
            lbl3.Text='ICA Artifact Removal'; lbl3.FontSize=14; lbl3.FontWeight='bold'; lbl3.FontColor=TXT;
            iconPanel3=uipanel(card3); iconPanel3.Position=[10 160 220 108];
            iconPanel3.BackgroundColor=[0.13 0.07 0.07]; iconPanel3.BorderType='none';
            ax3=uiaxes(iconPanel3); ax3.Position=[0 0 220 108]; ax3.Color=[0.13 0.07 0.07];
            ax3.XAxis.Visible='off'; ax3.YAxis.Visible='off'; ax3.Box='off';
            disableDefaultInteractivity(ax3);
            hold(ax3,'on');
            blink=zeros(1,200); blink(80:100)=60*exp(-0.5*((80:100)-90).^2/20);
            raw3=sin(t_demo)+blink; clean3=sin(t_demo);
            plot(ax3,t_demo,raw3,'Color',[0.75 0.20 0.20],'LineWidth',1.0);
            plot(ax3,t_demo,clean3,'Color',[0.10 0.10 0.10],'LineWidth',1.5);
            hold(ax3,'off'); ax3.XLim=[0 2*pi]; ax3.YLim=[-5 65];
            desc3=uilabel(card3); desc3.Position=[10 80 220 78];
            desc3.Text=sprintf('Separate and remove artifact sources.\n\nRemoves: eye blinks, eye movement, heartbeat, muscle noise.');
            desc3.FontSize=10; desc3.FontColor=SUB; desc3.WordWrap='on';
            openBtn3=uibutton(card3,'push'); openBtn3.Position=[10 10 220 42];
            openBtn3.Text='Open ICA →'; openBtn3.FontSize=13; openBtn3.FontWeight='bold';
            openBtn3.FontColor=[1 1 1]; openBtn3.BackgroundColor=[0.45 0.12 0.12];
            openBtn3.ButtonPushedFcn=@(~,~) set(app.ICATab,'Visible','on');

            tipCard=uipanel(P); tipCard.Position=[120 120 920 55];
            tipCard.BackgroundColor=[0.13 0.13 0.13]; tipCard.BorderType='none';
            tipBadge=uibutton(tipCard,'push'); tipBadge.Position=[10 12 36 30];
            tipBadge.Text='💡'; tipBadge.FontSize=14; tipBadge.BackgroundColor=[0.13 0.13 0.13]; tipBadge.Enable='off';
            tipLbl=uilabel(tipCard); tipLbl.Position=[55 8 840 36];
            tipLbl.Text='Recommended order: Filtering first, then Re-reference, then ICA. Each step improves the quality of the next.';
            tipLbl.FontSize=11; tipLbl.FontColor=SUB; tipLbl.WordWrap='on';

            % ══════════════════════════════════════════════════════════════
            %  FILTERING OVERLAY PANEL
            % ══════════════════════════════════════════════════════════════
            app.FilterTab = uipanel(app.PipelineTab);
            app.FilterTab.Position = [0 0 W 652]; app.FilterTab.BackgroundColor = BG;
            app.FilterTab.BorderType = 'none'; app.FilterTab.Visible = 'off';
            P = app.FilterTab;

            backBtn1=uibutton(P,'push'); backBtn1.Position=[30 610 160 30];
            backBtn1.Text='← Back to Pipeline'; backBtn1.FontSize=11; backBtn1.FontWeight='bold';
            backBtn1.FontColor=[1 1 1]; backBtn1.BackgroundColor=[0.22 0.22 0.22];
            backBtn1.ButtonPushedFcn=@(~,~) set(app.FilterTab,'Visible','off');

            hdr=uilabel(P); hdr.Position=[205 608 400 30]; hdr.Text='Bandpass Filtering';
            hdr.FontSize=20; hdr.FontWeight='bold'; hdr.FontColor=TXT;
            sub=uilabel(P); sub.Position=[30 585 900 20];
            sub.Text='Set low and high cutoff frequencies. Optionally apply a notch filter to remove power line noise.';
            sub.FontSize=12; sub.FontColor=SUB;

            presetCard=uipanel(P); presetCard.Position=[30 528 1040 52];
            presetCard.BackgroundColor=BG; presetCard.BorderType='line';
            presetCard.HighlightColor=[0.45 0.45 0.45];
            presetBadge=uibutton(presetCard,'push'); presetBadge.Position=[10 11 52 28];
            presetBadge.Text='PRESET'; presetBadge.FontSize=8; presetBadge.FontWeight='bold';
            presetBadge.FontColor=[1 1 1]; presetBadge.BackgroundColor=[0.10 0.38 0.55]; presetBadge.Enable='off';
            app.PresetDropdown=uidropdown(presetCard); app.PresetDropdown.Position=[72 11 820 28];
            app.PresetDropdown.FontSize=12;
            app.PresetDropdown.Items={'Select a preset to auto-fill settings below…',...
                'General EEG  (1–40 Hz)  –  good starting point for most recordings',...
                'Sleep Analysis  (0.5–35 Hz)  –  preserves slow sleep waves',...
                'Motor Imagery / BCI  (8–30 Hz)  –  alpha and beta bands only',...
                'Emotion / Cognitive  (4–45 Hz)  –  theta through gamma',...
                'Epilepsy Screening  (0.5–70 Hz)  –  wide band, keeps spike activity',...
                'Research / Custom  –  set your own values below'};
            app.PresetDropdown.BackgroundColor=[0.08 0.08 0.08];
            app.PresetDropdown.FontColor=[0.9 0.9 0.9];
            app.PresetDropdown.ValueChangedFcn=createCallbackFcn(app,@PresetChanged,true);

            settingsCard=uipanel(P); settingsCard.Position=[30 443 1040 78];
            settingsCard.BackgroundColor=BG; settingsCard.BorderType='line';
            settingsCard.HighlightColor=[0.45 0.45 0.45];
            settingsBadge=uibutton(settingsCard,'push'); settingsBadge.Position=[10 24 52 28];
            settingsBadge.Text='FILTER'; settingsBadge.FontSize=8; settingsBadge.FontWeight='bold';
            settingsBadge.FontColor=[1 1 1]; settingsBadge.BackgroundColor=[0.25 0.25 0.25]; settingsBadge.Enable='off';
            uilabel(settingsCard,'Position',[72 48 120 18],'Text','Low cutoff (Hz)','FontColor',SUB,'FontSize',11);
            app.FiltLowCutField=uieditfield(settingsCard,'numeric');
            app.FiltLowCutField.Position=[72 22 90 26]; app.FiltLowCutField.Value=1;
            app.FiltLowCutField.Limits=[0 1000]; app.FiltLowCutField.FontSize=13;
            app.FiltLowCutField.BackgroundColor=[0.08 0.08 0.08]; app.FiltLowCutField.FontColor=[0.9 0.9 0.9];
            uilabel(settingsCard,'Position',[178 48 120 18],'Text','High cutoff (Hz)','FontColor',SUB,'FontSize',11);
            app.FiltHighCutField=uieditfield(settingsCard,'numeric');
            app.FiltHighCutField.Position=[178 22 90 26]; app.FiltHighCutField.Value=40;
            app.FiltHighCutField.Limits=[0 10000]; app.FiltHighCutField.FontSize=13;
            app.FiltHighCutField.BackgroundColor=[0.08 0.08 0.08]; app.FiltHighCutField.FontColor=[0.9 0.9 0.9];
            app.FiltNotchCheck=uicheckbox(settingsCard);
            app.FiltNotchCheck.Position=[296 26 130 22]; app.FiltNotchCheck.Text='Notch filter';
            app.FiltNotchCheck.FontSize=12; app.FiltNotchCheck.Value=true; app.FiltNotchCheck.FontColor=[0.85 0.85 0.85];
            uilabel(settingsCard,'Position',[432 48 130 18],'Text','Notch frequency (Hz)','FontColor',SUB,'FontSize',11);
            app.FiltNotchFreqField=uieditfield(settingsCard,'numeric');
            app.FiltNotchFreqField.Position=[432 22 70 26]; app.FiltNotchFreqField.Value=50;
            app.FiltNotchFreqField.Limits=[0 1000]; app.FiltNotchFreqField.FontSize=13;
            app.FiltNotchFreqField.BackgroundColor=[0.08 0.08 0.08]; app.FiltNotchFreqField.FontColor=[0.9 0.9 0.9];
            app.FiltApplyBtn=uibutton(settingsCard,'push'); app.FiltApplyBtn.Position=[800 16 104 36];
            app.FiltApplyBtn.Text='Apply Filter'; app.FiltApplyBtn.FontSize=13; app.FiltApplyBtn.FontWeight='bold';
            app.FiltApplyBtn.FontColor=[1 1 1]; app.FiltApplyBtn.BackgroundColor=[0.20 0.20 0.20];
            app.FiltApplyBtn.ButtonPushedFcn=createCallbackFcn(app,@FiltApplyBtnPushed,true);

            resultsCard=uipanel(P); resultsCard.Position=[30 388 1040 48];
            resultsCard.BackgroundColor=BG; resultsCard.BorderType='line';
            resultsCard.HighlightColor=[0.45 0.45 0.45];
            resultsBadge=uibutton(resultsCard,'push'); resultsBadge.Position=[10 9 68 28];
            resultsBadge.Text='RESULTS'; resultsBadge.FontSize=8; resultsBadge.FontWeight='bold';
            resultsBadge.FontColor=[1 1 1]; resultsBadge.BackgroundColor=[0.10 0.55 0.25]; resultsBadge.Enable='off';
            app.FiltStatusLabel=uilabel(resultsCard); app.FiltStatusLabel.Position=[88 8 820 30];
            app.FiltStatusLabel.Text='Apply a filter above to see results here.';
            app.FiltStatusLabel.FontSize=12; app.FiltStatusLabel.FontColor=SUB; app.FiltStatusLabel.WordWrap='on';

            beforeCard=uipanel(P); beforeCard.Position=[30 68 510 315];
            beforeCard.BackgroundColor=[0.078 0.078 0.078];
            app.FiltAxesBefore=uiaxes(beforeCard); app.FiltAxesBefore.Position=[0 0 510 315];
            app.FiltAxesBefore.Color=[0.078 0.078 0.078];
            app.FiltAxesBefore.XColor=[0.75 0.75 0.75]; app.FiltAxesBefore.YColor=[0.75 0.75 0.75];
            xlabel(app.FiltAxesBefore,'Time (s)'); ylabel(app.FiltAxesBefore,'Amplitude (µV)');
            beforeBadge=uibutton(beforeCard,'push'); beforeBadge.Position=[8 280 60 26];
            beforeBadge.Text='BEFORE'; beforeBadge.FontSize=8; beforeBadge.FontWeight='bold';
            beforeBadge.FontColor=[1 1 1]; beforeBadge.BackgroundColor=[0.20 0.45 0.75]; beforeBadge.Enable='off';

            afterCard=uipanel(P); afterCard.Position=[555 68 510 315];
            afterCard.BackgroundColor=[0.078 0.078 0.078];
            app.FiltAxesAfter=uiaxes(afterCard); app.FiltAxesAfter.Position=[0 0 510 315];
            app.FiltAxesAfter.Color=[0.078 0.078 0.078];
            app.FiltAxesAfter.XColor=[0.75 0.75 0.75]; app.FiltAxesAfter.YColor=[0.75 0.75 0.75];
            xlabel(app.FiltAxesAfter,'Time (s)'); ylabel(app.FiltAxesAfter,'Amplitude (µV)');
            afterBadge=uibutton(afterCard,'push'); afterBadge.Position=[8 280 60 26];
            afterBadge.Text='AFTER'; afterBadge.FontSize=8; afterBadge.FontWeight='bold';
            afterBadge.FontColor=[1 1 1]; afterBadge.BackgroundColor=[0.10 0.55 0.25]; afterBadge.Enable='off';

            statsRow=uipanel(P); statsRow.Position=[30 20 820 40];
            statsRow.BackgroundColor=[0.078 0.078 0.078]; statsRow.BorderType='line';
            app.FiltRMSLabel=uilabel(statsRow); app.FiltRMSLabel.Position=[15 8 200 22];
            app.FiltRMSLabel.Text='RMS: –'; app.FiltRMSLabel.FontSize=11; app.FiltRMSLabel.FontColor=SUB;
            app.FiltPowerLabel=uilabel(statsRow); app.FiltPowerLabel.Position=[200 8 220 22];
            app.FiltPowerLabel.Text='Power: –'; app.FiltPowerLabel.FontSize=11; app.FiltPowerLabel.FontColor=SUB;
            app.FiltSNRLabel=uilabel(statsRow); app.FiltSNRLabel.Position=[400 8 200 22];
            app.FiltSNRLabel.Text='SNR: –'; app.FiltSNRLabel.FontSize=11; app.FiltSNRLabel.FontColor=SUB;
            uilabel(statsRow,'Position',[610 8 90 22],'Text','Show channel:','FontColor',SUB,'FontSize',11);
            app.FiltChanSpinner=uispinner(statsRow); app.FiltChanSpinner.Position=[705 6 60 26];
            app.FiltChanSpinner.Value=1; app.FiltChanSpinner.Limits=[1 Inf];
            app.FiltChanSpinner.Step=1; app.FiltChanSpinner.FontSize=11;
            app.FiltChanSpinner.ValueChangedFcn=createCallbackFcn(app,@FiltChanChanged,true);
            app.FiltChanLabel=uilabel(statsRow); app.FiltChanLabel.Position=[770 8 100 22];
            app.FiltChanLabel.Text='/ – ch'; app.FiltChanLabel.FontSize=11; app.FiltChanLabel.FontColor=SUB;

            app.RerefNextBtn=uibutton(P,'push'); app.RerefNextBtn.Position=[860 20 200 40];
            app.RerefNextBtn.Text='Re-referencing →'; app.RerefNextBtn.FontSize=12; app.RerefNextBtn.FontWeight='bold';
            app.RerefNextBtn.FontColor=[1 1 1]; app.RerefNextBtn.BackgroundColor=[0.08 0.36 0.52];
            app.RerefNextBtn.Visible='off';
            app.RerefNextBtn.ButtonPushedFcn=@(~,~) set(app.RereferenceTab,'Visible','on');

            % ══════════════════════════════════════════════════════════════
            %  RE-REFERENCE OVERLAY PANEL
            % ══════════════════════════════════════════════════════════════
            app.RereferenceTab=uipanel(app.PipelineTab);
            app.RereferenceTab.Position=[0 0 W 652]; app.RereferenceTab.BackgroundColor=BG;
            app.RereferenceTab.BorderType='none'; app.RereferenceTab.Visible='off';
            P=app.RereferenceTab;

            backBtn2=uibutton(P,'push'); backBtn2.Position=[30 610 160 30];
            backBtn2.Text='← Back to Pipeline'; backBtn2.FontSize=11; backBtn2.FontWeight='bold';
            backBtn2.FontColor=[1 1 1]; backBtn2.BackgroundColor=[0.22 0.22 0.22];
            backBtn2.ButtonPushedFcn=@(~,~) set(app.RereferenceTab,'Visible','off');

            hdr=uilabel(P); hdr.Position=[205 608 500 30]; hdr.Text='Re-referencing';
            hdr.FontSize=20; hdr.FontWeight='bold'; hdr.FontColor=TXT;
            sub=uilabel(P); sub.Position=[30 585 900 20];
            sub.Text='Choose a reference scheme and apply it to the EEG data.';
            sub.FontSize=12; sub.FontColor=SUB;

            settingsCard2=uipanel(P); settingsCard2.Position=[30 515 1040 62];
            settingsCard2.BackgroundColor=[0.078 0.078 0.078]; settingsCard2.BorderType='line';
            rerefBadge=uibutton(settingsCard2,'push'); rerefBadge.Position=[10 16 52 28];
            rerefBadge.Text='REF'; rerefBadge.FontSize=9; rerefBadge.FontWeight='bold';
            rerefBadge.FontColor=[1 1 1]; rerefBadge.BackgroundColor=[0.25 0.25 0.25]; rerefBadge.Enable='off';
            uilabel(settingsCard2,'Position',[72 40 160 18],'Text','Reference type','FontColor',[0.85 0.85 0.85],'FontSize',11);
            app.RerefTypeDropdown=uidropdown(settingsCard2); app.RerefTypeDropdown.Position=[72 14 260 26];
            app.RerefTypeDropdown.Items={'Average reference','Specific channel(s)','Linked mastoids (TP9/TP10)'};
            app.RerefTypeDropdown.FontSize=12; app.RerefTypeDropdown.FontColor=[0.9 0.9 0.9];
            app.RerefTypeDropdown.BackgroundColor=[0.18 0.18 0.18];
            app.RerefTypeDropdown.ValueChangedFcn=createCallbackFcn(app,@RerefTypeChanged,true);
            uilabel(settingsCard2,'Position',[360 40 260 18],'Text','Channel number(s) – if specific channel selected','FontColor',[0.85 0.85 0.85],'FontSize',11);
            app.RerefChanField=uieditfield(settingsCard2,'text'); app.RerefChanField.Position=[360 14 180 26];
            app.RerefChanField.Placeholder='e.g. 1 2'; app.RerefChanField.FontSize=12;
            app.RerefChanField.FontColor=[0.9 0.9 0.9]; app.RerefChanField.BackgroundColor=[0.18 0.18 0.18];
            app.RerefChanField.Enable='off';
            app.RerefApplyBtn=uibutton(settingsCard2,'push'); app.RerefApplyBtn.Position=[920 12 104 36];
            app.RerefApplyBtn.Text='Apply Ref'; app.RerefApplyBtn.FontSize=13; app.RerefApplyBtn.FontWeight='bold';
            app.RerefApplyBtn.FontColor=[1 1 1]; app.RerefApplyBtn.BackgroundColor=[0.20 0.20 0.20];
            app.RerefApplyBtn.ButtonPushedFcn=createCallbackFcn(app,@RerefApplyBtnPushed,true);

            resultsCard2=uipanel(P); resultsCard2.Position=[30 466 1040 42];
            resultsCard2.BackgroundColor=[0.10 0.10 0.10]; resultsCard2.BorderType='line';
            resultsBadge2=uibutton(resultsCard2,'push'); resultsBadge2.Position=[10 7 68 26];
            resultsBadge2.Text='RESULTS'; resultsBadge2.FontSize=8; resultsBadge2.FontWeight='bold';
            resultsBadge2.FontColor=[1 1 1]; resultsBadge2.BackgroundColor=[0.10 0.55 0.25]; resultsBadge2.Enable='off';
            app.RerefStatusLabel=uilabel(resultsCard2); app.RerefStatusLabel.Position=[88 6 820 28];
            app.RerefStatusLabel.Text='Apply a reference above to see results here.';
            app.RerefStatusLabel.FontSize=12; app.RerefStatusLabel.FontColor=SUB; app.RerefStatusLabel.WordWrap='on';

            beforeCard2=uipanel(P); beforeCard2.Position=[30 212 445 248];
            beforeCard2.BackgroundColor=[0.078 0.078 0.078]; beforeCard2.BorderType='line';
            beforeBadge2=uibutton(beforeCard2,'push'); beforeBadge2.Position=[10 208 60 26];
            beforeBadge2.Text='BEFORE'; beforeBadge2.FontSize=8; beforeBadge2.FontWeight='bold';
            beforeBadge2.FontColor=[1 1 1]; beforeBadge2.BackgroundColor=[0.20 0.45 0.75]; beforeBadge2.Enable='off';
            app.RerefAxesBefore=uiaxes(beforeCard2); app.RerefAxesBefore.Position=[5 5 432 200];
            app.RerefAxesBefore.Color=[0.078 0.078 0.078];
            xlabel(app.RerefAxesBefore,'Time (s)'); ylabel(app.RerefAxesBefore,'Amplitude (µV)');

            afterCard2=uipanel(P); afterCard2.Position=[505 212 445 248];
            afterCard2.BackgroundColor=[0.078 0.078 0.078]; afterCard2.BorderType='line';
            afterBadge2=uibutton(afterCard2,'push'); afterBadge2.Position=[10 208 60 26];
            afterBadge2.Text='AFTER'; afterBadge2.FontSize=8; afterBadge2.FontWeight='bold';
            afterBadge2.FontColor=[1 1 1]; afterBadge2.BackgroundColor=[0.10 0.55 0.25]; afterBadge2.Enable='off';
            app.RerefAxesAfter=uiaxes(afterCard2); app.RerefAxesAfter.Position=[5 5 432 200];
            app.RerefAxesAfter.Color=[0.078 0.078 0.078];
            xlabel(app.RerefAxesAfter,'Time (s)'); ylabel(app.RerefAxesAfter,'Amplitude (µV)');

            statsRow2=uipanel(P); statsRow2.Position=[30 168 920 38];
            statsRow2.BackgroundColor=[0.078 0.078 0.078]; statsRow2.BorderType='line';
            app.RerefRMSLabel=uilabel(statsRow2); app.RerefRMSLabel.Position=[15 7 230 22];
            app.RerefRMSLabel.Text='RMS: –'; app.RerefRMSLabel.FontSize=11; app.RerefRMSLabel.FontColor=SUB;
            app.RerefSNRLabel=uilabel(statsRow2); app.RerefSNRLabel.Position=[260 7 220 22];
            app.RerefSNRLabel.Text='SNR change: –'; app.RerefSNRLabel.FontSize=11; app.RerefSNRLabel.FontColor=SUB;
            app.RerefCorrLabel=uilabel(statsRow2); app.RerefCorrLabel.Position=[495 7 230 22];
            app.RerefCorrLabel.Text='Correlation with original: –'; app.RerefCorrLabel.FontSize=11; app.RerefCorrLabel.FontColor=SUB;
            uilabel(statsRow2,'Position',[700 7 90 22],'Text','Show channel:','FontColor',SUB,'FontSize',11);
            app.RerefChanSpinner=uispinner(statsRow2); app.RerefChanSpinner.Position=[795 5 60 26];
            app.RerefChanSpinner.Value=1; app.RerefChanSpinner.Limits=[1 Inf];
            app.RerefChanSpinner.Step=1; app.RerefChanSpinner.FontSize=11;
            app.RerefChanSpinner.ValueChangedFcn=createCallbackFcn(app,@RerefChanChanged,true);
            app.RerefChanLabel=uilabel(statsRow2); app.RerefChanLabel.Position=[860 7 55 22];
            app.RerefChanLabel.Text='/ – ch'; app.RerefChanLabel.FontSize=11; app.RerefChanLabel.FontColor=SUB;

            app.RerefICANextBtn=uibutton(P,'push'); app.RerefICANextBtn.Position=[730 128 220 32];
            app.RerefICANextBtn.Text='ICA Artifact Removal →'; app.RerefICANextBtn.FontSize=12; app.RerefICANextBtn.FontWeight='bold';
            app.RerefICANextBtn.FontColor=[1 1 1]; app.RerefICANextBtn.BackgroundColor=[0.08 0.32 0.50];
            app.RerefICANextBtn.Visible='off';
            app.RerefICANextBtn.ButtonPushedFcn=@(~,~) set(app.ICATab,'Visible','on');

            % ══════════════════════════════════════════════════════════════
            %  ICA OVERLAY PANEL
            % ══════════════════════════════════════════════════════════════
            app.ICATab=uipanel(app.PipelineTab);
            app.ICATab.Position=[0 0 W 652]; app.ICATab.BackgroundColor=BG;
            app.ICATab.BorderType='none'; app.ICATab.Visible='off';
            P=app.ICATab;

            backBtn3=uibutton(P,'push'); backBtn3.Position=[30 610 160 30];
            backBtn3.Text='← Back to Pipeline'; backBtn3.FontSize=11; backBtn3.FontWeight='bold';
            backBtn3.FontColor=[1 1 1]; backBtn3.BackgroundColor=[0.22 0.22 0.22];
            backBtn3.ButtonPushedFcn=@(~,~) set(app.ICATab,'Visible','off');

            hdr=uilabel(P); hdr.Position=[205 620 600 26]; hdr.Text='ICA Artifact Removal';
            hdr.FontSize=18; hdr.FontWeight='bold'; hdr.FontColor=TXT;
            sub=uilabel(P); sub.Position=[30 598 900 18];
            sub.Text='Run ICA decomposition, inspect the inline component topoplots, then remove artifact components by number.';
            sub.FontSize=11; sub.FontColor=SUB;

            step1Card=uipanel(P); step1Card.Position=[30 545 920 48];
            step1Card.BackgroundColor=[0.078 0.078 0.078]; step1Card.BorderType='line';
            app.ICARunBtn=uibutton(step1Card,'push'); app.ICARunBtn.Position=[30 4 120 30];
            app.ICARunBtn.Text='Run ICA'; app.ICARunBtn.FontSize=12; app.ICARunBtn.FontWeight='bold';
            app.ICARunBtn.FontColor=[1 1 1]; app.ICARunBtn.BackgroundColor=[0.20 0.20 0.20];
            app.ICARunBtn.ButtonPushedFcn=createCallbackFcn(app,@ICARunBtnPushed,true);
            uilabel(step1Card,'Position',[202 10 700 18],...
                'Text','Decomposes signal into independent components (runica – extended infomax). Topoplots appear below.',...
                'FontColor',SUB,'FontSize',10);

            resultsCardICA=uipanel(P); resultsCardICA.Position=[30 510 920 30];
            resultsCardICA.BackgroundColor=[0.10 0.10 0.10]; resultsCardICA.BorderType='line';
            resultsBadgeICA=uibutton(resultsCardICA,'push'); resultsBadgeICA.Position=[10 3 68 22];
            resultsBadgeICA.Text='RESULTS'; resultsBadgeICA.FontSize=8; resultsBadgeICA.FontWeight='bold';
            resultsBadgeICA.FontColor=[1 1 1]; resultsBadgeICA.BackgroundColor=[0.10 0.55 0.25]; resultsBadgeICA.Enable='off';
            app.ICAStatusLabel=uilabel(resultsCardICA); app.ICAStatusLabel.Position=[88 2 820 24];
            app.ICAStatusLabel.Text='Run ICA above to see results here.';
            app.ICAStatusLabel.FontSize=11; app.ICAStatusLabel.FontColor=SUB; app.ICAStatusLabel.WordWrap='on';

            app.ICATopoPanel=uipanel(P); app.ICATopoPanel.Position=[30 155 920 350];
            app.ICATopoPanel.BackgroundColor=[0.078 0.078 0.078]; app.ICATopoPanel.BorderType='line';
            app.ICATopoPanel.Title='  Component Topoplots  (populated after Run ICA)';
            app.ICATopoPanel.FontSize=11; app.ICATopoPanel.FontWeight='bold';
            app.ICATopoPanel.ForegroundColor=[0.784 0.784 0.784];
            topoPlaceholder=uilabel(app.ICATopoPanel); topoPlaceholder.Position=[0 160 920 40];
            topoPlaceholder.Text='Topoplots will appear here after Run ICA completes.';
            topoPlaceholder.FontSize=12; topoPlaceholder.FontColor=SUB; topoPlaceholder.HorizontalAlignment='center';

            step2Card=uipanel(P); step2Card.Position=[30 108 920 42];
            step2Card.BackgroundColor=[0.078 0.078 0.078]; step2Card.BorderType='line';
            step2Badge=uibutton(step2Card,'push'); step2Badge.Position=[10 7 52 26];
            step2Badge.Text='STEP 2'; step2Badge.FontSize=8; step2Badge.FontWeight='bold';
            step2Badge.FontColor=[1 1 1]; step2Badge.BackgroundColor=[0.45 0.12 0.12]; step2Badge.Enable='off';
            uilabel(step2Card,'Position',[72 24 190 16],'Text','Components to remove:','FontColor',SUB,'FontSize',10);
            app.ICARejectField=uieditfield(step2Card,'text'); app.ICARejectField.Position=[72 4 160 22];
            app.ICARejectField.Placeholder='e.g. 1 3 5'; app.ICARejectField.FontSize=11;
            app.ICARejectField.BackgroundColor=[0.145 0.145 0.145];
            compHelpBtn=uibutton(step2Card,'push'); compHelpBtn.Position=[242 4 90 22];
            compHelpBtn.Text='Components?'; compHelpBtn.FontSize=9; compHelpBtn.FontWeight='bold';
            compHelpBtn.FontColor=[0.45 0.75 0.95]; compHelpBtn.BackgroundColor=[0.08 0.18 0.26];
            compHelpBtn.ButtonPushedFcn=@(~,~) uialert(app.UIFigure,...
                sprintf(['How to identify artifact components from topoplots:\n\n'...
                '👁  Eye Blinks: High activity at front, near eyes.\n\n'...
                '↔  Lateral Eye Movements: Blobs on far left/right frontal edges.\n\n'...
                '⚡  Muscle Activity: Localised near temples or neck.\n\n'...
                '🧠  Neural Sources (keep): Smooth, broader gradients over central/occipital regions.']),...
                'Component Guide','Icon','info');
            app.ICARejectBtn=uibutton(step2Card,'push'); app.ICARejectBtn.Position=[344 4 180 22];
            app.ICARejectBtn.Text='Remove Components'; app.ICARejectBtn.FontSize=10; app.ICARejectBtn.FontWeight='bold';
            app.ICARejectBtn.FontColor=[1 1 1]; app.ICARejectBtn.BackgroundColor=[0.45 0.12 0.12];
            app.ICARejectBtn.ButtonPushedFcn=createCallbackFcn(app,@ICARejectBtnPushed,true);
            uilabel(step2Card,'Position',[540 24 90 16],'Text','Show channel:','FontColor',SUB,'FontSize',10);
            app.ICAChanSpinner=uispinner(step2Card); app.ICAChanSpinner.Position=[540 4 60 22];
            app.ICAChanSpinner.Value=1; app.ICAChanSpinner.Limits=[1 Inf];
            app.ICAChanSpinner.Step=1; app.ICAChanSpinner.FontSize=10;
            app.ICAChanSpinner.ValueChangedFcn=createCallbackFcn(app,@ICAChanChanged,true);
            app.ICAChanLabel=uilabel(step2Card); app.ICAChanLabel.Position=[604 4 80 22];
            app.ICAChanLabel.Text='/ – ch'; app.ICAChanLabel.FontSize=10; app.ICAChanLabel.FontColor=SUB;
            app.ICAGuideDropdown=uidropdown(step2Card); app.ICAGuideDropdown.Position=[700 -40 180 22];
            app.ICAGuideDropdown.Items={'n/a'}; app.ICAGuideDropdown.Visible='off';

            app.ICAOverlayPanel=uipanel(P); app.ICAOverlayPanel.Position=[30 20 920 82];
            app.ICAOverlayPanel.BackgroundColor=[0.078 0.078 0.078]; app.ICAOverlayPanel.BorderType='line';
            app.ICAOverlayPanel.Title='  Artifact Overlay'; app.ICAOverlayPanel.FontSize=10; app.ICAOverlayPanel.FontWeight='bold';
            app.ICAOverlayPanel.ForegroundColor=[0.90 0.35 0.35]; app.ICAOverlayPanel.Visible='off';
            app.ICAOverlayAxes=uiaxes(app.ICAOverlayPanel); app.ICAOverlayAxes.Position=[5 4 906 56];
            app.ICAOverlayAxes.Color=[0.078 0.078 0.078];
            app.ICAOverlayAxes.XAxis.FontSize=8; app.ICAOverlayAxes.YAxis.FontSize=8;
            app.ICAOverlayAxes.XColor=[0.55 0.55 0.55]; app.ICAOverlayAxes.YColor=[0.55 0.55 0.55];
            disableDefaultInteractivity(app.ICAOverlayAxes);

            app.ICAAxesBefore=uiaxes(P); app.ICAAxesBefore.Position=[0 -200 1 1]; app.ICAAxesBefore.Visible='off';
            app.ICAAxesAfter=uiaxes(P);  app.ICAAxesAfter.Position=[0 -200 1 1];  app.ICAAxesAfter.Visible='off';

            app.ICAVizBtn=uibutton(P,'push'); app.ICAVizBtn.Position=[375 610 250 24];
            app.ICAVizBtn.Text='Visualise Pre-Processing'; app.ICAVizBtn.FontSize=11; app.ICAVizBtn.FontWeight='bold';
            app.ICAVizBtn.FontColor=[1 1 1]; app.ICAVizBtn.BackgroundColor=[0.08 0.32 0.55];
            app.ICAVizBtn.Visible='off';
            app.ICAVizBtn.ButtonPushedFcn=createCallbackFcn(app,@VizPlotBtnPushed,true);
            % ══════════════════════════════════════════════════════════════
            %  VISUALIZE TAB (hidden placeholder)
            % ══════════════════════════════════════════════════════════════
            P=app.VisualizeTab;
            hdr=uilabel(P); hdr.Position=[30 610 400 30]; hdr.Text='Visualize EEG';
            hdr.FontSize=20; hdr.FontWeight='bold'; hdr.FontColor=TXT;
            app.VizPanel=uipanel(P); app.VizPanel.Position=[30 380 920 200]; app.VizPanel.Title='  Plot Options';
            app.VizPanel.FontSize=12; app.VizPanel.FontWeight='bold';
            app.VizPanel.ForegroundColor=[0.784 0.784 0.784]; app.VizPanel.BackgroundColor=[0.078 0.078 0.078];
            app.VizPlotBtn=uibutton(app.VizPanel,'push'); app.VizPlotBtn.Position=[15 108 200 34];
            app.VizPlotBtn.Text='Plot EEG Signal'; app.VizPlotBtn.FontSize=13; app.VizPlotBtn.FontWeight='bold';
            app.VizPlotBtn.FontColor=[1 1 1]; app.VizPlotBtn.BackgroundColor=[0.20 0.20 0.20];
            app.VizPlotBtn.ButtonPushedFcn=createCallbackFcn(app,@VizPlotBtnPushed,true);
            app.VizSpecBtn=uibutton(app.VizPanel,'push'); app.VizSpecBtn.Position=[15 34 200 34];
            app.VizSpecBtn.Text='Plot Power Spectrum'; app.VizSpecBtn.FontSize=13; app.VizSpecBtn.FontWeight='bold';
            app.VizSpecBtn.FontColor=[1 1 1]; app.VizSpecBtn.BackgroundColor=[0.10 0.28 0.45];
            app.VizSpecBtn.ButtonPushedFcn=createCallbackFcn(app,@VizSpecBtnPushed,true);
            app.VizStatusLabel=uilabel(P); app.VizStatusLabel.Position=[30 340 880 30];
            app.VizStatusLabel.Text='Ready.'; app.VizStatusLabel.FontSize=12; app.VizStatusLabel.FontColor=SUB;

            % ══════════════════════════════════════════════════════════════
            %  RUN & SAVE TAB  —  FIX 2: output folder now visible here
            % ══════════════════════════════════════════════════════════════
            P=app.RunTab;
            hdr=uilabel(P); hdr.Position=[30 610 400 30]; hdr.Text='Run Pipeline & Save';
            hdr.FontSize=20; hdr.FontWeight='bold'; hdr.FontColor=TXT;
            sub=uilabel(P); sub.Position=[30 590 800 20];
            sub.Text='Select which steps to run, choose an output folder, then export the processed dataset.';
            sub.FontSize=12; sub.FontColor=SUB;

            app.RunPanel=uipanel(P); app.RunPanel.Position=[30 390 920 190]; app.RunPanel.Title='  Pipeline Steps';
            app.RunPanel.FontSize=12; app.RunPanel.FontWeight='bold';
            app.RunPanel.ForegroundColor=[0.784 0.784 0.784]; app.RunPanel.BackgroundColor=[0.078 0.078 0.078];
            uilabel(app.RunPanel,'Position',[15 148 700 22],'Text','Select steps to include (uses settings from each tab):','FontColor',SUB,'FontSize',12);
            app.RunFilterCheck=uicheckbox(app.RunPanel); app.RunFilterCheck.Position=[15 114 300 24]; app.RunFilterCheck.Value=true;
            app.RunFilterCheck.Text='Bandpass filter (settings from Filtering tab)'; app.RunFilterCheck.FontSize=12; app.RunFilterCheck.FontColor=[0.85 0.85 0.85];
            app.RunRerefCheck=uicheckbox(app.RunPanel); app.RunRerefCheck.Position=[15 82 300 24]; app.RunRerefCheck.Value=true;
            app.RunRerefCheck.Text='Re-reference (average reference)'; app.RunRerefCheck.FontSize=12; app.RunRerefCheck.FontColor=[0.85 0.85 0.85];
            app.RunICACheck=uicheckbox(app.RunPanel); app.RunICACheck.Position=[15 50 300 24]; app.RunICACheck.Value=false;
            app.RunICACheck.Text='Run ICA (slow – uncheck for quick runs)'; app.RunICACheck.FontSize=12; app.RunICACheck.FontColor=[0.85 0.85 0.85];

            % Output folder row — visible, in the Run tab
            uilabel(P,'Position',[30 368 200 22],'Text','Output folder:','FontColor',SUB,'FontSize',12);
            app.OutputFolderField.Parent = P;
            app.OutputFolderField.Position = [30 340 560 28];
            app.OutputFolderField.Placeholder = 'Select a folder to save results…';
            app.OutputFolderField.FontSize = 11;
            app.OutputFolderField.BackgroundColor = [0.08 0.08 0.08];
            app.OutputFolderField.FontColor = [0.9 0.9 0.9];
            app.OutputFolderField.Visible = 'on';
            app.BrowseFolderBtn.Parent = P;
            app.BrowseFolderBtn.Position = [600 340 140 28];
            app.BrowseFolderBtn.Text = 'Browse Folder…';
            app.BrowseFolderBtn.FontSize = 11;
            app.BrowseFolderBtn.FontColor = [1 1 1];
            app.BrowseFolderBtn.BackgroundColor = [0.22 0.22 0.22];
            app.BrowseFolderBtn.Visible = 'on';

            app.RunAllBtn=uibutton(P,'push'); app.RunAllBtn.Position=[30 295 160 38];
            app.RunAllBtn.Text='Run Pipeline'; app.RunAllBtn.FontSize=13; app.RunAllBtn.FontWeight='bold';
            app.RunAllBtn.FontColor=[1 1 1]; app.RunAllBtn.BackgroundColor=[0.08 0.32 0.16];
            app.RunAllBtn.ButtonPushedFcn=createCallbackFcn(app,@RunAllBtnPushed,true);
            app.SaveBtn=uibutton(P,'push'); app.SaveBtn.Position=[210 295 160 38];
            app.SaveBtn.Text='Save Results'; app.SaveBtn.FontSize=13; app.SaveBtn.FontWeight='bold';
            app.SaveBtn.FontColor=[1 1 1]; app.SaveBtn.BackgroundColor=[0.12 0.12 0.45];
            app.SaveBtn.ButtonPushedFcn=createCallbackFcn(app,@SaveBtnPushed,true);
            app.RunStatusLabel=uilabel(P); app.RunStatusLabel.Position=[390 295 560 38];
            app.RunStatusLabel.Text='Ready.'; app.RunStatusLabel.FontSize=12;
            app.RunStatusLabel.FontColor=[0.85 0.85 0.85]; app.RunStatusLabel.WordWrap='on';

            % ══════════════════════════════════════════════════════════════
            %  WAVELET DENOISING TAB  —  FIX 3: white text on dark bg
            % ══════════════════════════════════════════════════════════════
            P=app.WaveletTab;
            hdr=uilabel(P); hdr.Position=[30 610 400 30]; hdr.Text='Wavelet Denoising';
            hdr.FontSize=20; hdr.FontWeight='bold'; hdr.FontColor=TXT;
            sub=uilabel(P); sub.Position=[30 590 800 20];
            sub.Text='Decompose EEG using discrete wavelet transform and remove noise via coefficient thresholding.';
            sub.FontSize=12; sub.FontColor=SUB;
            wPanel=uipanel(P); wPanel.Position=[30 440 920 140]; wPanel.Title='  Wavelet Settings';
            wPanel.FontSize=12; wPanel.FontWeight='bold';
            wPanel.ForegroundColor=[0.85 0.85 0.85]; wPanel.BackgroundColor=[0.078 0.078 0.078];
            uilabel(wPanel,'Position',[15 95 150 22],'Text','Wavelet family','FontColor',[0.85 0.85 0.85],'FontSize',12);
            app.WaveletFamilyDropdown=uidropdown(wPanel); app.WaveletFamilyDropdown.Position=[15 65 160 28];
            app.WaveletFamilyDropdown.Items={'db4','db6','db8','sym5','sym8','coif3','coif5'};
            app.WaveletFamilyDropdown.BackgroundColor=[0.145 0.145 0.145];
            app.WaveletFamilyDropdown.FontColor=[0.9 0.9 0.9]; app.WaveletFamilyDropdown.FontSize=12;
            uilabel(wPanel,'Position',[210 95 150 22],'Text','Decomposition level','FontColor',[0.85 0.85 0.85],'FontSize',12);
            app.WaveletLevelField=uieditfield(wPanel,'numeric'); app.WaveletLevelField.Position=[210 65 100 28];
            app.WaveletLevelField.Value=5; app.WaveletLevelField.Limits=[1 10];
            app.WaveletLevelField.BackgroundColor=[0.145 0.145 0.145]; app.WaveletLevelField.FontColor=[0.9 0.9 0.9]; app.WaveletLevelField.FontSize=12;
            uilabel(wPanel,'Position',[345 95 150 22],'Text','Threshold type','FontColor',[0.85 0.85 0.85],'FontSize',12);
            app.WaveletThreshDropdown=uidropdown(wPanel); app.WaveletThreshDropdown.Position=[345 65 140 28];
            app.WaveletThreshDropdown.Items={'Soft','Hard','Minimax'};
            app.WaveletThreshDropdown.BackgroundColor=[0.145 0.145 0.145];
            app.WaveletThreshDropdown.FontColor=[0.9 0.9 0.9]; app.WaveletThreshDropdown.FontSize=12;
            app.WaveletApplyBtn=uibutton(P,'push'); app.WaveletApplyBtn.Position=[30 390 220 38];
            app.WaveletApplyBtn.Text='Apply Wavelet Denoising'; app.WaveletApplyBtn.FontSize=12; app.WaveletApplyBtn.FontWeight='bold';
            app.WaveletApplyBtn.FontColor=[1 1 1]; app.WaveletApplyBtn.BackgroundColor=[0.20 0.20 0.20];
            app.WaveletApplyBtn.ButtonPushedFcn=createCallbackFcn(app,@WaveletApplyBtnPushed,true);
            app.WaveletStatusLabel=uilabel(P); app.WaveletStatusLabel.Position=[265 390 700 38];
            app.WaveletStatusLabel.Text='Ready.'; app.WaveletStatusLabel.FontSize=12;
            app.WaveletStatusLabel.FontColor=[0.85 0.85 0.85]; app.WaveletStatusLabel.WordWrap='on';
            app.WaveletAxesBefore=uiaxes(P); app.WaveletAxesBefore.Position=[30 170 440 210];
            app.WaveletAxesBefore.Color=[0.078 0.078 0.078];
            app.WaveletAxesBefore.XColor=[0.85 0.85 0.85]; app.WaveletAxesBefore.YColor=[0.85 0.85 0.85];
            title(app.WaveletAxesBefore,'Before Denoising (Ch 1)','Color',[0.85 0.85 0.85]);
            xlabel(app.WaveletAxesBefore,'Time (s)','Color',[0.85 0.85 0.85]);
            ylabel(app.WaveletAxesBefore,'Amplitude (µV)','Color',[0.85 0.85 0.85]);
            app.WaveletAxesAfter=uiaxes(P); app.WaveletAxesAfter.Position=[510 170 440 210];
            app.WaveletAxesAfter.Color=[0.078 0.078 0.078];
            app.WaveletAxesAfter.XColor=[0.85 0.85 0.85]; app.WaveletAxesAfter.YColor=[0.85 0.85 0.85];
            title(app.WaveletAxesAfter,'After Denoising (Ch 1)','Color',[0.85 0.85 0.85]);
            xlabel(app.WaveletAxesAfter,'Time (s)','Color',[0.85 0.85 0.85]);
            ylabel(app.WaveletAxesAfter,'Amplitude (µV)','Color',[0.85 0.85 0.85]);

            % ══════════════════════════════════════════════════════════════
            %  ADAPTIVE FILTERING TAB  —  FIX 3: white text
            % ══════════════════════════════════════════════════════════════
            P=app.AdaptiveTab;
            hdr=uilabel(P); hdr.Position=[30 610 400 30]; hdr.Text='Adaptive Filtering';
            hdr.FontSize=20; hdr.FontWeight='bold'; hdr.FontColor=TXT;
            sub=uilabel(P); sub.Position=[30 590 800 20];
            sub.Text='Apply LMS or RLS adaptive filtering to suppress noise by learning the noise pattern from the signal.';
            sub.FontSize=12; sub.FontColor=SUB;
            aPanel=uipanel(P); aPanel.Position=[30 440 920 140]; aPanel.Title='  Adaptive Filter Settings';
            aPanel.FontSize=12; aPanel.FontWeight='bold';
            aPanel.ForegroundColor=[0.85 0.85 0.85]; aPanel.BackgroundColor=[0.078 0.078 0.078];
            uilabel(aPanel,'Position',[15 95 120 22],'Text','Algorithm','FontColor',[0.85 0.85 0.85],'FontSize',12);
            app.AdaptAlgoDropdown=uidropdown(aPanel); app.AdaptAlgoDropdown.Position=[15 65 120 28];
            app.AdaptAlgoDropdown.Items={'LMS','RLS'};
            app.AdaptAlgoDropdown.BackgroundColor=[0.145 0.145 0.145]; app.AdaptAlgoDropdown.FontColor=[0.9 0.9 0.9]; app.AdaptAlgoDropdown.FontSize=12;
            uilabel(aPanel,'Position',[165 95 180 22],'Text','Step size / mu','FontColor',[0.85 0.85 0.85],'FontSize',12);
            app.AdaptMuField=uieditfield(aPanel,'numeric'); app.AdaptMuField.Position=[165 65 110 28];
            app.AdaptMuField.Value=0.01; app.AdaptMuField.Limits=[1e-6 1];
            app.AdaptMuField.BackgroundColor=[0.145 0.145 0.145]; app.AdaptMuField.FontColor=[0.9 0.9 0.9]; app.AdaptMuField.FontSize=12;
            uilabel(aPanel,'Position',[310 95 120 22],'Text','Filter order','FontColor',[0.85 0.85 0.85],'FontSize',12);
            app.AdaptOrderField=uieditfield(aPanel,'numeric'); app.AdaptOrderField.Position=[310 65 100 28];
            app.AdaptOrderField.Value=8; app.AdaptOrderField.Limits=[1 64];
            app.AdaptOrderField.BackgroundColor=[0.145 0.145 0.145]; app.AdaptOrderField.FontColor=[0.9 0.9 0.9]; app.AdaptOrderField.FontSize=12;
            app.AdaptApplyBtn=uibutton(P,'push'); app.AdaptApplyBtn.Position=[30 390 190 38];
            app.AdaptApplyBtn.Text='Apply Adaptive Filter'; app.AdaptApplyBtn.FontSize=12; app.AdaptApplyBtn.FontWeight='bold';
            app.AdaptApplyBtn.FontColor=[1 1 1]; app.AdaptApplyBtn.BackgroundColor=[0.20 0.20 0.20];
            app.AdaptApplyBtn.ButtonPushedFcn=createCallbackFcn(app,@AdaptApplyBtnPushed,true);
            app.AdaptStatusLabel=uilabel(P); app.AdaptStatusLabel.Position=[235 390 680 38];
            app.AdaptStatusLabel.Text='Ready.'; app.AdaptStatusLabel.FontSize=12;
            app.AdaptStatusLabel.FontColor=[0.85 0.85 0.85]; app.AdaptStatusLabel.WordWrap='on';
            app.AdaptAxesBefore=uiaxes(P); app.AdaptAxesBefore.Position=[30 170 440 210];
            app.AdaptAxesBefore.Color=[0.078 0.078 0.078];
            app.AdaptAxesBefore.XColor=[0.85 0.85 0.85]; app.AdaptAxesBefore.YColor=[0.85 0.85 0.85];
            title(app.AdaptAxesBefore,'Before (Ch 1)','Color',[0.85 0.85 0.85]);
            xlabel(app.AdaptAxesBefore,'Time (s)','Color',[0.85 0.85 0.85]);
            ylabel(app.AdaptAxesBefore,'Amplitude (µV)','Color',[0.85 0.85 0.85]);
            app.AdaptAxesAfter=uiaxes(P); app.AdaptAxesAfter.Position=[510 170 440 210];
            app.AdaptAxesAfter.Color=[0.078 0.078 0.078];
            app.AdaptAxesAfter.XColor=[0.85 0.85 0.85]; app.AdaptAxesAfter.YColor=[0.85 0.85 0.85];
            title(app.AdaptAxesAfter,'After (Ch 1)','Color',[0.85 0.85 0.85]);
            xlabel(app.AdaptAxesAfter,'Time (s)','Color',[0.85 0.85 0.85]);
            ylabel(app.AdaptAxesAfter,'Amplitude (µV)','Color',[0.85 0.85 0.85]);

            % ══════════════════════════════════════════════════════════════
            %  COMPARISON TAB  —  FIX 3: white text
            % ══════════════════════════════════════════════════════════════
            P=app.ComparisonTab;
            hdr=uilabel(P); hdr.Position=[30 610 500 30]; hdr.Text='Method Comparison & Metrics';
            hdr.FontSize=20; hdr.FontWeight='bold'; hdr.FontColor=TXT;
            sub=uilabel(P); sub.Position=[30 590 800 20];
            sub.Text='Compare original vs processed EEG using SNR, MSE, and Correlation Coefficient across all channels.';
            sub.FontSize=12; sub.FontColor=SUB;
            app.CompRunBtn=uibutton(P,'push'); app.CompRunBtn.Position=[30 545 200 38];
            app.CompRunBtn.Text='Compute Metrics'; app.CompRunBtn.FontSize=13; app.CompRunBtn.FontWeight='bold';
            app.CompRunBtn.FontColor=[1 1 1]; app.CompRunBtn.BackgroundColor=[0.20 0.20 0.20];
            app.CompRunBtn.ButtonPushedFcn=createCallbackFcn(app,@CompRunBtnPushed,true);
            app.CompStatusLabel=uilabel(P); app.CompStatusLabel.Position=[245 545 680 38];
            app.CompStatusLabel.Text='Load a file and apply processing first, then compute metrics.';
            app.CompStatusLabel.FontSize=12; app.CompStatusLabel.FontColor=[0.85 0.85 0.85]; app.CompStatusLabel.WordWrap='on';
            app.CompAxes=uiaxes(P); app.CompAxes.Position=[30 270 560 260];
            app.CompAxes.Color=[0.078 0.078 0.078];
            app.CompAxes.XColor=[0.85 0.85 0.85]; app.CompAxes.YColor=[0.85 0.85 0.85];
            title(app.CompAxes,'SNR per Channel (dB)','Color',[0.85 0.85 0.85]);
            xlabel(app.CompAxes,'Channel','Color',[0.85 0.85 0.85]);
            ylabel(app.CompAxes,'SNR (dB)','Color',[0.85 0.85 0.85]);
            metricsPanel=uipanel(P); metricsPanel.Position=[610 270 340 260]; metricsPanel.Title='  Quantitative Results';
            metricsPanel.FontSize=12; metricsPanel.FontWeight='bold';
            metricsPanel.ForegroundColor=[0.85 0.85 0.85]; metricsPanel.BackgroundColor=[0.078 0.078 0.078];
            app.CompMetricsArea=uitextarea(metricsPanel); app.CompMetricsArea.Position=[10 10 315 220];
            app.CompMetricsArea.FontSize=11; app.CompMetricsArea.Editable='off';
            app.CompMetricsArea.BackgroundColor=[0.102 0.102 0.102];
            app.CompMetricsArea.FontColor=[0.85 0.85 0.85];
            app.CompMetricsArea.Value='Metrics will appear here after computing.';

            % ══════════════════════════════════════════════════════════════
            %  SIGNAL MERGING TAB  —  FIX 3: white text
            % ══════════════════════════════════════════════════════════════
            P=app.MergeTab;
            hdr=uilabel(P); hdr.Position=[30 610 400 30]; hdr.Text='Signal Merging';
            hdr.FontSize=20; hdr.FontWeight='bold'; hdr.FontColor=TXT;
            sub=uilabel(P); sub.Position=[30 590 800 20];
            sub.Text='Overlay and compare multiple EEG channels in a single plot with vertical offsets for clarity.';
            sub.FontSize=12; sub.FontColor=SUB;
            uilabel(P,'Position',[30 555 300 22],'Text','Channels to merge (e.g. 1 2 3 4 5 6)','FontColor',[0.85 0.85 0.85],'FontSize',12);
            app.MergeChanField=uieditfield(P,'text'); app.MergeChanField.Position=[30 525 300 30];
            app.MergeChanField.Placeholder='Leave blank for first 6';
            app.MergeChanField.BackgroundColor=[0.145 0.145 0.145]; app.MergeChanField.FontColor=[0.9 0.9 0.9]; app.MergeChanField.FontSize=12;
            app.MergePlotBtn=uibutton(P,'push'); app.MergePlotBtn.Position=[350 525 160 32];
            app.MergePlotBtn.Text='Plot Merged'; app.MergePlotBtn.FontSize=12; app.MergePlotBtn.FontWeight='bold';
            app.MergePlotBtn.FontColor=[1 1 1]; app.MergePlotBtn.BackgroundColor=[0.20 0.20 0.20];
            app.MergePlotBtn.ButtonPushedFcn=createCallbackFcn(app,@MergePlotBtnPushed,true);
            app.MergeStatusLabel=uilabel(P); app.MergeStatusLabel.Position=[530 525 420 32];
            app.MergeStatusLabel.Text='Ready.'; app.MergeStatusLabel.FontSize=12; app.MergeStatusLabel.FontColor=[0.85 0.85 0.85];
            app.MergeAxes=uiaxes(P); app.MergeAxes.Position=[30 80 940 430];
            app.MergeAxes.Color=[0.078 0.078 0.078];
            app.MergeAxes.XColor=[0.85 0.85 0.85]; app.MergeAxes.YColor=[0.85 0.85 0.85];
            title(app.MergeAxes,'Merged Channel View','Color',[0.85 0.85 0.85]);
            xlabel(app.MergeAxes,'Time (s)','Color',[0.85 0.85 0.85]);
            ylabel(app.MergeAxes,'Amplitude + offset (µV)','Color',[0.85 0.85 0.85]);

            % ══════════════════════════════════════════════════════════════
            %  RESULTS & SUMMARY TAB  —  FIX 3: white text
            % ══════════════════════════════════════════════════════════════
            P=app.SummaryTab;
            hdr=uilabel(P); hdr.Position=[30 610 500 30]; hdr.Text='Results & Summary';
            hdr.FontSize=20; hdr.FontWeight='bold'; hdr.FontColor=TXT;
            sub=uilabel(P); sub.Position=[30 590 800 20];
            sub.Text='Select a processing step from the dropdown to learn what it does and why it matters.';
            sub.FontSize=12; sub.FontColor=SUB;
            uilabel(P,'Position',[30 555 200 22],'Text','Select a step to explain:','FontColor',[0.85 0.85 0.85],'FontSize',12);
            app.SummaryStepDropdown=uidropdown(P); app.SummaryStepDropdown.Position=[30 525 280 30];
            app.SummaryStepDropdown.Items={'Load Data','Filtering','Re-reference','ICA','Wavelet Denoising','Run & Save'};
            app.SummaryStepDropdown.FontSize=13;
            app.SummaryStepDropdown.BackgroundColor=[0.145 0.145 0.145]; app.SummaryStepDropdown.FontColor=[0.9 0.9 0.9];
            app.SummaryStepDropdown.ValueChangedFcn=createCallbackFcn(app,@SummaryStepChanged,true);
            explPanel=uipanel(P); explPanel.Position=[30 300 920 215]; explPanel.Title='  What this step does';
            explPanel.FontSize=12; explPanel.FontWeight='bold';
            explPanel.ForegroundColor=[0.85 0.85 0.85]; explPanel.BackgroundColor=[0.078 0.078 0.078];
            app.SummaryExplanationArea=uitextarea(explPanel); app.SummaryExplanationArea.Position=[10 10 895 175];
            app.SummaryExplanationArea.FontSize=12; app.SummaryExplanationArea.Editable='off';
            app.SummaryExplanationArea.BackgroundColor=[0.102 0.102 0.102];
            app.SummaryExplanationArea.FontColor=[0.85 0.85 0.85];
            app.SummaryExplanationArea.Value='Select a step above to see its explanation.';
            logPanel=uipanel(P); logPanel.Position=[30 50 920 235]; logPanel.Title='  Processing Log (this session)';
            logPanel.FontSize=12; logPanel.FontWeight='bold';
            logPanel.ForegroundColor=[0.85 0.85 0.85]; logPanel.BackgroundColor=[0.078 0.078 0.078];
            app.SummaryLogArea=uitextarea(logPanel); app.SummaryLogArea.Position=[10 10 895 195];
            app.SummaryLogArea.FontSize=11; app.SummaryLogArea.Editable='off';
            app.SummaryLogArea.BackgroundColor=[0.102 0.102 0.102];
            app.SummaryLogArea.FontColor=[0.85 0.85 0.85];
            app.SummaryLogArea.Value='No steps applied yet.';


            % ── Apply dark theme to all UIAxes ───────────────────────────
            allAxes = findobj(app.UIFigure, 'Type', 'axes');
            allUIAxes = findobj(app.UIFigure, 'Type', 'uiaxes');
            for axObj = allUIAxes'
                try
                    axObj.Color           = [0.078 0.078 0.078];
                    axObj.XColor          = [0.65 0.65 0.65];
                    axObj.YColor          = [0.65 0.65 0.65];
                    axObj.GridColor       = [0.30 0.30 0.30];
                    axObj.MinorGridColor  = [0.22 0.22 0.22];
                    axObj.Title.Color     = [0.85 0.85 0.85];
                    axObj.XLabel.Color    = [0.65 0.65 0.65];
                    axObj.YLabel.Color    = [0.65 0.65 0.65];
                catch
                end
            end

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
