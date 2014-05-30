%% read skeleton.
clear;


skeleton_all = {};

conf = configDailyAcitity;
data_dir = conf.data_dir;

for a  =1:conf.num_actions
    for s = 1:conf.num_subjects
        for e=1:conf.num_env
            a
            s
            e
            filename = fullfile(data_dir, sprintf('a%02d_s%02d_e%02d_skeleton.txt',a, s,e));
            skeleton = readSkeleton(filename);
            skeleton_all{a, s, e} = skeleton;
        end
    end
end
save('skeletons.mat', 'skeleton_all');

%% Compute skeleton features.
recompute_features = 1;
for a = 1:conf.num_actions
    for s=1:conf.num_subjects
        for e=1:conf.num_env
            processOneSkeleton(a, s, e, recompute_features);
        end
    end
end