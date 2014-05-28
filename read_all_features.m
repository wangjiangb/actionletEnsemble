%% Read all the features for MSR-DailyActity dataset.
clear;
num_actions = 3;
num_subject = 10;
num_env = 2;

skeleton_all = {};

conf = configDailyAcitity;
data_dir = conf.data_dir;

for a  =1:num_actions
    for s = 1:num_subject
        for e=1:num_env
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
