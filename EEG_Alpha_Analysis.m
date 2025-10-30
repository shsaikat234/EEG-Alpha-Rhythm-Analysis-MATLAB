clc; clear; close all;

%% ===================== Load & Extract ============================
filename = 'YASH_4-L04.edf';         % <--EDF file
dataTT   = edfread(filename);        % timetable in R2025b

fs = 200;                            % sampling rate (Hz) – adjust if needed

% First channel -> numeric column vector (edfread often yields cell array)
eeg = dataTT{:,1};
eeg = vertcat(eeg{:});               % concatenate cells to one vector
t   = (0:numel(eeg)-1)/fs;           % time vector (s)

%% ===================== Part 1: Full-signal preprocessing ================
% 0.5–45 Hz band-pass
bpFilt = designfilt('bandpassiir', ...
    'FilterOrder', 6, ...
    'HalfPowerFrequency1', 0.5, ...
    'HalfPowerFrequency2', 45, ...
    'SampleRate', fs);

eeg_bp = filtfilt(bpFilt, eeg);

% 50 Hz notch (line-noise)
notch50 = designfilt('bandstopiir', ...
    'FilterOrder', 4, ...
    'HalfPowerFrequency1', 49, ...
    'HalfPowerFrequency2', 51, ...
    'DesignMethod', 'butter', ...
    'SampleRate', fs);

eeg_pre = filtfilt(notch50, eeg_bp);   % preprocessed = BP + Notch

% ---- FFT helper over preprocessed ----
[P1_pre, f_pre] = singleSidedFFT(eeg_pre, fs);

% ---- Plot Part 1 in ONE figure ----
figure('Name','Part 1: Raw → BP(0.5–45) → Notch 50 → FFT', 'Position',[100 100 1000 800]);

subplot(4,1,1);
plot(t, eeg,'r');
title('Raw EEG'); xlabel('Time (s)'); ylabel('\muV'); grid on;

subplot(4,1,2);
plot(t, eeg_bp,'b');
title('Band-pass 0.5–45 Hz'); xlabel('Time (s)'); ylabel('\muV'); grid on;

subplot(4,1,3);
plot(t, eeg_pre,'g');
title('Preprocessed (0.5–45 Hz + 50 Hz Notch)'); xlabel('Time (s)'); ylabel('\muV'); grid on;

subplot(4,1,4);
plot(f_pre, P1_pre);
xlim([0 60]); grid on;
title('FFT of Preprocessed EEG'); xlabel('Frequency (Hz)'); ylabel('Amplitude (\muV)');

%% ===================== Stage-wise alpha analysis ================
% Stage boundaries in seconds (inclusive start, exclusive end)
stages = struct( ...
    'name',   {'Eyes Closed','Mental Arithmetic','After Hyperventilation','Eyes Open'}, ...
    'tStart', {0,             10,                 42,                      56}, ...
    'tEnd',   {10,            42,                 56,                      66} );

% Alpha-band filter (8–13 Hz)
alphaFilt = designfilt('bandpassiir', ...
    'FilterOrder', 6, ...
    'HalfPowerFrequency1', 8, ...
    'HalfPowerFrequency2', 13, ...
    'SampleRate', fs);

% Safety: cap stage ends to signal duration
Tmax = (numel(eeg)-1)/fs;

% Store FFT results for global axis scaling
fftData = cell(1,numel(stages));
f_all   = cell(1,numel(stages));

for k = 1:numel(stages)
    % Compute sample indices from seconds
    i1 = sec2idx(stages(k).tStart, fs);
    i2 = sec2idx(min(stages(k).tEnd, Tmax), fs);  % cap to available time
    
    % Ensure indices valid
    i1 = max(1, min(i1, numel(eeg)));
    i2 = max(1, min(i2, numel(eeg)));
    if i2 < i1, [i1,i2] = deal(i2,i1); end

    seg = eeg(i1:i2);

    % Alpha-band filter the segment
    seg_alpha = filtfilt(alphaFilt, seg);

    % FFT of alpha-filtered segment
    [P1_seg, f_seg] = singleSidedFFT(seg_alpha, fs);

    fftData{k} = P1_seg;
    f_all{k}   = f_seg;
end

% ====== Normalize axis scaling ======
% X-axis (frequency) up to 60 Hz
xLim = [0 60];

