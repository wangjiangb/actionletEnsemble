function feature = compute_sop_features_skeleton(depth, skeleton,skeleton_id ,num_bins,bin_size, saturation_size)
 num_sample = 10;
 %bin_size = [5 5 100];
 size_feature = prod(num_bins);
 num_frames = size(depth,3);
  features_all = zeros(num_frames, size_feature);
 for f= 1:num_frames
     depth_current = reshape(depth(:,:,f),[240 320]);
     if (size(skeleton,1)<f)
         feature_right = zeros(num_bins);
     else
        skeleton_current = reshape(skeleton(f,2:2:end,:), [size(skeleton,2)/2 ...
                         size(skeleton,3 )]);
        center_x = int32(skeleton_current(skeleton_id, 1)*320);
        center_x = min(max(center_x, 1),320);
        center_y = int32(skeleton_current(skeleton_id, 2)*240);
         center_y = min(max(center_y, 1),240);
         center_z = int32(depth_current(center_y, center_x));
         if (isempty(find(skeleton_current, 1)))
             feature_right = zeros(num_bins);
         else
            feature_right = get_sop_feature(depth_current, center_x,center_y, ...
                                                   center_z, ...
                                                   num_bins, ...
                                                   bin_size, saturation_size);
         end
     end
      feature_right= reshape(feature_right, [ 1, size_feature]);
      %feature_right = fftn(feature_right);
      features_all(f,:) = [feature_right];
 end
 feature = abs(fft(features_all))/double(num_frames);
 feature = feature([1:num_sample/2 end-num_sample/2+1:end], :);
end
