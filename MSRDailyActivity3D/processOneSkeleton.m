function  processOneSkeleton(a,s,e, recompute_features)
% Compute the skeleton feature for one depth sequence.
% a, s, e: the action, subject, and enviornment id.
% recompute_features: if set 1 to 1, the feature is computed
% regardless of whether the feature file already exists.

% Hack for parsing parameters from command line if the function
% is compiled with Matlab compiler.
if (ischar(a)), a = str2num(a), end;
if (ischar(s)), s = str2num(s), end;
if (ischar(e)), e = str2num(e), end;
if (ischar(recompute_features)), recompute_features = str2num(recompute_features), end;

conf = configDailyAcitity();
data = load('skeletons.mat');
skeleton_all  = data.skeleton_all;


% The weights for the skeleton.
target_list = conf.target_list;
weight_list = conf.weight_list;
skeleton = skeleton_all{a,s,e};
num_frame = size(skeleton,1);
num_joint  = size(skeleton, 2);

angles = [];
num_samples  = 10;
avg_positions = [];

for f= 1:num_frame
    % Normalize the absolute positions.
    skeleton(f,2:2:num_joint,3) = skeleton(f,2:2:num_joint,3)*0.01;
    positions =[];
    % The odd dimension of the feature is relative skeleton positions.
    skeleton_relative = reshape(skeleton(f,1:2:num_joint,:),[num_joint/2,size(skeleton, 3)]);
    for j=1:length(conf.joints_all)
        position =  computePairwiseJointPositions(skeleton_relative,conf.joints_all(j), target_list)*weight_list(j);
        positions(:,j) =  position;
    end
    positions2 =[];
    % The even dimension of the feature is absolute skeleton positions.
    skeleton_absolute = reshape(skeleton(f,2:2:num_joint,:),[num_joint/2,size(skeleton, 3)]);
    for j=1:length(conf.joints_all)
        position = computePairwiseJointPositions(skeleton_absolute,conf.joints_all(j), target_list)*weight_list(j);
        positions2(:,j) =  position;
    end

    avg_position = mean(skeleton(f,2:2: ...
                                 num_joint,1:3));
    avg_position = reshape(avg_position, [1 3])*10;
    avg_position = avg_position(1:2);
    angles(f,:,:) = [positions ;positions2];
    avg_positions(f,:) = avg_position;
end

feature_current =[];
for j=1:length(conf.joints_all)
    angles_jt = angles(:,:,j);
    angles_jt = reshape(angles_jt,[size(angles_jt,1) ...
                        size(angles_jt,2)]);
    angles_jt = angles_jt';
    angle_cos_sin =fftPyramid(angles_jt,num_samples);
    angles_shift = circshift(angles_jt', 1)';
    angles_diff = angles_jt  - angles_shift;
    angles_diff = angles_diff(:,1:end-1);
    feature_diff = fftPyramid(angles_diff, ...
                               num_samples);
    feature_current(:,:,j) =[ angle_cos_sin feature_diff];
end
angles_jt =  avg_positions';
angle_cos_sin =fftPyramid(angles_jt,num_samples);
angles_shift = circshift(angles_jt', 1)';
angles_diff = angles_jt  - angles_shift;
angles_diff = angles_diff(:,1:end-1);
feature_diff = fftPyramid(angles_diff, num_samples);


feature = feature_current;
pos = [ angle_cos_sin feature_diff];
filename_out = fullfile(conf.feature_dir, sprintf('a%02d_s%02d_e%02d_skeleton.mat',a,s,e));
save(filename_out,'feature_current','pos');
