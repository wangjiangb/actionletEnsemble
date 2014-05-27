function motion_field=computeMotionField(depth, frame_diff)
% Compute motion field for the whole sequence of depth map.
% depth: depth map sequence.
% frame_diff: number of frame difference for computing motion field.
% motion_field: output motion field.
num_frame = size(depth,3);
motion_field = zeros(3, size(depth,1), size(depth, 2), num_frame-1);
for f=1:num_frame-frame_diff
    depth1 = reshape(depth(:,:,f), [size(depth,1) size(depth,2)]);
    depth2 = reshape(depth(:,:,f+frame_diff), [size(depth,1) size(depth,2)]);
    depth1_s = medfilt2(depth1,[5 5]);
    depth2_s = medfilt2(depth2,[5 5]);
    motion = ComputeMotion(depth1_s/20,depth2_s/20);
    motion_field(:,:,:,f) = motion;
end
