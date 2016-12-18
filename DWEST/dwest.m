im_rgb = imread('1.png');

im_rgb = im2double(im_rgb);
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

% prebuild masks
masks = {};
masks_inv = {};
for w_size = 1:2:(w_max_size - 2)
	masks{end + 1} = reshape(sq_mask(w_max_size, 1, w_size), [], 1);
	masks_inv{end + 1} = ~masks{end};
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
		
		% for each mask
		for k = 1:num_masks
			iw = win(masks{k}, :);
			ow = win(masks_inv{k}, :);
    
			% inner window
            if 1 < k
                iw_mean = mean(iw, 1);
                iw_centered = bsxfun(@minus, iw, iw_mean);
            else
                iw_mean = iw;
                iw_centered = zeros(size(iw));
            end
			
            % outer window
			ow_mean = mean(ow, 1);
			ow_centered = bsxfun(@minus, ow, ow_mean);
    
			% difference in covariance
            diff_cov = ((iw_centered' * iw_centered) - (ow_centered' * ow_centered)) / (size(ow_centered, 1) - 1);
    
			% eigenvalues difference in covariance
			[e_vec, e_val] = eig(diff_cov);

			% eigen vectors associated with positive value times mean
			d = max(d, abs(sum((ow_mean - iw_mean) * e_vec(:, diag(e_val) > 0))));
		end
		
		im_result(j, i) = d;
	end
end

% final_img = im_result > 10;
% imshow(final_img);
% imwrite(final_img, '6_output.png');
% imwrite(im_result, '6_result.png');
% 
% imshow(final_img);