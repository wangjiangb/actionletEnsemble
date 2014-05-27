dataconf;
% num_dic = 300;
% for f=1:num_dic
%     dir_name = sprintf('\\\\msr-arrays/scratch/msr-pool/L25-dev21/data/rgbd-dataset/%s',dirs{f});
%     for no_obj = 1:num_files(1,f)
%         parfor no_obj_instance = 1:num_files(no_obj+1,f)
%             file_name_prefix = sprintf('%s/%s_%d_%d',dir_name,objs{f},no_obj,no_obj_instance);
%             file_color = sprintf('%s_crop.png',file_name_prefix);
%             file_depth = sprintf('%s_depthcrop.png',file_name_prefix);
%             file_mask = sprintf('%s_maskcrop.png',file_name_prefix);
%             if (~exist(file_color,'file')||~exist(file_depth,'file')||~exist(file_mask,'file'))
%                 continue;
%             end
%             feature_name = sprintf('feature_shape/shape_%d_%d_%d.mat',f,no_obj,no_obj_instance);
%             if (~exist(feature_name,'file'))
%                 feature = compute_sop_features(file_depth, file_color, file_mask,[10 10 20],[6 6 2],50);
%                 %feature  = fftn(feature);
%                 iSaveX(feature_name,feature);
%             end
%         end
%     end    
% end
%% computer features,final
features = [];
labels = []
fea_count = 1;
for f=1:282    
    for no_obj = 1:num_files(1,f)
        for no_obj_instance = 1:num_files(no_obj+1,f)
            feature_name = sprintf('feature_shape/shape_%d_%d_%d.mat',f,no_obj,no_obj_instance);
            if (~exist(feature_name,'file'))
                continue;
            end
            data = load(feature_name);
            feature = data.fea;          
            feature = reshape(feature,[ size(feature,1)*size(feature,2)*size(feature,3) 1]);
            features(:,fea_count)= feature;
            labels(fea_count) = count(f);
            fea_count = fea_count+1
        end
    end
end

labels_training =labels(1:2:end);
features_training = features(:,1:2:end);
labels_test =labels(2:2:end);
features_test = features(:,2:2:end);

%% train a svm
  c =1;
  %' -s 0 -t 2 -d 1 -g 0.08'
  options = ['-c ' num2str(c) ];
    model = train(double(labels_training'), sparse(features_training'), options);
   [predicted_label, accuracy2, decision_values] = predict(double(labels_test'), sparse(features_test'), model);
save result2
