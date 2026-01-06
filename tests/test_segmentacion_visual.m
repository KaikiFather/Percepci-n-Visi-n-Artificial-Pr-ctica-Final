%TEST_SEGMENTACION_VISUAL Genera un montaje de celdas segmentadas y lo guarda en datos/procesados.
addpath(genpath('codigo'));

if ~exist('datos/procesados', 'dir'); mkdir('datos/procesados'); end

if exist(fullfile('ejemplos','ejemplo_5x5.jpg'), 'file')
    entrada = fullfile('ejemplos','ejemplo_5x5.jpg');
else
    error('No se encontró una imagen de ejemplo en la carpeta ejemplos/.');
end

[img, ~] = capturarCuadricula(entrada);
pre = preprocesarImagen(img);
[tabImgWarp, N] = detectarCuadricula(pre);
[lineasFilas, lineasColumnas] = detectarBordesCeldas(tabImgWarp, N);
celdas = segmentarCeldas(tabImgWarp, lineasFilas, lineasColumnas);

h = figure('Visible', 'off');
montage(celdas, 'Size', [N N]);
title(sprintf('Celdas segmentadas N=%d', N));

rutaSalida = fullfile('datos','procesados','segmentacion_montage.png');
saveas(h, rutaSalida);
fprintf('Montaje guardado en %s\n', rutaSalida);
