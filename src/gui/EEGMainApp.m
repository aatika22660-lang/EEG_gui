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
            app.DataLoaded = false;
            app.EEG        = struct();
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
                app.DataLoaded = true;
                app.NumChannelsValue.Text = sprintf('%d channels  ·  %d samples  ·  %.1f s', ...
                    app.EEG.nbchan, app.EEG.pnts, app.EEG.pnts/app.EEG.srate);
                app.setStatus(sprintf('✔  Loaded – %d channels, %.1f s @ %d Hz', ...
                    app.EEG.nbchan, app.EEG.pnts/app.EEG.srate, app.EEG.srate), 'ok');
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
            catch ME
                app.RunStatusLabel.Text = ['Error saving: ' ME.message];
                app.RunStatusLabel.FontColor = [0.75 0.10 0.10];
            end
        end

        % ── Shared helper ─────────────────────────────────────────────────

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
                        '  ICA  ','  Visualize  ','  Run & Save  '};
            tabProps = {'LoadTab','FilterTab','RereferenceTab','ICATab','VisualizeTab','RunTab'};
            for i = 1:6
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
