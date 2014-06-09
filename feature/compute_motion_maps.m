%% Compute the motion maps for the depth maps.
clear;
num_actions = 16;
conf = configDailyAcitity;
parfor a  =1:conf.num_actions
    computeMoitonForOneAction(a, conf);
end
function computeMoitonForOneaction(a,conf, recompute_features)
    if (nargin < 3)
        recompute_features = 1
    end
    parfor s = 1:conf.num_subject
        for e=1:conf.num_env
            a
            s
            e
            filename_depth = fullfile(conf.data_dir, sprintf('a%02d_s%02d_e%02d_depth.bin',a, s,e));
            filename_skeleton = fullfile(conf.data_dir, sprintf('a%02d_s%02d_e%02d_skeleton.txt',a, s,e));
            filename_points = fullfile(conf.data_dir, sprintf('a%02d_s%02d_e%02d_points.bin',a, s,e));
            filename_out = fullfile(conf.data_dir, sprintf('features/a%02d_s%02d_e%02d_motionmap.mat',a, s,e));
            if (recompute_features||~exist(filename_out,'file'))
                motion_desc_all = [];
                [depth, skeleton_mask] =  ReadDepthBin(filename_depth);
                skeleton = readSkeleton(filename_skeleton);
                motion_field = computeMotionField(depth,5);
                iSaveX(filename_out,motion_field);
            end

        end
    end
end
