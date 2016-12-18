im_rgb = imread('1.png');


%DWEST Perform the DWEST algorithm on img.

% largest window size (must be odd)
w_max_size = 11;


cf = makecform('srgb2lab');
img = applycform(im_rgb, cf);

img = img(:,:,2:3);

% image information
[height, width, channels] = size(img);

% return image
im_result = zeros(height, width);

% create inner window (size 1)
iw_size = 1;
mask_iw = reshape(sq_mask(w_max_size, 1, iw_size), [], 1);

% prebuild other masks
masks = {};
for w_size = (iw_size + 2):2:w_max_size
	masks{end + 1} = reshape(sq_mask(w_max_size, 1, w_size, w_size - 2), [], 1);
end
num_masks = length(masks);

% pad image
border = (w_max_size - 1) / 2;
pad_img = pad_image_symmetric(img, border);
disp('Padding Done');
for i = 1:width
	for j = 1:height
		d = nan;
		
		% reshape window
		win = reshape(pad_img(j:j + w_max_size - 1, i:i + w_max_size - 1, :), [], channels);
		
		% get inner window mean
		iw_mean = mean(win(mask_iw, :), 1);
        
        % last outer window to pass into loop
        ow_mean = mean(win(masks{1}, :), 1);
		
		% for each mask
		for k = 2:num_masks
			% last outer window is new middle window
            mw_mean = ow_mean;
            
            % new outer window
            ow_mean = mean(win(masks{k}, :), 1);
	
            % use OSP based on outer window to project both inner and middle window
            p_outer = osp(ow_mean);
            cd = (iw_mean * p_outer * iw_mean') + (mw_mean * p_outer * mw_mean');
            if 0 <= cd
                d = max(d, sqrt(cd));
            end
		end
		
		im_result(j, i) = d;
    end
end

final_img = im_result > 10;
imshow(final_img);
imwrite(final_img, '1_output.png');
imwrite(im_result, '1_result.png');

imshow(im_result);