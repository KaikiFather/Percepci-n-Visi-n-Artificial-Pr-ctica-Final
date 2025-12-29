function cortada = segmentarCeldas(img, offset)
    if nargin < 2
        offset = 3;
    end
    gray = im2gray(img);
    bin = gray > 20;
    bin = imcomplement(bin);
    relleno = imfill(bin,100000);
    relleno = imcomplement(relleno);
    relleno = imfill(relleno,'holes');

    [labeledImage, numLabels] = bwlabel(relleno);
    coloreo = label2rgb(labeledImage, 'jet', 'k', 'shuffle');
    figure, imshow(coloreo);
    cortada = cell(numLabels, 1);
    stats = regionprops(labeledImage, 'BoundingBox');
    for k = 1:numLabels
        bb = stats(k).BoundingBox;
        
        x = floor(bb(1)) + offset;
        y = floor(bb(2)) + offset;
        w = floor(bb(3)) - (offset * 2);
        h = floor(bb(4)) - (offset * 2);
        
        if w > 0 && h > 0
            rect = [x, y, w, h];
            cortada{k} = imcrop(gray, rect);
            imshow(imcrop(gray, rect));
        else
            warning('La celda %d es demasiado pequeña para el offset dado.', k);
            cortada{k} = []; 
        end
    end
end
%for k = 1:numLabels
%    imwrite(cortada{k}, sprintf('region%d.png', k));
%end

