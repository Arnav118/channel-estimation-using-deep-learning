% Step 1: Define OFDM Parameters
N_subcarriers = 72;      % Number of OFDM subcarriers
N_symbols = 1000;        % Number of OFDM symbols (Training samples)
cp_len = 16;             % Cyclic prefix length
SNR_dB = 15;             % Signal-to-Noise Ratio (dB)
mod_order = 4;           % QPSK Modulation
fs = 2.35e9;             % Carrier Frequency (2.35 GHz)
speed_kmh = 100;         % Train speed (300 km/h)
speed_mps = speed_kmh / 3.6; % Convert to m/s

% Step 2: Generate OFDM Signal with QPSK Modulation
data_bits = randi([0 mod_order-1], N_subcarriers, N_symbols);
modulated_data = pskmod(data_bits, mod_order, pi/4, 'gray'); % QPSK Modulation

% Perform IFFT to get OFDM symbols
ofdm_symbols = ifft(modulated_data, N_subcarriers);

% Add Cyclic Prefix
ofdm_tx = [ofdm_symbols(end-cp_len+1:end, :); ofdm_symbols]; % intercarrier interference

% Step 3: Apply Multipath Fading (Rician Channel)z
% Define Rician Channel Model (Ensure SISO)
rician_chan = comm.RicianChannel( ...
    'SampleRate', fs, ...
    'KFactor', 10, ...              % Rician K-factor
    'PathDelays', [0 1e-6 2e-6], ... % Multipath Delays
    'AveragePathGains', [0 -3 -6], ... % Path Gains
    'MaximumDopplerShift', speed_mps * (fs / 3e8), ... % Doppler Effect
    'FadingTechnique', 'Sum of sinusoids');  % Ensures smooth Doppler processing

% Reshape to match the channel requirements
ofdm_tx_reshaped = reshape(ofdm_tx, 1, []).';

% Pass OFDM Signal Through Channel (Ensure Correct Input Format)
ofdm_rx = rician_chan(ofdm_tx_reshaped);

% Reshape back to original format
ofdm_rx = reshape(ofdm_rx.', N_subcarriers + cp_len, []);

% Remove the Cyclic Prefix
ofdm_rx = ofdm_rx(cp_len + 1:end, :);

% Step 4: Add AWGN Noise
SNR_linear = 10^(SNR_dB/10);
ofdm_rx_noisy = awgn(ofdm_rx, SNR_dB, 'measured');

% Step 5: Extract Pilot Symbols for Channel Estimation
pilot_indices = 1:6:N_subcarriers;  % Example: Place pilots every 6 subcarriers
pilot_tx = modulated_data(pilot_indices, :);
pilot_rx = ofdm_rx_noisy(pilot_indices, :);

% Compute LS Channel Estimation
H_LS = pilot_rx ./ pilot_tx;  % Least Squares (LS) estimate

% Step 6: Save Data as CSV for Python
X_train = abs(H_LS);  % Input: Estimated channel magnitude
Y_train = abs(modulated_data);  % Target: True channel

X_train = double(X_train);
Y_train = double(Y_train);

% Save as CSV files
writematrix(X_train, 'X_train0.csv');  
writematrix(Y_train, 'Y_train0.csv');  

disp('Training dataset saved as X_train.csv and Y_train.csv');
