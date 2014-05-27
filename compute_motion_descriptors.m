clear;
conf = configDailyAcitity();
parfor a  =1:conf.num_actions
    computeMotionFeatures(a,conf);
end
cd ../processing/;
cd ../processDepth/
end
function computeMotionFeatures(a,  conf , recompute_features)
    if (nargin < 3)
        recompute_features = 1
    end
    for s = 1:conf.num_subject
        for e=1:conf.num_env
            a
            s
            e
            filename_depth = fullfile(conf.data_dir, sprintf('a%02d_s%02d_e%02d_depth.bin',a, s,e));
            filename_skeleton = fullfile(conf.data_dir, sprintf('a%02d_s%02d_e%02d_skeleton.txt',a, s,e));
            filename_motion_field = fullfile(conf.data_dir, sprintf('features/a%02d_s%02d_e%02d_motionmap.mat',a, s,e));
            filename_out = fullfile(conf.feature_dir, sprintf('features/a%02d_s%02d_e%02d_motion.mat',a,s,e));
            if (recompute_features||~exist(filename_out,'file'))
                motion_desc_all = [];
                 [depth, skeleton_mask] =  ReadDepthBin(filename_depth);
                 skeleton = ReadSkeleton(filename_skeleton);
                 motion_field =load(filename_motion_field);
                 motion_field = motion_field.fea;
                for j = 1: length(conf.joint_list)
                    motion_desc = ...
                        compute_motion_features_skeleton(depth, ...
                                                         motion_field, skeleton,conf.joint_list(j),[20,20,100]);
                    motion_desc = reshape(motion_desc, [1 ...
                                        prod(size(motion_desc))]);
                    motion_desc_all(j,:) = motion_desc;
                end
                iSaveX(filename_out,motion_desc_all);
            end

        end
    end
end
