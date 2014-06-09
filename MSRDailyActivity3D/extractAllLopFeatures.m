function extractAllLopFeatures()
    num_actions = 16;
    conf = configDailyAcitity();
    for a  =1:conf.num_actions
        processSOPOneAction(a, conf);
    end
end
function processSOPOneAction(a, conf)
    num_env = conf.num_env;
    for s = 1:conf.num_subjects
        for e=1:conf.num_env
            a
            s
            e
            filename_depth = fullfile(conf.data_dir, sprintf('a%02d_s%02d_e%02d_depth.bin',a, ...
                                                             s,e));
            filename_skeleton = fullfile(conf.data_dir, sprintf('a%02d_s%02d_e%02d_skeleton.txt',a, ...
                                                              s,e));
            filename_points = fullfile(conf.data_dir, sprintf('a%02d_s%02d_e%02d_points.bin',a, ...
                                                              s,e));
            filename_out = fullfile(conf.feature_dir, sprintf('a%02d_s%02d_e%02d_features.mat',a, ...
                                                              s,e));
            if (conf.recompute_features||~exist(filename_out,'file'))
                shape_desc_all = [];
                 [depth, skeleton_mask] =  readDepthBin(filename_depth);
                 skeleton = readSkeleton(filename_skeleton);
                for j = 1: length(conf.joints_all)
                    shape_desc = computeSOPFeaturesSkeleton(depth,skeleton, conf.joints_all(j), conf);
                    shape_desc = reshape(shape_desc, [1 prod(size(shape_desc))]);
                    shape_desc_all(j,:) = shape_desc;
                end
                iSaveX(filename_out,shape_desc_all);
            end

        end
    end
end
