img = imread('numops.png');
gray = rgb2gray(img);
figure, imshow(gray);

bin = gray > 250;
figure, imshow(bin);
bin = imcomplement(bin);
relleno = imfill(bin, 'holes');
figure, imshow(relleno);
[labeledImage, numLabels] = bwlabel(relleno);
coloreo = label2rgb(labeledImage, 'jet', 'k', 'shuffle');
figure, imshow(coloreo);
cortada = cell(numLabels, 1);
offset = 3;
for k = 1:numLabels
    tamanno = regionprops(labeledImage == k, 'BoundingBox').BoundingBox;
    tamanno(1) = floor(tamanno(1))+offset;
    tamanno(2) = floor(tamanno(2))+offset;
    tamanno(3) = floor(tamanno(3))-offset*2;
    tamanno(4) = floor(tamanno(4))-offset*2;
    cortada{k} = imcrop(gray, tamanno);
end
for k = 1:numLabels
    imwrite(cortada{k}, sprintf('region%d.png', k));
end

