%% rotating_brain_shfd.m
% Minimalistic rotating brain with hover-reveal EEG electrodes.
% Close the figure window to stop.
%
% Usage:  rotating_brain_shfd

clear; clc; close all;

%% ── 1. Load Colin27 ──────────────────────────────────────────────────────
colin_file = "/Users/aatikashaikh/project_gui/documents/eeglab2026.0.0/functions/supportfiles/head_modelColin27_5003_Standard-10-5-Cap339.mat";
S = load(colin_file);

%% ── 2. Cortex surface ────────────────────────────────────────────────────
cortex = S.cortex;
V = pick_numeric(cortex, {'pos','pnt','vert','vertices','Vertices','coords'}, 3);
F = pick_numeric(cortex, {'tri','face','faces','Faces','triangles','elements'}, 3);
if isempty(V) || isempty(F)
    V = pick_numeric(S.scalp, {'pos','pnt','vert','vertices','Vertices','coords'}, 3);
    F = pick_numeric(S.scalp, {'tri','face','faces','Faces','triangles','elements'}, 3);
end
V = double(V); F = double(F);
if min(F(:)) == 0, F = F + 1; end

%% ── 3. Electrodes ────────────────────────────────────────────────────────
elec_xyz    = double(S.channelSpace);
elec_labels = S.labels;
n_elec      = size(elec_xyz,1);
elec_colors = hsv(n_elec);
HOVER_RADIUS = range(elec_xyz(:,1)) * 0.07;

%% ── 4. Depth shading ─────────────────────────────────────────────────────
Vc    = V - mean(V,1);
depth = Vc * [0.2; 0.1; 0.8];
depth = smooth_on_mesh(depth, F, size(V,1), 6);
depth = (depth-min(depth))./(max(depth)-min(depth));
grey_vals = 0.72 - 0.28.*depth;

%% ── 5. Figure & brain ────────────────────────────────────────────────────
fig = figure('Color',[0.08 0.08 0.08], ...
             'Name','Brain', ...
             'NumberTitle','off', ...
             'MenuBar','none', ...
             'ToolBar','none', ...
             'Units','pixels', ...
             'Position',[100 100 900 700]);

ax = axes('Parent',fig, ...
          'Color',[0.08 0.08 0.08], ...
          'XColor','none','YColor','none','ZColor','none');
hold(ax,'on');

trisurf(F, V(:,1), V(:,2), V(:,3), grey_vals, ...
    'EdgeColor','none', ...
    'FaceColor','interp', ...
    'FaceLighting','gouraud', ...
    'AmbientStrength',  0.18, ...
    'DiffuseStrength',  0.72, ...
    'SpecularStrength', 0.30, ...
    'SpecularExponent', 18);

cmap = gray(256); cmap = cmap(80:230,:);
colormap(ax,cmap); caxis(ax,[0 1]);

light('Position',[ 1.5  0.5  2  ],'Style','infinite','Color',[1.0 1.0 1.0]);
light('Position',[-1.0 -0.3  0.5],'Style','infinite','Color',[0.25 0.25 0.28]);

axis(ax,'equal','off','tight');
view(ax,[-68,16]); camzoom(ax,1.22);

%% ── 6. Electrode dots + labels (invisible by default) ────────────────────
h_dots  = gobjects(n_elec,1);
h_texts = gobjects(n_elec,1);
for i = 1:n_elec
    c = elec_colors(i,:);
    h_dots(i) = scatter3(ax, elec_xyz(i,1), elec_xyz(i,2), elec_xyz(i,3), ...
        60, c, 'filled', 'MarkerEdgeColor','w', 'LineWidth',0.8, 'Visible','off');
    h_texts(i) = text(ax, elec_xyz(i,1), elec_xyz(i,2), elec_xyz(i,3), ...
        ['  ' elec_labels{i}], 'Color',c, 'FontSize',9, 'FontWeight','bold', 'Visible','off');
end

%% ── 7. Store ALL shared state in fig.UserData ────────────────────────────
fig.UserData = struct( ...
    'ax',          ax, ...
    'az',          -68, ...
    'h_dots',      h_dots, ...
    'h_texts',     h_texts, ...
    'elec_xyz',    elec_xyz, ...
    'n_elec',      n_elec, ...
    'HOVER_RADIUS',HOVER_RADIUS);

%% ── 8. Hover callback (reads everything from fig.UserData) ───────────────
fig.WindowButtonMotionFcn = @on_hover;

%% ── 9. Timer rotation ────────────────────────────────────────────────────
t = timer('ExecutionMode','fixedRate','Period',0.033);
t.UserData = fig;          % just store the fig handle
t.TimerFcn = @(tmr,~) rotate_step(tmr);
t.StopFcn  = @(tmr,~) delete(tmr);
fig.DeleteFcn = @(~,~) safe_stop(t);
start(t);
fprintf('Rotating... hover over brain to reveal electrodes. Close window to stop.\n');

%% ════════════════════════════════════════════════════════════════════════
%%  CALLBACKS & HELPERS  (all standalone — no shared workspace variables)
%% ════════════════════════════════════════════════════════════════════════

function on_hover(fig_h, ~)
    ud = fig_h.UserData;
    cp    = get(ud.ax, 'CurrentPoint');   % 2x3 ray
    ray_o = cp(1,:);
    ray_d = cp(2,:) - cp(1,:);
    ray_d = ray_d ./ max(norm(ray_d), 1e-9);
    for ii = 1:ud.n_elec
        oe      = ud.elec_xyz(ii,:) - ray_o;
        t_proj  = dot(oe, ray_d);
        closest = ray_o + t_proj .* ray_d;
        dist    = norm(ud.elec_xyz(ii,:) - closest);
        vis = 'off';
        if dist < ud.HOVER_RADIUS && t_proj > 0
            vis = 'on';
        end
        set(ud.h_dots(ii),  'Visible', vis);
        set(ud.h_texts(ii), 'Visible', vis);
    end
    drawnow limitrate;
end

function rotate_step(tmr)
    fig_h = tmr.UserData;
    if ~ishandle(fig_h), stop(tmr); return; end
    ud    = fig_h.UserData;
    ud.az = ud.az + 0.4;
    fig_h.UserData = ud;
    view(ud.ax, [ud.az, 16]);
    drawnow limitrate;
end

function safe_stop(tmr)
    try
        if isvalid(tmr) && strcmp(tmr.Running,'on'), stop(tmr); end
    catch, end
end

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
    A  = sparse(ii,jj,1,n,n);
    L  = spdiags(1./sum(A,2),0,n,n)*A;
    out = sig;
    for k = 1:iters, out = 0.5*out + 0.5*(L*out); end
end
