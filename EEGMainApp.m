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

        % ── Load Data tab components ──────────────────────────────────
        % Input file
        InputFilePanel  matlab.ui.container.Panel
        InputFileField  matlab.ui.control.EditField
        BrowseFileBtn   matlab.ui.control.Button
        FileTypeLabel   matlab.ui.control.Label
        FileTypeValue   matlab.ui.control.Label

        % Output folder
        OutputPanel     matlab.ui.container.Panel
        OutputFolderField matlab.ui.control.EditField
        BrowseFolderBtn matlab.ui.control.Button

        % EEG parameters
        ParamsPanel     matlab.ui.container.Panel
        SamplingRateField matlab.ui.control.EditField
        SamplingRateLabel matlab.ui.control.Label
        NumChannelsLabel  matlab.ui.control.Label
        NumChannelsValue  matlab.ui.control.Label

        % Status
        StatusPanel     matlab.ui.container.Panel
        StatusLabel     matlab.ui.control.Label
        LoadBtn         matlab.ui.control.Button

        % Shared EEG data
        EEG             struct
        DataLoaded      logical
    end

    % ════════════════════════════════════════════════════════════════════
    %  Startup
    % ════════════════════════════════════════════════════════════════════
    methods (Access = private)

        function startupFcn(app)
            movegui(app.UIFigure, 'center');
            app.DataLoaded = false;
            app.EEG        = struct();
            app.setStatus('No file loaded. Please select an EEG file to begin.', 'idle');
            % Disable other tabs until data is loaded
            app.FilterTab.Title      = '  Filtering  ';
            app.RereferenceTab.Title = '  Re-reference  ';
            app.ICATab.Title         = '  ICA  ';
            app.VisualizeTab.Title   = '  Visualize  ';
            app.RunTab.Title         = '  Run & Save  ';
        end

    end

    % ════════════════════════════════════════════════════════════════════
    %  Callbacks
    % ════════════════════════════════════════════════════════════════════
    methods (Access = private)

        % Browse for EEG file
        function BrowseFileBtnPushed(app, ~)
            [file, path] = uigetfile( ...
                {'*.csv','CSV Files (*.csv)'; ...
                 '*.mat','MATLAB Files (*.mat)'; ...
                 '*.edf','EDF Files (*.edf)'; ...
                 '*.*','All Files (*.*)'}, ...
                'Select EEG File');

            if isequal(file, 0)
                return;
            end

            fullpath = fullfile(path, file);
            app.InputFileField.Value = fullpath;

            % Detect and display file type
            [~, ~, ext] = fileparts(file);
            switch lower(ext)
                case '.csv'; typeStr = 'CSV  (comma-separated values)';
                case '.mat'; typeStr = 'MAT  (MATLAB data file)';
                case '.edf'; typeStr = 'EDF  (European Data Format)';
                otherwise;   typeStr = 'Unknown format';
            end
            app.FileTypeValue.Text = typeStr;
            app.setStatus(['File selected: ' file '  —  Click "Load File" to import.'], 'idle');
        end

        % Browse for output folder
        function BrowseFolderBtnPushed(app, ~)
            folder = uigetdir('', 'Select Output Folder');
            if isequal(folder, 0)
                return;
            end
            app.OutputFolderField.Value = folder;
        end

        % Load the file
        function LoadBtnPushed(app, ~)
            filepath = app.InputFileField.Value;
            if isempty(filepath)
                app.setStatus('Error: No file selected.', 'error');
                return;
            end
            if ~isfile(filepath)
                app.setStatus('Error: File not found. Check the path.', 'error');
                return;
            end

            app.setStatus('Loading file…', 'busy');
            drawnow;

            try
                [~, ~, ext] = fileparts(filepath);
                switch lower(ext)

                    case '.edf'
                        app.EEG = pop_biosig(filepath);

                    case '.mat'
                        S = load(filepath);
                        fields = fieldnames(S);
                        % Try to find an EEG struct first
                        if isfield(S, 'EEG')
                            app.EEG = S.EEG;
                        elseif isfield(S, 'eeg')
                            % Raw matrix stored as 'eeg'
                            srHz = str2double(app.SamplingRateField.Value);
                            app.EEG         = eeg_emptyset();
                            app.EEG.data    = S.eeg;
                            app.EEG.srate   = srHz;
                            app.EEG.nbchan  = size(S.eeg, 1);
                            app.EEG.pnts    = size(S.eeg, 2);
                            app.EEG.trials  = 1;
                        else
                            % Take the first numeric matrix field
                            found = false;
                            for i = 1:numel(fields)
                                val = S.(fields{i});
                                if isnumeric(val) && ismatrix(val) && ndims(val) == 2
                                    srHz = str2double(app.SamplingRateField.Value);
                                    app.EEG         = eeg_emptyset();
                                    app.EEG.data    = val;
                                    app.EEG.srate   = srHz;
                                    app.EEG.nbchan  = size(val, 1);
                                    app.EEG.pnts    = size(val, 2);
                                    app.EEG.trials  = 1;
                                    found = true;
                                    break;
                                end
                            end
                            if ~found
                                error('No numeric EEG matrix found in .mat file.');
                            end
                        end

                    case '.csv'
                        raw = readmatrix(filepath);
                        % Auto-orient: assume more timepoints than channels
                        if size(raw, 1) > size(raw, 2)
                            raw = raw';   % transpose so rows = channels
                        end
                        app.EEG        = eeg_emptyset();
                        app.EEG.data   = raw;
                        app.EEG.srate  = str2double(app.SamplingRateField.Value);
                        app.EEG.nbchan = size(raw, 1);
                        app.EEG.pnts   = size(raw, 2);
                        app.EEG.trials = 1;

                    otherwise
                        error('Unsupported file format: %s', ext);
                end

                app.EEG = eeg_checkset(app.EEG);
                app.DataLoaded = true;

                % Update info labels
                app.NumChannelsValue.Text = sprintf('%d channels  ·  %d samples  ·  %.1f s', ...
                    app.EEG.nbchan, app.EEG.pnts, app.EEG.pnts / app.EEG.srate);

                app.setStatus( ...
                    sprintf('✓  File loaded successfully — %d channels, %.1f s @ %d Hz', ...
                    app.EEG.nbchan, app.EEG.pnts/app.EEG.srate, app.EEG.srate), 'ok');

            catch ME
                app.setStatus(['Error loading file: ' ME.message], 'error');
            end
        end

        % Helper: update status bar
        function setStatus(app, msg, state)
            app.StatusLabel.Text = msg;
            switch state
                case 'ok'
                    app.StatusLabel.FontColor = [0.10 0.55 0.25];
                case 'error'
                    app.StatusLabel.FontColor = [0.75 0.10 0.10];
                case 'busy'
                    app.StatusLabel.FontColor = [0.65 0.45 0.00];
                otherwise
                    app.StatusLabel.FontColor = [0.40 0.40 0.40];
            end
        end

    end

    % ════════════════════════════════════════════════════════════════════
    %  UI Construction
    % ════════════════════════════════════════════════════════════════════
    methods (Access = private)

        function createComponents(app)

            BG  = [0.94 0.94 0.94];   % Automagic window gray
            PNL = [1.00 1.00 1.00];   % white panels
            ACC = [0.20 0.20 0.20];   % dark accent / borders
            TXT = [0.10 0.10 0.10];   % primary text
            SUB = [0.45 0.45 0.45];   % secondary text
            W   = 1000;  H = 680;

            % ── Figure ──────────────────────────────────────────────────
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position  = [100 100 W H];
            app.UIFigure.Name      = 'EEG Preprocessor';
            app.UIFigure.Color     = BG;

            % ── Tab group ───────────────────────────────────────────────
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [0 0 W H];

            tabNames = {'  Load Data  ','  Filtering  ','  Re-reference  ', ...
                        '  ICA  ','  Visualize  ','  Run & Save  '};
            tabProps  = {'LoadTab','FilterTab','RereferenceTab','ICATab','VisualizeTab','RunTab'};
            for i = 1:6
                app.(tabProps{i})       = uitab(app.TabGroup);
                app.(tabProps{i}).Title = tabNames{i};
                app.(tabProps{i}).BackgroundColor = BG;
            end

            % ════════════════════════════════════════════════════════════
            %  LOAD DATA TAB
            % ════════════════════════════════════════════════════════════
            P = app.LoadTab;   % shorthand

            % Tab header label
            hdr = uilabel(P);
            hdr.Position            = [30 610 400 30];
            hdr.Text                = 'Load EEG Data';
            hdr.FontSize            = 20;
            hdr.FontWeight          = 'bold';
            hdr.FontColor           = TXT;

            sub = uilabel(P);
            sub.Position  = [30 590 600 20];
            sub.Text      = 'Select an EEG file (CSV, MAT or EDF) and an output folder.';
            sub.FontSize  = 12;
            sub.FontColor = SUB;

            % ── Input file panel ────────────────────────────────────────
            app.InputFilePanel = uipanel(P);
            app.InputFilePanel.Position        = [30 480 920 105];
            app.InputFilePanel.Title           = '  EEG File';
            app.InputFilePanel.FontSize        = 12;
            app.InputFilePanel.FontWeight      = 'bold';
            app.InputFilePanel.ForegroundColor = ACC;
            app.InputFilePanel.BackgroundColor = PNL;
            app.InputFilePanel.BorderType      = 'line';

            uilabel(app.InputFilePanel, 'Position', [15 55 80 20], ...
                'Text', 'File path', 'FontColor', SUB, 'FontSize', 11);

            app.InputFileField = uieditfield(app.InputFilePanel, 'text');
            app.InputFileField.Position        = [15 32 760 28];
            app.InputFileField.Value           = '';
            app.InputFileField.Placeholder     = 'Select a file using the Browse button…';
            app.InputFileField.FontSize        = 11;
            app.InputFileField.FontColor       = TXT;
            app.InputFileField.BackgroundColor = [1 1 1];

            app.BrowseFileBtn = uibutton(app.InputFilePanel, 'push');
            app.BrowseFileBtn.Position        = [790 32 105 28];
            app.BrowseFileBtn.Text            = 'Browse…';
            app.BrowseFileBtn.FontSize        = 11;
            app.BrowseFileBtn.FontColor       = [0.10 0.10 0.10];
            app.BrowseFileBtn.BackgroundColor = [0.86 0.86 0.86];
            app.BrowseFileBtn.ButtonPushedFcn = createCallbackFcn(app, @BrowseFileBtnPushed, true);

            uilabel(app.InputFilePanel, 'Position', [15 8 70 18], ...
                'Text', 'Detected type:', 'FontColor', SUB, 'FontSize', 10);
            app.FileTypeValue = uilabel(app.InputFilePanel);
            app.FileTypeValue.Position  = [95 8 400 18];
            app.FileTypeValue.Text      = '—';
            app.FileTypeValue.FontSize  = 10;
            app.FileTypeValue.FontColor = ACC;

            % ── Output folder panel ─────────────────────────────────────
            app.OutputPanel = uipanel(P);
            app.OutputPanel.Position        = [30 360 920 105];
            app.OutputPanel.Title           = '  Output Folder';
            app.OutputPanel.FontSize        = 12;
            app.OutputPanel.FontWeight      = 'bold';
            app.OutputPanel.ForegroundColor = ACC;
            app.OutputPanel.BackgroundColor = PNL;
            app.OutputPanel.BorderType      = 'line';

            uilabel(app.OutputPanel, 'Position', [15 55 80 20], ...
                'Text', 'Save results to', 'FontColor', SUB, 'FontSize', 11);

            app.OutputFolderField = uieditfield(app.OutputPanel, 'text');
            app.OutputFolderField.Position        = [15 32 760 28];
            app.OutputFolderField.Placeholder     = 'Select output folder using the Browse button…';
            app.OutputFolderField.FontSize        = 11;
            app.OutputFolderField.FontColor       = TXT;
            app.OutputFolderField.BackgroundColor = [1 1 1];

            app.BrowseFolderBtn = uibutton(app.OutputPanel, 'push');
            app.BrowseFolderBtn.Position        = [790 32 105 28];
            app.BrowseFolderBtn.Text            = 'Browse…';
            app.BrowseFolderBtn.FontSize        = 11;
            app.BrowseFolderBtn.FontColor       = [0.10 0.10 0.10];
            app.BrowseFolderBtn.BackgroundColor = [0.86 0.86 0.86];
            app.BrowseFolderBtn.ButtonPushedFcn = createCallbackFcn(app, @BrowseFolderBtnPushed, true);

            uilabel(app.OutputPanel, 'Position', [15 8 600 18], ...
                'Text', 'Processed files will be saved here as .mat (EEGLAB format).', ...
                'FontColor', SUB, 'FontSize', 10);

            % ── EEG parameters panel ────────────────────────────────────
            app.ParamsPanel = uipanel(P);
            app.ParamsPanel.Position        = [30 240 920 105];
            app.ParamsPanel.Title           = '  EEG Parameters';
            app.ParamsPanel.FontSize        = 12;
            app.ParamsPanel.FontWeight      = 'bold';
            app.ParamsPanel.ForegroundColor = ACC;
            app.ParamsPanel.BackgroundColor = PNL;
            app.ParamsPanel.BorderType      = 'line';

            uilabel(app.ParamsPanel, 'Position', [15 55 200 20], ...
                'Text', 'Sampling Rate (Hz)  —  required for CSV/MAT', ...
                'FontColor', SUB, 'FontSize', 11);

            app.SamplingRateField = uieditfield(app.ParamsPanel, 'text');
            app.SamplingRateField.Position        = [15 28 120 28];
            app.SamplingRateField.Value           = '256';
            app.SamplingRateField.FontSize        = 13;
            app.SamplingRateField.FontColor       = TXT;
            app.SamplingRateField.BackgroundColor = [1 1 1];

            uilabel(app.ParamsPanel, 'Position', [155 28 50 28], ...
                'Text', 'Hz', 'FontColor', SUB, 'FontSize', 12);

            uilabel(app.ParamsPanel, 'Position', [250 55 200 20], ...
                'Text', 'Dataset info (after loading)', ...
                'FontColor', SUB, 'FontSize', 11);

            app.NumChannelsValue = uilabel(app.ParamsPanel);
            app.NumChannelsValue.Position  = [250 28 600 28];
            app.NumChannelsValue.Text      = '—';
            app.NumChannelsValue.FontSize  = 12;
            app.NumChannelsValue.FontColor = ACC;

            % ── Status + Load button ────────────────────────────────────
            app.StatusPanel = uipanel(P);
            app.StatusPanel.Position        = [30 140 920 85];
            app.StatusPanel.Title           = '  Status';
            app.StatusPanel.FontSize        = 12;
            app.StatusPanel.FontWeight      = 'bold';
            app.StatusPanel.ForegroundColor = ACC;
            app.StatusPanel.BackgroundColor = PNL;
            app.StatusPanel.BorderType      = 'line';

            app.StatusLabel = uilabel(app.StatusPanel);
            app.StatusLabel.Position   = [15 12 760 40];
            app.StatusLabel.Text       = 'Ready.';
            app.StatusLabel.FontSize   = 12;
            app.StatusLabel.FontColor  = SUB;
            app.StatusLabel.WordWrap   = 'on';

            app.LoadBtn = uibutton(app.StatusPanel, 'push');
            app.LoadBtn.Position        = [790 20 105 38];
            app.LoadBtn.Text            = 'Load File';
            app.LoadBtn.FontSize        = 13;
            app.LoadBtn.FontWeight      = 'bold';
            app.LoadBtn.FontColor       = [0.10 0.10 0.10];
            app.LoadBtn.BackgroundColor = [0.86 0.86 0.86];
            app.LoadBtn.ButtonPushedFcn = createCallbackFcn(app, @LoadBtnPushed, true);

            % ── Placeholder notice for other tabs ───────────────────────
            otherTabs = {app.FilterTab, app.RereferenceTab, app.ICATab, ...
                         app.VisualizeTab, app.RunTab};
            otherNames = {'Filtering','Re-referencing','ICA Artifact Removal', ...
                          'Visualization','Run & Save'};
            for i = 1:5
                lbl = uilabel(otherTabs{i});
                lbl.Position            = [0 280 W 60];
                lbl.Text                = ['⟳  ' otherNames{i} ' — coming in next build'];
                lbl.FontSize            = 18;
                lbl.FontColor           = [0.35 0.37 0.42];
                lbl.HorizontalAlignment = 'center';
            end

            app.UIFigure.Visible = 'on';
        end
    end

    % ════════════════════════════════════════════════════════════════════
    %  Constructor / Destructor
    % ════════════════════════════════════════════════════════════════════
    methods (Access = public)

        function app = EEGMainApp
            createComponents(app);
            registerApp(app, app.UIFigure);
            runStartupFcn(app, @startupFcn);
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end
end
