function compute_SOP_skeleton()
clear;
addpath(genpath('\\msr-arrays\scratch\msr-pool\11-H41\redmond\t-jiwa\code\lightspeed'));
num_actions = 16;

for a  =1:num_actions
    process_one_action(a,joint_list);
end
%cd ../processing/;
%test_global_joints;
%cd ../processDepth/
end
function process_one_action(a,joint_list)
    num_subject = 10;
    num_env = 2;
    recompute_features =1;
    for s = 1:num_subject
        for e=1:num_env
            a
            s
            e
            filename_depth = sprintf('../data/a%02d_s%02d_e%02d_depth.bin',a, ...
                               s,e);
            filename_skeleton = sprintf('../data/a%02d_s%02d_e%02d_skeleton.txt',a, ...
                               s,e);
            filename_points = sprintf('../data/a%02d_s%02d_e%02d_points.bin',a, ...
                               s,e);
            filename_out = sprintf('features/a%02d_s%02d_e%02d_features.mat',a, ...
                               s,e);
            if (recompute_features||~exist(filename_out,'file'))
                shape_desc_all = [];
                 [depth, skeleton_mask] =  ReadDepthBin(filename_depth);
                 skeleton = ReadSkeleton(filename_skeleton);
                for j = 1: length(joint_list)
                    shape_desc = compute_sop_features_skeleton(depth,skeleton,joint_list(j),[14 14 1], [6,6,80],3);
                    shape_desc = reshape(shape_desc, [1 ...
                                        prod(size(shape_desc))]);
                    shape_desc_all(j,:) = shape_desc;
                end
                iSaveX(filename_out,shape_desc_all);
            end

        end
    end
end
