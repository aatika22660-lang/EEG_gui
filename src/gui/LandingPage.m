classdef LandingPage < matlab.apps.AppBase

    properties (Access = public)
        UIFigure        matlab.ui.Figure
        BGAxes          matlab.ui.control.UIAxes
        TitleLine1      matlab.ui.control.Label
        TitleLine2      matlab.ui.control.Label
        TitleLine3      matlab.ui.control.Label
        SubtitleLabel   matlab.ui.control.Label
        LoadFileBtn     matlab.ui.control.Button
        SampleBtn       matlab.ui.control.Button
        ByLabel         matlab.ui.control.Label
    end

    methods (Access = private)

        function startupFcn(app)
            movegui(app.UIFigure, 'center');
            drawBackground(app);
        end

        function drawBackground(app)
            ax = app.BGAxes;
            cla(ax);
            hold(ax, 'on');
            ax.XLim = [0 100];
            ax.YLim = [0 100];
            ax.XAxis.Visible = 'off';
            ax.YAxis.Visible = 'off';
            ax.Color = [1 1 1];
            ax.Box   = 'off';

            % ── Faint diagonal texture lines ──────────────────────────────
            for xi = -30:12:130
                plot(ax, [xi xi+100], [0 100], '-', ...
                    'Color', [0.93 0.93 0.93], 'LineWidth', 0.4);
            end

            % ── Main curved dashed path (S-curve) ─────────────────────────
            px = [15, 28, 40, 50, 58, 68, 80];
            py = [15, 28, 44, 57, 66, 76, 88];
            t  = 1:numel(px);
            tf = linspace(1, numel(px), 400);
            xs = spline(t, px, tf);
            ys = spline(t, py, tf);

            plot(ax, xs, ys, '--', 'Color', [0.75 0.75 0.75], ...
                'LineWidth', 1.0);

            % ── Nodes along curve ─────────────────────────────────────────
