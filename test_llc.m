clear;
load result;
addpath ../libs/LLC/;
addpath ../libs/vlfeat-0.9.16-bin/vlfeat-0.9.16/toolbox/;
vl_setup

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

%% clustering the 
num_samples =12;
num_actions = 20;
features = [];
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
            features(:, end+1:end + size(angles, 2)) = angles;
            feature_per_class{s, a, e} = angles;
            s
            a
            e                        
        end
    end
end

%% perform k-menas on each joints features
num_clusters = 500;
voc = vl_kmeans(features, num_clusters, 'verbose', 'algorithm', 'elkan');
kd_tree = vl_kdtreebuild(voc);
[index, distance]  = vl_kdtreequery(kd_tree, voc, features);

%% perform quantization with LLC
training_count = 1;
test_count = 1;
features_histogram =[];
labels = [];
knn = 30;
for a=1: num_actions
    for s =1:datacf.numOfSubjects            
        nos = datacf.numOfSamples(s,a);
        if (nos == 0)
            continue;
        end
        for e=1:nos 
            feature = feature_per_class{s, a, e};
            code = LLC_coding_appr(voc', feature', knn);
            % max-pooling
            histogram = max(code,[], 1);
            histogram1 = max(code(1:int16(size(code, 1)/2), :), [], 1);
            histogram2 = max(code(int16(size(code, 1)/2) +1:end, :), [], 1);
            histogram11 = max(code(1:int16(size(code, 1)/4), :), [], 1);
            histogram12 = max(code(int16(size(code, 1)/4) +1:int16(size(code, 1)/2), :), [], 1);
            histogram21 = max(code(int16(size(code, 1)/2) +1:int16(size(code, 1)/4*3), :), [], 1);
            histogram22 = max(code(int16(size(code, 1)/4*3) +1:end, :), [], 1);
            %histogram = [histogram histogram1 histogram2 histogram11 histogram12 histogram21 histogram22];
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

 