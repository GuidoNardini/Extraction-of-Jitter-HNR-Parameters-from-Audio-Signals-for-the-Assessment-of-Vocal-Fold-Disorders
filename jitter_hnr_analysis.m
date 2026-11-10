function [plot_y, jitta_plot, HNR1_plot, HNR_plot, Q, jitta] = Elaborato (Fileaudio, nome_file)

[y, Fs] = audioread(Fileaudio); %Carico segnale su matlab, estraggo segnale y e frequenza di campionamento Fs

t = (0:length(y)-1)/Fs; % Vettore tempo
win = round(0.025*Fs); % Dimensione delle finestre
n_finestre = floor(length(y) / (win)); % Calcola il numero totale di segmenti

finestre = zeros(win, n_finestre); % Inizializza una matrice per immagazzinare le finestre

tempi_finestre = zeros(win, n_finestre); % Inizializza una matrice per immagazzinare i vettori tempo

%% Finestratura
% Taglia il segnale in finestre

for i = 1:n_finestre
    indice_inizio = (i - 1) * (win) + 1;
    indice_fine = min(length(y), indice_inizio + (win) - 1);
    finestre(:, i) = y(indice_inizio:indice_fine);
    tempi_finestre(:, i) = ((0:(length(finestre(:,i))-1)) / Fs) + (i-1)*win;
end

F0 = zeros(1,n_finestre); % Inizializza vettore F0

for j = 1:n_finestre
   F0 (:,j) = pitch(finestre(:,j), Fs,Method='CEP',WindowLength=win,OverlapLength=0); %Frequenza fondamentale per ogni finestra
end

%% Suddivisione in gruppi della F0

n_gruppi = floor(n_finestre / 10); % Numero gruppi per finestre
F0_1 = zeros(10, n_gruppi); % Inizializza matrice

for r = 1:n_gruppi
   for k = 1:10
       indice_finestra = (r - 1) * 10 + k;
       F0_1 (k,r) = pitch(finestre(:,indice_finestra), Fs,'Method','CEP','WindowLength',win,'OverlapLength',0); %Frequenza fondamentale per ogni gruppo
   end
end

%% Calcolo del Jitter

t0_y = 1./F0; %Periodo fondamentale calcolato da frequenza fondamentale
N = 2:length(t0_y); %Numero totale di periodi

jitta = zeros (1,n_finestre-1);
somma = 0;

for l = 1:n_finestre-1
    jitta_sum = (abs((t0_y(:,l+1)-(t0_y(:,l))))); %Calcola differenza periodi fondamentali
    somma = somma + jitta_sum; %Incremento del valore del numeratore
    jitta (:,l) = somma/(N(:,l)-1);%Misura di Jitta calcoalto in μs 
end

%% Metodo alternativo al calcolo del Jitter per gruppi

% t0_y1 = 1./F0_1; %Periodo fondamentale per ogni gruppo
% N1 = length (t0_y1); %Numero di periodi per ogni gruppo
% 
% jitta1 = (sum(abs(diff(t0_y1))))/(N1-1); % Jitta per ogni gruppo
% 
% jitter_y1 = zeros (1,n_gruppi);
% for h = 1:n_gruppi
%     jitter_y1 (:,h) = (jitta1(:,h)/mean(t0_y1(:,h)))*100; %Jitter per ogni gruppo
% end

%% Calcolo del Harmonic Noise to Ratio (HNR)

hnr1 = zeros (1,n_finestre);
for q = 1:n_finestre
    hnr1 (:,q) = HNR1 (finestre(:,q),Fs);
end

%% Calcolo quantile 95%
Q = quantile(jitta, 0.95);
nome = ['Valore di jitter tra stato transiente e stato a regime ', nome_file,':'];
disp(nome)
disp (Q);

%% Calcolo HNR da SNR e HarmonicRatio  
[~,noise] = snr(y,Fs);
hr = harmonicRatio (y,Fs,'OverlapLength',0);
HNR = 10*log10(hr/abs(noise));

figure;
tiledlayout (2,2)
nexttile
plot_y = plot(t,y);
title("Audio signal-",nome_file)
nexttile
jitta_plot = plot(jitta);
title("Jitter")
name = ['Valore jitter in μs ',nome_file,':'];
disp(name)
disp(jitta(end));
nexttile
HNR1_plot = plot (hnr1);
title("Harmonic noise to ratio")
nexttile
HNR_plot = plot (HNR);
title("Harmonic noise to ratio (Matlab Func)")

end

