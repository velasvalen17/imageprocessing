%% Segmentación de fémur en imagen de US %%
% Introducir el nombre de la imagen original.
im_o = imread('crop1.jpg');
im = histeq(im_o(:,:,2));

% Antonio se enajena

se = strel('square', 10);
Io = imopen(im, se);
% figure
% imshow(Io), title('Opening (Io)')

Ie = imerode(im, se);
Iobr = imreconstruct(Ie, im);
% figure
% imshow(Iobr), title('Opening-by-reconstruction (Iobr)')

Ioc = imclose(Io, se);
% figure
% imshow(Ioc), title('Opening-closing (Ioc)')

Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
% figure
% imshow(Iobrcbr), title('Opening-closing by reconstruction (Iobrcbr)')

fgm = imregionalmax(Iobrcbr);
fgm = imfill(fgm,'holes');
% figure
% imshow(fgm), title('Regional maxima of opening-closing by reconstruction (fgm)')

L = bwlabel(fgm);
prop = regionprops(L,{'Area','BoundingBox'});

area = zeros(1,length(prop));
for i = 1:length(prop)
    area(i) = prop(i).Area;
end

% % Los niveles LB (por abajo) y UB (por arriba) se deben cambiar en
% % función de la imagen, ya que los valores que valen para una, pueden no
% % ser los adecuados para otra imagen distinta. Con esto, eliminamos las
% % regiones no deseadas de la imagen binaria previa para quedarnos solo con
% % la región de interés.

LB = 1800;
UB = max(area);
im_seg = xor(bwareaopen(fgm,LB),  bwareaopen(fgm,UB));
figure
imshow(im_seg), title('Segmented image')

% Calculamos el borde de la imagen segmentada, y la distancia entre los
% puntos extremos del fémur.
borde = bwperim(im_seg);
[x,y] = find(borde);
figure 
imshow(im_o+uint8(borde)*255), title('Original image with segmentation edge')

% La distancia se calcula basandose en la suposición de que el fémur está
% perfectamente segementado y que los puntos (min(x), min(y)) y
% (max(x),max(y)) corresponden de forma aproximada con los puntos extremos
% del fémur. Aproximadamente, 31.875 píxeles corresponden a 1 cm en las imágenes.
d = ((sqrt((max(x)-min(x))^2+(max(y)-min(y))^2))*10)/31.875530110263;
fprintf('Longitud: %3.1f mm \n',d);