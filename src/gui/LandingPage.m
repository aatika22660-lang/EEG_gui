classdef LandingPage < matlab.apps.AppBase

    properties (Access = public)
        UIFigure        matlab.ui.Figure
        BGAxes          matlab.ui.control.UIAxes
        GlobeAxes       matlab.ui.control.UIAxes
        NavBar          matlab.ui.control.Label
        CardPanel       matlab.ui.container.Panel
        TagLabel        matlab.ui.control.Label
        TitleLabel      matlab.ui.control.Label
        DividerLabel    matlab.ui.control.Label
        StackTitle      matlab.ui.control.Label
        LangRow         matlab.ui.control.Label
        LangVal         matlab.ui.control.Label
        VizRow          matlab.ui.control.Label
        VizVal          matlab.ui.control.Label
        CompRow         matlab.ui.control.Label
        CompVal         matlab.ui.control.Label
        DividerLabel2   matlab.ui.control.Label
        UploadLink      matlab.ui.control.Button
        ArrowBtn        matlab.ui.control.Button
        ByLabel         matlab.ui.control.Label
        GlobeTimer      timer
    end

    properties (Access = private)
        GlobeAngle   double = 0   % rotation state for the globe animation
        ElecPos      double       % Nx3 electrode positions
        ElecColors   double       % Nx3 HSV colors per electrode
        ElecLabels   cell         % Nx1 label strings
        hDots        matlab.graphics.chart.primitive.Scatter  % hidden dots
        hLabels      % cell of text handles
    end

    methods (Access = private)

        function startupFcn(app)
            movegui(app.UIFigure, 'center');
            drawGlobe(app, 0);
            startGlobeTimer(app);
        end

        % ── Animated rotating brain surface + electrodes ────────────────
        function drawGlobe(app, theta)
            ax = app.GlobeAxes;

            if isempty(ax.Children)

                % ── Axes setup ────────────────────────────────────────────
                ax.Color           = [0.08 0.08 0.08];
                ax.XAxis.Visible   = 'off';
                ax.YAxis.Visible   = 'off';
                ax.ZAxis.Visible   = 'off';
                ax.Box             = 'off';
                ax.DataAspectRatio = [1 1 1];
                ax.Projection      = 'orthographic';
                disableDefaultInteractivity(ax);

                % ── Load Colin27 mesh ─────────────────────────────────────
                colinFile = fullfile( ...
                    fileparts(which('eeglab')), ...
                    'functions','supportfiles', ...
                    'head_modelColin27_5003_Standard-10-5-Cap339.mat');
                S      = load(colinFile);
                cortex = S.cortex;

                V = LandingPage.pick_numeric(cortex, ...
                    {'pos','pnt','vert','vertices','Vertices','coords'}, 3);
                F = LandingPage.pick_numeric(cortex, ...
                    {'tri','face','faces','Faces','triangles','elements'}, 3);
                V = double(V); F = double(F);
                if min(F(:)) == 0, F = F + 1; end

                % ── Depth shading ─────────────────────────────────────────
                Vc    = V - mean(V,1);
                depth = Vc * [0.2;0.1;0.8];
                depth = LandingPage.smooth_on_mesh(depth, F, size(V,1), 6);
                depth = (depth-min(depth))./(max(depth)-min(depth));
                grey_vals = 0.88 - 0.18.*depth;

                trisurf(F, V(:,1), V(:,2), V(:,3), grey_vals, ...
                    'Parent',ax, 'EdgeColor','none', 'FaceColor','interp', ...
                    'FaceLighting','gouraud', ...
                    'AmbientStrength',0.18, 'DiffuseStrength',0.72, ...
                    'SpecularStrength',0.30, 'SpecularExponent',18);

                cmap = gray(256); cmap = cmap(150:256,:);
                colormap(ax, cmap); ax.CLim = [0 1];

                light('Parent',ax,'Position',[ 1.5  0.5  2.0], ...
                    'Style','infinite','Color',[1.0 1.0 1.0]);
                light('Parent',ax,'Position',[-1.0 -0.3  0.5], ...
                    'Style','infinite','Color',[0.25 0.25 0.28]);

                axis(ax,'equal','off','tight');
                view(ax,[-68,16]);
                camzoom(ax, 0.82);

                % ── Electrodes from channelSpace ──────────────────────────
                if isfield(S,'channelSpace') && isfield(S,'labels')
                    ep = double(S.channelSpace);   % Nx3
                    el = S.labels;                 % Nx1 cell
                    if ischar(el), el = cellstr(el); end
                    nE = size(ep,1);

                    % HSV colour wheel — one colour per electrode
                    cols = hsv(nE);

                    % Draw ALL dots at once as one scatter — initially invisible
                    hold(ax,'on');
                    app.hDots = scatter3(ax, ep(:,1), ep(:,2), ep(:,3), ...
                        55, cols, 'filled', ...
                        'MarkerEdgeColor','w', 'LineWidth',0.5, ...
                        'Visible','off');
                    hold(ax,'off');

                    % One text label per electrode — all invisible
                    app.hLabels = cell(nE,1);
                    for k = 1:nE
                        app.hLabels{k} = text(ax, ...
                            ep(k,1), ep(k,2), ep(k,3), ...
                            [' ' el{k}], ...
                            'Color', cols(k,:), ...
                            'FontSize', 8, ...
                            'FontName', 'Courier New', ...
                            'Visible', 'off', ...
                            'HitTest', 'off');
                    end

                    % Store for hover callback
                    app.ElecPos    = ep;
                    app.ElecColors = cols;
                    app.ElecLabels = el;

                    % Wire hover callback to the figure
                    app.UIFigure.WindowButtonMotionFcn = ...
                        @(~,~) hoverCallback(app);
                end
            end

            % Rotate view each frame
            az = mod(-68 + theta*(180/pi)*0.6, 360);
            view(ax,[az,16]);
            drawnow limitrate;
        end

        % ── Hover: show only the nearest electrode ────────────────────────
        function hoverCallback(app)
            if isempty(app.ElecPos) || ~isvalid(app.GlobeAxes)
                return;
            end
            ax  = app.GlobeAxes;
            ep  = app.ElecPos;
            nE  = size(ep,1);

            % Current mouse position in figure pixels
            mp = app.UIFigure.CurrentPoint;   % [x y] in figure pixels
            axPos = getpixelposition(ax, true);% ax position in figure pixels

            % Convert mouse to axes normalised [0,1]
            nx = (mp(1) - axPos(1)) / axPos(3);
            ny = (mp(2) - axPos(2)) / axPos(4);

            % Only process if mouse is inside the axes
            if nx<0 || nx>1 || ny<0 || ny>1
                % Hide everything when outside
                set(app.hDots, 'Visible','off');
                for k=1:nE, set(app.hLabels{k},'Visible','off'); end
                return;
            end

            % Project all 3-D electrode positions to 2-D screen coords
            % using data2fig helper
            scrPts = LandingPage.project3D(ax, ep);  % Nx2 in [0,1] normalised

            % Distance from mouse to each projected electrode
            dx   = scrPts(:,1) - nx;
            dy   = scrPts(:,2) - ny;
            dist = sqrt(dx.^2 + dy.^2);

            THRESH = 0.04;   % normalised-axes units (~4% of axes width)
            [dmin, idx] = min(dist);

            % Show all dots dimly always, highlight nearest on hover
            set(app.hDots, 'Visible','on');

            % Reset all labels off
            for k=1:nE, set(app.hLabels{k},'Visible','off'); end

            if dmin < THRESH
                % Show label for nearest electrode
                set(app.hLabels{idx}, 'Visible','on');
            end
            drawnow limitrate;
        end


        function startGlobeTimer(app)
            app.GlobeTimer = timer( ...
                'ExecutionMode', 'fixedRate', ...
                'Period',        0.05, ...
                'TimerFcn',      @(~,~) timerStep(app));
            start(app.GlobeTimer);
        end

        function timerStep(app)
            if ~isvalid(app); return; end
            app.GlobeAngle = app.GlobeAngle + 0.012;
            drawGlobe(app, app.GlobeAngle);
        end

        % ── Button callbacks ──────────────────────────────────────────────
        function LoadFileBtnPushed(app, ~)
            stopAndDeleteTimer(app);
            app.UIFigure.Visible = 'off';   % hide window so dialog isn't buried

            [file, path] = uigetfile( ...
                {'*.csv','CSV Files (*.csv)'; ...
                 '*.mat','MAT Files (*.mat)'; ...
                 '*.edf','EDF Files (*.edf)'; ...
                 '*.*','All Files (*.*)'}, ...
                'Select EEG File');
            if isequal(file, 0)
                app.UIFigure.Visible = 'on';  % bring it back if cancelled

                startGlobeTimer(app);   % restart if cancelled
                return;
            end
            delete(app);
            EEGMainApp(fullfile(path, file));
        end

        function stopAndDeleteTimer(app)
            if ~isempty(app.GlobeTimer) && isvalid(app.GlobeTimer)
                stop(app.GlobeTimer);
                delete(app.GlobeTimer);
            end
        end

    end

    methods (Access = private)

        function createComponents(app)

            W  = 1100; H = 680;
            BG = [0.08 0.08 0.08];
            FG = [0.90 0.90 0.90];
            DIM= [0.65 0.65 0.65];          % label keys colour
            ACC= [0.78 0.55 0.40];          % amber upload button
            GRN= [0.49 0.63 0.48];          % Technology Stack heading
            WHT= [1.00 1.00 1.00];          % right-side values
            FONT = 'Andale Mono';

            % ── Figure ────────────────────────────────────────────────────
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position      = [100 100 W H];
            app.UIFigure.Name          = 'EEG Analysis Tool';
            app.UIFigure.Color         = BG;
            app.UIFigure.Resize        = 'off';

            % ── Full-window background axes ───────────────────────────────
            app.BGAxes = uiaxes(app.UIFigure);
            app.BGAxes.Position = [0 0 W H];
            app.BGAxes.Color    = BG;
            ax = app.BGAxes;
            ax.XAxis.Visible = 'off';
            ax.YAxis.Visible = 'off';
            ax.Box = 'off';
            disableDefaultInteractivity(app.BGAxes);

            % ── Top nav bar label ─────────────────────────────────────────
            app.NavBar = uilabel(app.UIFigure);
            app.NavBar.Position            = [300 H-52 W-320 30];
            app.NavBar.Text                = '01 UPLOAD     02 PREPROCESS     03 DENOISE     04 FILTER     05 ANALYZE     06 REPORT';
            app.NavBar.FontSize            = 10.5;
            app.NavBar.FontName            = FONT;
            app.NavBar.FontColor           = [0.40 0.40 0.40];
            app.NavBar.BackgroundColor     = 'none';
            app.NavBar.HorizontalAlignment = 'center';

            % Nav bar border bottom
            sepPnl = uipanel(app.UIFigure);
            sepPnl.Position        = [0 H-58 W 1];
            sepPnl.BackgroundColor = [0.22 0.22 0.22];
            sepPnl.BorderType      = 'none';

            % ── Globe axes (right half) ───────────────────────────────────
            globeW = 580; globeH = 580;
            app.GlobeAxes = uiaxes(app.UIFigure);
            app.GlobeAxes.Position = [W - globeW - 10, (H - globeH)/2 - 10, globeW, globeH];
            app.GlobeAxes.Color    = BG;
            disableDefaultInteractivity(app.GlobeAxes);

            % ── Card panel — narrower ─────────────────────────────────────
            cX = 120; cY = 110; cW = 290; cH = 430;
            app.CardPanel = uipanel(app.UIFigure);
            app.CardPanel.Position        = [cX cY cW cH];
            app.CardPanel.BackgroundColor = [0.13 0.13 0.13];
            app.CardPanel.BorderType      = 'line';
            app.CardPanel.ForegroundColor = [0.25 0.25 0.25];
            app.CardPanel.BorderWidth     = 1;

            % Tag line
            app.TagLabel = uilabel(app.UIFigure);
            app.TagLabel.Position            = [cX+14 cY+cH-36 cW-18 18];
            app.TagLabel.Text                = '✧ Development  /  ✧ Prototype';
            app.TagLabel.FontSize            = 8.5;
            app.TagLabel.FontName            = FONT;
            app.TagLabel.FontColor           = [0.40 0.40 0.40];
            app.TagLabel.BackgroundColor     = 'none';
            app.TagLabel.HorizontalAlignment = 'left';

            % Dashed divider — full card width
            app.DividerLabel = uilabel(app.UIFigure);
            app.DividerLabel.Position            = [cX+14 cY+cH-50 cW-18 12];
            app.DividerLabel.Text                = repmat('- ', 1, 34);
            app.DividerLabel.FontSize            = 7;
            app.DividerLabel.FontName            = FONT;
            app.DividerLabel.FontColor           = [0.28 0.28 0.28];
            app.DividerLabel.BackgroundColor     = 'none';

            % Title
            app.TitleLabel = uilabel(app.UIFigure);
            app.TitleLabel.Position            = [cX+14 cY+cH-170 cW-18 114];
            app.TitleLabel.Text                = ['Interactive EEG' newline ...
                                                  'Analysis & Artifact' newline ...
                                                  'Removal'];
            app.TitleLabel.FontSize            = 20;
            app.TitleLabel.FontWeight          = 'bold';
            app.TitleLabel.FontName            = FONT;
            app.TitleLabel.FontColor           = FG;
            app.TitleLabel.BackgroundColor     = 'none';
            app.TitleLabel.HorizontalAlignment = 'left';
            app.TitleLabel.WordWrap            = 'on';

            % Divider 2 — full card width
            app.DividerLabel2 = uilabel(app.UIFigure);
            app.DividerLabel2.Position            = [cX+14 cY+cH-184 cW-18 12];
            app.DividerLabel2.Text                = repmat('- ', 1, 34);
            app.DividerLabel2.FontSize            = 7;
            app.DividerLabel2.FontName            = FONT;
            app.DividerLabel2.FontColor           = [0.28 0.28 0.28];
            app.DividerLabel2.BackgroundColor     = 'none';

            % Technology Stack heading — green
            app.StackTitle = uilabel(app.UIFigure);
            app.StackTitle.Position            = [cX+14 cY+cH-206 cW-18 18];
            app.StackTitle.Text                = 'Technology Stack';
            app.StackTitle.FontSize            = 10;
            app.StackTitle.FontWeight          = 'bold';
            app.StackTitle.FontName            = FONT;
            app.StackTitle.FontColor           = GRN;
            app.StackTitle.BackgroundColor     = 'none';

            rowH = 20; rowStart = cY + cH - 230;
            lW = cW * 0.52;   % left col width
            rX = cX + lW;     % right col x
            rW = cW - lW - 14;

            % Language
            app.LangRow = uilabel(app.UIFigure);
            app.LangRow.Position            = [cX+14 rowStart lW rowH];
            app.LangRow.Text                = 'Language';
            app.LangRow.FontSize            = 10;
            app.LangRow.FontName            = FONT;
            app.LangRow.FontColor           = DIM;
            app.LangRow.BackgroundColor     = 'none';

            app.LangVal = uilabel(app.UIFigure);
            app.LangVal.Position            = [rX rowStart rW rowH];
            app.LangVal.Text                = 'MATLAB';
            app.LangVal.FontSize            = 10;
            app.LangVal.FontName            = FONT;
            app.LangVal.FontColor           = WHT;
            app.LangVal.BackgroundColor     = 'none';
            app.LangVal.HorizontalAlignment = 'right';

            % Visualization
            app.VizRow = uilabel(app.UIFigure);
            app.VizRow.Position            = [cX+14 rowStart-24 lW rowH];
            app.VizRow.Text                = 'Visualization';
            app.VizRow.FontSize            = 10;
            app.VizRow.FontName            = FONT;
            app.VizRow.FontColor           = DIM;
            app.VizRow.BackgroundColor     = 'none';

            app.VizVal = uilabel(app.UIFigure);
            app.VizVal.Position            = [rX rowStart-24 rW rowH];
            app.VizVal.Text                = 'MATLAB GUI';
            app.VizVal.FontSize            = 10;
            app.VizVal.FontName            = FONT;
            app.VizVal.FontColor           = WHT;
            app.VizVal.BackgroundColor     = 'none';
            app.VizVal.HorizontalAlignment = 'right';

            % Computation
            app.CompRow = uilabel(app.UIFigure);
            app.CompRow.Position            = [cX+14 rowStart-48 lW rowH];
            app.CompRow.Text                = 'Computation';
            app.CompRow.FontSize            = 10;
            app.CompRow.FontName            = FONT;
            app.CompRow.FontColor           = DIM;
            app.CompRow.BackgroundColor     = 'none';

            app.CompVal = uilabel(app.UIFigure);
            app.CompVal.Position            = [rX rowStart-48 rW rowH];
            app.CompVal.Text                = 'Sig. Proc. Toolbox';
            app.CompVal.FontSize            = 9;
            app.CompVal.FontName            = FONT;
            app.CompVal.FontColor           = WHT;
            app.CompVal.BackgroundColor     = 'none';
            app.CompVal.HorizontalAlignment = 'right';

            % Divider 3 — full card width
            sepLbl = uilabel(app.UIFigure);
            sepLbl.Position            = [cX+14 cY+cH-316 cW-18 12];
            sepLbl.Text                = repmat('- ', 1, 34);
            sepLbl.FontSize            = 7;
            sepLbl.FontName            = FONT;
            sepLbl.FontColor           = [0.28 0.28 0.28];
            sepLbl.BackgroundColor     = 'none';

            % Upload button
            app.UploadLink = uibutton(app.UIFigure, 'push');
            app.UploadLink.Position        = [cX+14 cY+cH-350 cW-28 26];
            app.UploadLink.Text            = 'Upload Raw EEG Signal';
            app.UploadLink.FontSize        = 11;
            app.UploadLink.FontWeight      = 'bold';
            app.UploadLink.FontName        = FONT;
            app.UploadLink.FontColor       = ACC;
            app.UploadLink.BackgroundColor = [0.13 0.13 0.13];
            app.UploadLink.ButtonPushedFcn = createCallbackFcn(app, @LoadFileBtnPushed, true);

            % Arrow → label (no box — use uilabel not uibutton)
            app.ArrowBtn = uibutton(app.UIFigure, 'push');
            app.ArrowBtn.Position        = [cX+cW-36 cY+14 26 20];
            app.ArrowBtn.Text            = '→';
            app.ArrowBtn.FontSize        = 14;
            app.ArrowBtn.FontName        = FONT;
            app.ArrowBtn.FontColor       = [0.45 0.45 0.45];
            app.ArrowBtn.BackgroundColor = [0.13 0.13 0.13];
            app.ArrowBtn.ButtonPushedFcn = createCallbackFcn(app, @LoadFileBtnPushed, true);

            % ── Footer — bigger, higher ───────────────────────────────────
            app.ByLabel = uilabel(app.UIFigure);
            app.ByLabel.Position            = [cX cY-44 400 20];
            app.ByLabel.Text                = 'By Mohammad Azlaan & Aatika Asim';
            app.ByLabel.FontSize            = 12;
            app.ByLabel.FontName            = FONT;
            app.ByLabel.FontColor           = [0.38 0.38 0.38];
            app.ByLabel.BackgroundColor     = 'none';
            app.ByLabel.HorizontalAlignment = 'left';

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
            stopAndDeleteTimer(app);
            delete(app.UIFigure);
        end
    end

    methods (Static, Access = private)

        function out = pick_numeric(s, names, nc)
            out = [];
            for k = 1:numel(names)
                if isfield(s, names{k})
                    d = s.(names{k});
                    if isnumeric(d) && ismatrix(d) && size(d,2)==nc && size(d,1)>3
                        out = double(d); return;
                    end
                end
            end
        end

        function out = smooth_on_mesh(sig, F, n, iters)
            ii = [F(:,1);F(:,2);F(:,3);F(:,2);F(:,3);F(:,1)];
            jj = [F(:,2);F(:,3);F(:,1);F(:,1);F(:,2);F(:,3)];
            A  = sparse(ii, jj, 1, n, n);
            L  = spdiags(1./sum(A,2), 0, n, n) * A;
            out = sig;
            for k = 1:iters
                out = 0.5*out + 0.5*(L*out);
            end
        end

        function scrPts = project3D(ax, pts3)
            % Project Nx3 world coords to Nx2 normalised axes coords [0,1]
            % using the axes camera matrices.
            nP  = size(pts3,1);

            % Build camera transform (view * projection)
            % Get the camera parameters from the axes
            camPos  = ax.CameraPosition;
            camTgt  = ax.CameraTarget;
            camUp   = ax.CameraUpVector;
            camVA   = ax.CameraViewAngle;
            axPos   = ax.Position;   % normalised within figure

            % Forward / right / up unit vectors
            fwd = camTgt - camPos; fwd = fwd/norm(fwd);
            rgt = cross(fwd, camUp); rgt = rgt/norm(rgt);
            up2 = cross(rgt, fwd);

            % Translate to camera space
            rel = pts3 - camPos;
            cx  = rel * rgt';
            cy  = rel * up2';
            cz  = rel * fwd';

            % Orthographic projection (axes uses orthographic)
            % Scale by view angle and axes aspect
            scale = 1 / tand(camVA/2);
            sx = cx .* scale;
            sy = cy .* scale;

            % Map to [0,1] — centre is 0.5
            scrPts = [sx/(2) + 0.5, sy/(2) + 0.5];
        end

    end
end