% ── Second smaller path (top right area) ─────────────────────
px2 = [60, 72, 83, 92];   % 4 x-coords to match py2
py2 = [70, 78, 83, 88];   % 4 y-coords
t2  = 1:numel(px2);
tf2 = linspace(1, numel(px2), 100);
xs2 = spline(t2, px2, tf2);
ys2 = spline(t2, py2, tf2);
plot(ax, xs2, ys2, '--', 'Color', [0.82 0.82 0.82], ...
    'LineWidth', 0.7);

            hold(ax, 'off');
        end

        function LoadFileBtnPushed(app, ~)
            [file, path] = uigetfile( ...
                {'*.csv','CSV Files (*.csv)'; ...
                 '*.mat','MAT Files (*.mat)'; ...
                 '*.edf','EDF Files (*.edf)'; ...
                 '*.*','All Files (*.*)'}, ...
                'Select EEG File');
            if isequal(file, 0); return; end
            delete(app);
            EEGMainApp(fullfile(path, file));
        end

        function SampleBtnPushed(app, ~)
            thisDir   = fileparts(which('LandingPage'));
            sampleDir = fullfile(thisDir, 'sample_data');
            if ~isfolder(sampleDir); sampleDir = thisDir; end
            [file, path] = uigetfile( ...
                {'*.csv;*.mat;*.edf','EEG Files'}, ...
                'Choose a sample file', sampleDir);
            if isequal(file, 0); return; end
            delete(app);
            EEGMainApp(fullfile(path, file));
        end

    end

    methods (Access = private)

        function createComponents(app)

            W = 940;  H = 580;
            TXT = [0.15 0.15 0.15];
            SUB = [0.48 0.48 0.48];

            % ── Figure ───────────────────────────────────────────────────
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position  = [100 100 W H];
            app.UIFigure.Name      = 'EEG Analysis Tool';
            app.UIFigure.Color     = [1 1 1];
            app.UIFigure.Resize    = 'off';

            % ── Background axes (full window, behind everything) ──────────
            app.BGAxes = uiaxes(app.UIFigure);
            app.BGAxes.Position = [0 0 W H];
            app.BGAxes.Color    = [1 1 1];
            disableDefaultInteractivity(app.BGAxes);

            % ── LEFT — Title block ────────────────────────────────────────
            app.TitleLine1 = uilabel(app.UIFigure);
            app.TitleLine1.Position            = [62 412 420 62];
            app.TitleLine1.Text                = 'Interactive';
            app.TitleLine1.FontSize            = 50;
            app.TitleLine1.FontWeight          = 'bold';
            app.TitleLine1.FontColor           = TXT;
            app.TitleLine1.BackgroundColor     = 'none';
            app.TitleLine1.HorizontalAlignment = 'left';

            app.TitleLine2 = uilabel(app.UIFigure);
            app.TitleLine2.Position            = [62 350 440 62];
            app.TitleLine2.Text                = 'EEG Analysis';
            app.TitleLine2.FontSize            = 50;
            app.TitleLine2.FontWeight          = 'bold';
            app.TitleLine2.FontColor           = TXT;
            app.TitleLine2.BackgroundColor     = 'none';
            app.TitleLine2.HorizontalAlignment = 'left';

            app.TitleLine3 = uilabel(app.UIFigure);
            app.TitleLine3.Position            = [62 288 480 62];
            app.TitleLine3.Text                = '& Artifact Removal';
            app.TitleLine3.FontSize            = 50;
            app.TitleLine3.FontWeight          = 'bold';
            app.TitleLine3.FontColor           = TXT;
            app.TitleLine3.BackgroundColor     = 'none';
            app.TitleLine3.HorizontalAlignment = 'left';

            % Subtitle
            app.SubtitleLabel = uilabel(app.UIFigure);
            app.SubtitleLabel.Position            = [64 230 390 50];
            app.SubtitleLabel.Text                = ['Filter, re-reference and remove artifacts from EEG signals.' newline ...
                                                     'Supports CSV, MAT and EDF file formats.'];
            app.SubtitleLabel.FontSize            = 13;
            app.SubtitleLabel.FontColor           = SUB;
            app.SubtitleLabel.BackgroundColor     = 'none';
            app.SubtitleLabel.HorizontalAlignment = 'left';
            app.SubtitleLabel.WordWrap            = 'on';

            % ── RIGHT — Buttons ───────────────────────────────────────────
            bX = 672;
            bW = 220;

            % Primary — dark filled
            app.LoadFileBtn = uibutton(app.UIFigure, 'push');
            app.LoadFileBtn.Position        = [bX 348 bW 50];
            app.LoadFileBtn.Text            = 'Load EEG Signal';
            app.LoadFileBtn.FontSize        = 14;
            app.LoadFileBtn.FontWeight      = 'bold';
            app.LoadFileBtn.FontColor       = [1 1 1];
            app.LoadFileBtn.BackgroundColor = [0.15 0.15 0.15];
            app.LoadFileBtn.ButtonPushedFcn = createCallbackFcn(app, @LoadFileBtnPushed, true);

            % Secondary — light outlined style
            app.SampleBtn = uibutton(app.UIFigure, 'push');
            app.SampleBtn.Position        = [bX 284 bW 46];
            app.SampleBtn.Text            = 'Try a Sample File';
            app.SampleBtn.FontSize        = 13;
            app.SampleBtn.FontWeight      = 'normal';
            app.SampleBtn.FontColor       = TXT;
            app.SampleBtn.BackgroundColor = [0.93 0.93 0.93];
            app.SampleBtn.ButtonPushedFcn = createCallbackFcn(app, @SampleBtnPushed, true);

            % ── Footer ───────────────────────────────────────────────────
            app.ByLabel = uilabel(app.UIFigure);
            app.ByLabel.Position            = [0 16 W 16];
            app.ByLabel.Text                = 'By Mohammad Azlaan & Aatika Asim';
            app.ByLabel.FontSize            = 10;
            app.ByLabel.FontColor           = [0.68 0.68 0.68];
            app.ByLabel.HorizontalAlignment = 'center';
            app.ByLabel.BackgroundColor     = 'none';

            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = public)

        function app = LandingPage
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
