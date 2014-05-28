conf = configDailyAcitity;
for a = 1:conf.num_actions
    for s=1:conf.num_subjects
        for e=1:conf.num_env
            processOneSkeleton(a, s, e, 1);
        end
    end
end