% Y-axis: same max across all stage FFTs
yMax = max(cellfun(@(x) max(x), fftData));
yLim = [0 yMax*1.1];  % add 10% headroom

% ====== Plot with consistent scaling ======
figure('Name','Part 2: Alpha-band FFT by Stage', 'Position',[150 150 1100 800]);

for k = 1:numel(stages)
    subplot(4,1,k);
    plot(f_all{k}, fftData{k}); grid on;
    xlim(xLim); ylim(yLim);
    title(sprintf('%s (%.1f–%.1f s)', stages(k).name, stages(k).tStart, stages(k).tEnd));
    xlabel('Frequency (Hz)'); ylabel('Amplitude (\muV)');
end

%% ===================== Helper functions ================================
function idx = sec2idx(s, fs)
    idx = floor(s*fs) + 1;
end

function [P1, f] = singleSidedFFT(x, fs)
    x = x(:);
    N  = numel(x);
    Y  = fft(x);
    P2 = abs(Y/N);
    P1 = P2(1:floor(N/2)+1);
    if numel(P1) > 2
        P1(2:end-1) = 2*P1(2:end-1);
    end
    f  = fs*(0:floor(N/2))/N;
end
%% ===================== Part 3: Raw, Alpha, Alpha-RMS =====================
% Alpha filter already defined as alphaFilt (8–13 Hz)

% Apply to the whole EEG
eeg_alpha = filtfilt(alphaFilt, eeg);

% Compute RMS envelope of alpha
win = round(0.5*fs);          % 0.5-s RMS window
alpha_rms = sqrt(movmean(eeg_alpha.^2, win));

% Plot in one figure
figure('Name','Part 3: Raw vs Alpha vs Alpha-RMS','Position',[100 200 1200 600]);

subplot(3,1,1);
plot(t, eeg, 'r'); grid on;
title('Raw EEG'); xlabel('Time (s)'); ylabel('\muV');

subplot(3,1,2);
plot(t, eeg_alpha, 'Color', [0.5 0 0.5]); grid on;  % violet (RGB)
title('Alpha Band (8–13 Hz)'); xlabel('Time (s)'); ylabel('\muV');

subplot(3,1,3);
plot(t, alpha_rms, 'g','LineWidth',1.5); grid on;
title('Alpha RMS Envelope (0.5-s window)'); xlabel('Time (s)'); ylabel('RMS (\muV)');

%% ===================== Part 4: Feature Extraction =====================

% Define conditions as index ranges (replace with actual time ranges in sec)
condNames = {'Eyes closed (Control)','Mental arithmetic','Recovery','Eyes open'};

% Example: [start end] in seconds
conds = [
     0   10;   % Eyes closed (Control)
    10   42;   % Mental arithmetic
    42   56;   % Recovery from hyperventilation
    56   66];  % Eyes open
nCond = size(conds,1);

% Initialize results
EEG_std    = zeros(nCond,1);
Alpha_std  = zeros(nCond,1);
Alpha_RMSm = zeros(nCond,1);

for i=1:nCond
    idx = (t >= conds(i,1)) & (t <= conds(i,2));
    
    seg_eeg = eeg(idx);
    seg_alpha = eeg_alpha(idx);
    seg_alpha_rms = alpha_rms(idx);
    
    EEG_std(i)    = std(seg_eeg);
    Alpha_std(i)  = std(seg_alpha);
    Alpha_RMSm(i) = mean(seg_alpha_rms);
end

% Compute Alpha RMS difference relative to control (first condition)
Alpha_RMS_diff = Alpha_RMSm - Alpha_RMSm(1);

% Compute summary sign
Alpha_RMS_summary = strings(nCond,1);
for i=1:nCond
    if Alpha_RMS_diff(i) > 0
        Alpha_RMS_summary(i) = "+";
    elseif Alpha_RMS_diff(i) < 0
        Alpha_RMS_summary(i) = "-";
    else
        Alpha_RMS_summary(i) = "=";
    end
end

% Display results in table
resultsTable = table(condNames', EEG_std, Alpha_std, Alpha_RMSm, ...
    Alpha_RMS_diff, Alpha_RMS_summary, ...
    'VariableNames',{'Condition','EEG_std','Alpha_std','Alpha_RMS_mean','Alpha_RMS_diff','Alpha_RMS_summary'});

%% Show nicely
disp(resultsTable);
