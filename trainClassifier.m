function trainClassifier()
    conf = configDailyAcitity();
    all_features = {};
    for  a = 1:conf.num_actions
        for s = 1:conf.num_subjects
            for e =  1:conf.num_env
                skeleton_file = fullfile(conf.feature_dir, sprintf('a%02d_s%02d_e%02d_skeleton.mat',a,s,e));
                lop_file = fullfile(conf.feature_dir, sprintf('a%02d_s%02d_e%02d_features.mat',a, s,e));
                skeleton_feature = load(skeleton_file);
                skeleton_feature = [normalizeFeature(skeleton_feature.feature_current(:)); ...
                                    normalizeFeature(skeleton_feature.pos(:))];
                lop_feature = load(lop_file);
                lop_feature = lop_feature.fea;
                all_features{a, s, e}= [skeleton_feature(:); normalizeFeature(lop_feature(:))];
            end
        end
    end
    training_features = [];
    testing_features = [];
    training_labels = [];
    testing_labels = [];
    for  a = 1:conf.num_actions
        for e =  1:conf.num_env
            for s = conf.train_sub
                training_features = [training_features all_features{a, s, e}];
                training_labels = [training_labels a];
            end
            for s= conf.test_sub
                testing_features = [testing_features all_features{a, s, e}];
                testing_labels = [testing_labels a];
            end
        end
    end
    %% train and evalating a svm model on the features
    c =.002;
    options = ['-c ' num2str(c)];
    decisions = zeros(length(testing_labels), conf.num_actions);
    model = train(double(training_labels'), sparse(training_features'), options);
    [predicted_label, accuracy2, decision_values] = predict(double(testing_labels'), sparse(testing_features'), model);
end
