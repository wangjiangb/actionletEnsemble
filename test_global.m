clear;
load result;
addpath ../drtoolbox;
addpath ../drtoolbox/techniques/;
features = [];
feature_per_class={};
array_size = 1;
datacf.numOfActions = 4;

bodycf.test = [1 2 18 20];
subList = [1 3 5 7 9];
test_subList = [2 4 6 8 10];
subList_all = [1 2 3 4 5 6 7 8 9 10];
actList_as1 = [2 3 5 6 10 13 18 20];
actList_as2 = [1 4 7 8 9 11 14 12];
actList_as3 = [6 14 15 16 17 18 19 20];
actList_all = [1 2 3  4 5 6 7 8 9 10 11 12 13 14 15 16 17  18 19 20];
actList_test = [2 3 5];
actList = actList_all; 
datacf.trainSamples(subList,actList,[1 2 3]) = 1;
datacf.testSamples(test_subList,actList,[1 2 3]) = 1;
%% remove abnormal samples
% action set one
datacf.trainSamples(3,4,1)=0;
datacf.trainSamples(4,7,1) = 0;
 datacf.trainSamples([6 9],13,1) = 0;
  datacf.trainSamples([2 6 7],20,1) = 0;
  datacf.trainSamples([2 6 8 9 10],13,2)=0;
  datacf.trainSamples([2 8],20,2) = 0;
   datacf.trainSamples([2 6 9],13,3)=0;
   %datacf.testSamples([2 6 9],13,3)=0;
   %datacf.trainSamples([2 7 8],20,3)=0;
   datacf.trainSamples(6, 5, 3) =0;
   datacf.testSamples(6, 5, [3]) =0;
   datacf.trainSamples(4, 6, [1 2 3]) =0;
   datacf.testSamples(4, 6, [1 2 3]) =0;
     datacf.trainSamples(4, 4, [1 2 3]) =0;
   datacf.testSamples(4, 4, [1 2 3]) =0;
      datacf.trainSamples(6, 6, 3) =0;
   datacf.testSamples(6,6,3) =0;

% % action set 2
 datacf.trainSamples(3,2,2)=0;
  datacf.testSamples(3,2,2)=0;
 datacf.trainSamples(4,7,1)=0;
 datacf.testSamples(4,7,1)=0;
 datacf.trainSamples(3,14,1)=0;
  datacf.testSamples(3,14,1)=0;


% action set 3
datacf.trainSamples(3,14,1) = 0;
datacf.testSamples(3,14,1) = 0;
datacf.trainSamples([2 6 7], 20,1) = 0;
datacf.trainSamples([2 8], 20,2) = 0;
datacf.trainSamples([2 7 8], 20,3) = 0;
datacf.testSamples([10], 20,3) = 0;

num_samples =12;
num_actions = 20;
for a=1: num_actions
    for s =1:datacf.numOfSubjects    
        nos = datacf.numOfSamples(s,a);
        if (nos == 0)
            continue;
        end
         for e=1:nos       
            angles = angles_all{s,a,e};
            %if (datacf.trainSamples(s,a,e) ~=0)
            %    angles = circshift(angles',24)';
            %end
%             indx = size(angles,2);
%             for k=1:size(angles,2)
%                 if (isnan(angles(1,k))) 
%                     indx = k-1;
%                     break;
%                 end                
%             end            
%             indx
            if (size(angles,1)==0)
                continue;
            end            
            angle_cos_sin =fft_feature(angles,num_samples);            
            angles_shift = circshift(angles', 1)';
            angles_diff = angles  - angles_shift;
            angles_diff = angles_diff(:,1:end-1);
            feature_diff = fft_feature(angles_diff, num_samples);
            feature_per_class{s, a, e} =[ angle_cos_sin ; feature_diff];
            s
            a
            e                        
        end
    end
end

%[cx, see] = vgg_kmeans(features, 100);
%cx2 = full(sum(cx.*cx, 1));
% %scatter(d(1:size(features,2),1),d(1:size(features,2),2),'b'); hold on
% scatter(d(1:1519,1),d(1:1519,2),'y'); hold on
% scatter(d(1520:size(features,2),1),d(1520:size(features,2),2),'r'); hold on
% scatter(d(size(features,2)+1:end,1),d(size(features,2)+1:end,2),'b');
 % perform quantization
training_count = 1;
test_count = 1;
features_histogram =[];
labels = [];
for a=1: num_actions
    for s =1:datacf.numOfSubjects            
        nos = datacf.numOfSamples(s,a);
        if (nos == 0)
            continue;
        end
        for e=1:nos 
            feature = feature_per_class{s, a, e};
            histogram = reshape(feature, [1 size(feature,1)* ...
                                size(feature,2)]);
            if (size(feature,1)==0)
                continue;
            end            
            if (datacf.trainSamples(s,a,e) ~=0)
                features_histogram_training(:,training_count) = histogram;
                labels_training(training_count) = a;
                training_count = training_count +1;
            end
            if (datacf.testSamples(s,a,e) ~=0)
                features_histogram_test(:,test_count) = histogram;
                labels_test(test_count) = a;
                test_count = test_count +1;
            end
        end
    end
end
clear feature_per_class
%[mappedX, mapping] = pca(features_histogram_training',400);
%mappedTest = features_histogram_test'*mapping.M;
%features_histogram_training = mappedX';
%features_histogram_test = mappedTest';

%% train a svm
  c =.002;
  %' -s 0 -t 2 -d 1 -g 0.08'
  options = ['-c ' num2str(c) ];
  decisions = zeros(length(labels_test),datacf.numOfActions);
    model = train(double(labels_training'), sparse(features_histogram_training'), options);
    [predicted_label, accuracy2, decision_values] = predict(double(labels_test'), sparse(features_histogram_test'), model);

save result2

% %% use correlation coefficients
% error= 0;
% for i =1:length(labels_test)
%     max_value =0;
%     for j=1:length(labels_training)
%         coff_corr = max(xcorr(features_histogram_test(:,i), ...
%                               features_histogram_training(:,j) ,'coef'));
%         if (coff_corr>max_value)
%             max_value = coff_corr;
%             prediction =labels_training(j);
%         end        
%     end
%     [prediction labels_test(i)]
%      if (prediction~=labels_test(i))
%          error = error+1;
%      end        
% end
% error/length(labels_test)

%% use sparse coding for training
% addpath ../sparse_coding/
% for a =1:num_actions
%     training_matrix{a} = features_histogram_training(:, ...
%                                                      find(labels_training==a));    
% end
% error  =0;
% for i =1:length(labels_test)
%     min = 100000000000;
%     for a =1:num_actions
%         A = training_matrix{a}'*training_matrix{a}+1e-6*eye(size(training_matrix{a},2));
%         Q = -(features_histogram_test(:,i)'*training_matrix{a})';
%         x = L1QP_FeatureSign_yang(0, A,Q);
%         reconstruction_error = norm(training_matrix{a}*x- ...
%                                     features_histogram_test(:,i));
%         if (reconstruction_error<min)
%             prediction = a;
%             min = reconstruction_error;
%         end        
%     end
%     [prediction , labels_test(i)];
%     if (prediction~=labels_test(i))
%         error = error+1;
%     end    
% end
% error/length(labels_test)