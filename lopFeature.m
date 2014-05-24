function feature = lopFeature(depth_img,center_x, center_y, center_z, num_bins,bin_size, ...
                              saturation_size, use_sigmoid)
% Compute LOP features around a point.
% depth_imge: a depth frame.
% center_x, center_y, center_z: the center for LOP feature computation.
% num_bins: number of bins along each dimension, in the order of x, y, z.
% feature: output features, a 3D features that contains the feature at each bin.
% saturation_size: used to control \delta in the sigmoid function or cut-off function.
if (nargin < 8)
    use_sigmoid = false
end

feature = zeros(num_bins);
for bx = -num_bins(1)/2:num_bins(1)/2-1
    lower_x = max(1, center_x + bx*bin_size(1)+1);
    higer_x  = min(size(depth_img,2),center_x + (bx+1)*bin_size(1));
    range_x = lower_x:higer_x;
    for by= -num_bins(2)/2:num_bins(2)/2-1
        lower_y = max(1,center_y + by*bin_size(2)+1);
        higer_y = min(size(depth_img,1), center_y + (by+1)*bin_size(2));
        range_y = lower_y:higer_y;
        low_z = center_z - bin_size(3)+1;
        high_z = center_z + bin_size(3);
        sub_bin = depth_img(range_y, range_x);
        points_sum = sum(sum(sub_bin>=low_z&sub_bin<= high_z));
        sub_x  = bx + num_bins(1)/2+1;
        sub_y  = by + num_bins(2)/2+1
        sub_z  = 1;
        feature(sub_x,sub_y,sub_z) = computeOneFeature(points_sum,saturation_size, use_sigmoid);
    end
end
end
function out = computeOneFeature(points_sum, saturation_size, use_sigmoid)
    if (use_sigmoid)
        out = 1 / (1 + exp(-saturation_size * points_sum));
    else
        out = min(points_sum, saturation_size);
    end
end