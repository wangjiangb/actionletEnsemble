%% Read all the fetures for MSR-DailyActity dataset.
clear;
num_actions = 3;
num_subject = 10;
num_env = 2;

skeleton_all = {};
shape_all  = {};

data_dir = './data/';

for a  =1:num_actions
    for s = 1:num_subject
        for e=1:num_env
            a
            s
            e
            filename = fullfile(data_dir, sprintf'a%02d_s%02d_e%02d_skeleton.txt',a, s,e));
            skeleton = ReadSkeleton(filename);
            skeleton_all{a, s, e} = skeleton;
            filename_depth = fullfile(data_dir, sprintf('a%02d_s%02d_e%02d_depth.bin',a, s,e);
            filename_points = fullfile(data_dir, sprintf('a%02d_s%02d_e%02d_points.bin',a, s,e));
            shape_desc = extractShapeDescriptor(filename_depth,filename_points);
            shape_all{a,s,e} = shape_desc;

        end
    end
end
save skeletons.mat
