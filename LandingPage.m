classdef LandingPage < matlab.apps.AppBase

    properties (Access = public)
        UIFigure      matlab.ui.Figure
        MainPanel     matlab.ui.container.Panel
        TitleLabel    matlab.ui.control.Label
        SubtitleLabel matlab.ui.control.Label
        DescLabel     matlab.ui.control.Label
        GetStartedBtn matlab.ui.control.Button
        VersionLabel  matlab.ui.control.Label
    end

    methods (Access = private)

        function startupFcn(app)
            movegui(app.UIFigure, 'center');
        end

        function GetStartedBtnPushed(app, ~)
            delete(app);
            EEGMainApp;
        end

    end

    methods (Access = private)

        function createComponents(app)

            % ── Colors (Automagic light theme) ──────────────────────────
            BG   = [0.94 0.94 0.94];   % window background
            PNL  = [1.00 1.00 1.00];   % white panels
            ACC  = [0.20 0.20 0.20];   % dark text
            BTN  = [0.93 0.93 0.93];   % button gray
            SUB  = [0.45 0.45 0.45];   % secondary text

            % ── Figure ───────────────────────────────────────────────────
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position  = [100 100 720 480];
            app.UIFigure.Name      = 'EEG Preprocessor';
            app.UIFigure.Color     = BG;
            app.UIFigure.Resize    = 'off';

            % ── Background panel ────────────────────────────────────────
            app.MainPanel = uipanel(app.UIFigure);
            app.MainPanel.Position        = [0 0 720 480];
            app.MainPanel.BackgroundColor = BG;
            app.MainPanel.BorderType      = 'none';

            % ── Title ───────────────────────────────────────────────────
            app.TitleLabel = uilabel(app.MainPanel);
            app.TitleLabel.Position            = [60 360 600 70];
            app.TitleLabel.Text                = 'EEG Preprocessor';
            app.TitleLabel.FontSize            = 46;
            app.TitleLabel.FontWeight          = 'bold';
            app.TitleLabel.FontColor           = ACC;
            app.TitleLabel.HorizontalAlignment = 'center';

            % ── Accent line ─────────────────────────────────────────────
            accent = uilabel(app.MainPanel);
            accent.Position        = [210 352 300 2];
            accent.Text            = '';
            accent.BackgroundColor = [0.60 0.60 0.60];

            % ── Subtitle ────────────────────────────────────────────────
            app.SubtitleLabel = uilabel(app.MainPanel);
            app.SubtitleLabel.Position            = [60 315 600 35];
            app.SubtitleLabel.Text                = 'Automated EEG Signal Processing Pipeline';
            app.SubtitleLabel.FontSize            = 15;
            app.SubtitleLabel.FontColor           = SUB;
            app.SubtitleLabel.HorizontalAlignment = 'center';
            app.SubtitleLabel.BackgroundColor     = BG;

            % ── Description ─────────────────────────────────────────────
            app.DescLabel = uilabel(app.MainPanel);
            app.DescLabel.Position            = [110 255 500 55];
            app.DescLabel.Text                = ['Load EEG files in CSV, MAT or EDF format. ' ...
                'Apply bandpass/notch filtering, robust re-referencing, ' ...
                'wavelet denoising, adaptive filtering, and ICA artifact removal.'];
            app.DescLabel.FontSize            = 12;
            app.DescLabel.FontColor           = SUB;
            app.DescLabel.HorizontalAlignment = 'center';
            app.DescLabel.WordWrap            = 'on';
            app.DescLabel.BackgroundColor     = BG;

            % ── Feature chips ───────────────────────────────────────────
            chips  = {'CSV · MAT · EDF', 'Bandpass & Notch', 'PREP Re-reference', ...
                      'Wavelet Denoising', 'Adaptive Filter', 'ICA + ICLabel'};
            nChips = numel(chips);
            cW     = 110;  cH = 26;  gap = 10;
            totalW = nChips * cW + (nChips-1) * gap;
            x0     = (720 - totalW) / 2;
            y0     = 205;

            for k = 1:nChips
                xk = x0 + (k-1)*(cW + gap);
                c = uilabel(app.MainPanel);
                c.Position            = [xk y0 cW cH];
                c.Text                = chips{k};
                c.FontSize            = 10;
                c.FontWeight          = 'bold';
                c.FontColor           = ACC;
                c.HorizontalAlignment = 'center';
                c.BackgroundColor     = BTN;
            end

            % ── Get Started button ───────────────────────────────────────
            app.GetStartedBtn = uibutton(app.MainPanel, 'push');
            app.GetStartedBtn.Position        = [260 120 200 48];
            app.GetStartedBtn.Text            = 'Get Started  →';
            app.GetStartedBtn.FontSize        = 15;
            app.GetStartedBtn.FontWeight      = 'bold';
            app.GetStartedBtn.FontColor       = [0.20 0.20 0.20];
            app.GetStartedBtn.BackgroundColor = BTN;
            app.GetStartedBtn.ButtonPushedFcn = createCallbackFcn(app, @GetStartedBtnPushed, true);

            % ── Version footer ──────────────────────────────────────────
            app.VersionLabel = uilabel(app.MainPanel);
            app.VersionLabel.Position            = [0 12 720 18];
            app.VersionLabel.Text                = 'v1.0   ·   EEGLAB 2026   ·   PREP · ICLabel · MARA · clean_rawdata';
            app.VersionLabel.FontSize            = 9;
            app.VersionLabel.FontColor           = SUB;
            app.VersionLabel.HorizontalAlignment = 'center';
            app.VersionLabel.BackgroundColor     = BG;

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
