function feature = getSopFeature(depth_img,center_x, center_y, ...
                                             center_z, num_bins,bin_size, ...
                                             saturation_size)
% Compute SOP features around the center.
  num_bins(3) =1;
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
              points_sum = sum(sum(sub_bin>=low_z&sub_bin<= ...
                                   high_z));
              sub_x  = bx + num_bins(1)/2+1;
              sub_y  = by + num_bins(2)/2+1;
              sub_z  = 1;
              feature(sub_x,sub_y,sub_z) = min(points_sum,saturation_size);
      end
  end
end