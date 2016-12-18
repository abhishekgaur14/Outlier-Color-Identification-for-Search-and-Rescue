

[Maha,Classify] = RXDetector(img,i_size,o_size)
imrgb = im2double(img);
cform = makecform('srgb2lab');
imlab = applycform(imrgb,cform);
imlabxL = imlab(:,:,2:3);
image = imlabxL;
Threshold = 60;
Horizontal = size(image,1);
Vertical = size(image,2);
boundary = floor(o_size/2);
Maha = zeros(Horizontal,Vertical);
guard_window = (o_size - i_size)/2 + 1;
Classify = false(Horizontal, Vertical);

for i=1:1:Horizontal
    for j=1:1:Vertical
        mean_vector = zeros(2,1); point = zeros(2,1);
        outer_block = image(max(i - boundary+1,1):min(i+boundary - 1,Horizontal),max(j- boundary+1,1):min(j+boundary-1,Vertical),:);            
        outer_block(guard_window:guard_window+i_size-1,guard_window:guard_window+i_size-1,:) = NaN;                  
        mean_vector(1) = nanmean(nanmean(outer_block(:,:,1)));mean_vector(2) = nanmean(nanmean(outer_block(:,:,2))); 
        cov_matrix = nancov(outer_block(:,:,1),outer_block(:,:,2));
        det = 1/(cov_matrix(1)*cov_matrix(4)-cov_matrix(3)*cov_matrix(2));
        invcov_matrix = det.*[cov_matrix(4), - cov_matrix(3); - cov_matrix(2), cov_matrix(1)];            
        point(1) = image(i,j,1); point(2) = image(i,j,2);            
        Maha(i,j) = (point-mean_vector)'*(invcov_matrix)*(point-mean_vector); 
    end
end

Classify = Maha>Threshold;

figure(1)
imshow(img);

figure(2)
surf(Maha)

figure(3)
imshow(Classify)
