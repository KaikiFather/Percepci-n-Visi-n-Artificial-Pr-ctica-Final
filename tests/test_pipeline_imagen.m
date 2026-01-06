%TEST_PIPELINE_IMAGEN Ejecuta el pipeline completo sobre una imagen de ejemplo.
addpath(genpath('codigo'));

if exist(fullfile('ejemplos','ejemplo_5x5.jpg'), 'file')
    entrada = fullfile('ejemplos','ejemplo_5x5.jpg');
elseif exist(fullfile('ejemplos','ejemplo_7x7.jpg'), 'file')
    entrada = fullfile('ejemplos','ejemplo_7x7.jpg');
else
    error('No se encontró una imagen de ejemplo en la carpeta ejemplos/.');
end

[img, origen] = capturarCuadricula(entrada);
fprintf('Imagen cargada desde %s\n', origen);

pre = preprocesarImagen(img);
[tabImgWarp, N] = detectarCuadricula(pre);
fprintf('Tamaño estimado: %d\n', N);

[lineasFilas, lineasColumnas] = detectarBordesCeldas(tabImgWarp, N);
celdas = segmentarCeldas(tabImgWarp, lineasFilas, lineasColumnas);
tablero = reconocerTablero(celdas);

tiledlayout(1,2);
nexttile; imshow(tabImgWarp); title('Tablero rectificado');
nexttile; montage(celdas, 'Size', [N N]); title('Celdas segmentadas');
