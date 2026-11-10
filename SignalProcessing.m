function risultati = calcolaSegnali (cartella) %Inserire il percorso della cartella contenente i segnali
files = dir(fullfile(cartella, '*.wav'));
risultati = cell(numel(files),1);
for i = 1:numel(files)
    file_audio = fullfile (cartella, files(i).name);
    [~, nome_file, ~] = fileparts(files(i).name);
    risultati{i} = Elaborato(file_audio, nome_file);
end
end