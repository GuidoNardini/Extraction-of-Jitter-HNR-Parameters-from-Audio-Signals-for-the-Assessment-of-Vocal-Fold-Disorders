function HNR = HNR1(y, Fs)
    autocorrelazione = xcorr(y); % Autocorrelazione del segnale
    
    [~, indice_max] = max(autocorrelazione); % Picco dell'autocorrelazione
    
    energia_vocale = sum(y.^2); % Energia del segnale vocale
   
    finestra_senza_voce = autocorrelazione(indice_max:end);% Calcola l'energia del rumore da finestra senza voce
    
    energia_rumore = mean(finestra_senza_voce);
    
    HNR = 10 * log10(energia_vocale / energia_rumore); % Calcola l'HNR
end
