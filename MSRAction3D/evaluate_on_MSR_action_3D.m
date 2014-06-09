%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This script evaluate Fourier temporal pyramid features on
%%% MSRAction3D dataset. Only skeleton features are used.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load skeleton data adn remove irregular videos.
clear;
load MSRAction3D_skeleton_features;
features = [];
feature_per_class={};

subList = [1 3 5 7 9]; % subjects for training.
test_subList = [2 4 6 8 10]; % subjects for testing.
subList_all = [1 2 3 4 5 6 7 8 9 10];
actList_all = [1 2 3  4 5 6 7 8 9 10 11 12 13 14 15 16 17  18 19 20];

%% remove abnormal samples. Some of the sequences are empty.
datacf.trainSamples(subList,actList_all,[1 2 3]) = 1;
datacf.testSamples(test_subList,actList_all,[1 2 3]) = 1;
datacf.trainSamples(3,4,1)=0;
datacf.trainSamples(4,7,1) = 0;
datacf.trainSamples([6 9],13,1) = 0;
datacf.trainSamples([2 6 7],20,1) = 0;
datacf.trainSamples([2 6 8 9 10],13,2)=0;
datacf.trainSamples([2 8],20,2) = 0;
datacf.trainSamples([2 6 9],13,3)=0;
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

%% Compute Fourier Temporal Pyramid features.
num_samples =12; % the number of low frequency Fourier coeffcients used for features.
for a=1: datacf.numOfActions
    for s =1:datacf.numOfSubjects
        nos = datacf.numOfSamples(s,a);
        if (nos == 0)
            continue;
        end
         for e=1:nos
            angles = angles_all{s,a,e};
            if (size(angles,1)==0)
                continue;
            end
            features_fft =fftPyramid(angles,num_samples);
            angles_shift = circshift(angles', 1)';
            angles_diff = angles  - angles_shift;
            angles_diff = angles_diff(:,1:end-1);
            feature_diff = fftPyramid(angles_diff, num_samples);
            feature_per_class{s, a, e} =[ features_fft ; feature_diff];
            a
            s
            e
        end
    end
end


%% Split the training and testing dataset.
training_count = 1;
test_count = 1;
features_histogram =[];
labels = [];
for a=1:datacf.numOfActions
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

%% train and evalating a svm model on the features
  c =.002;
  options = ['-c ' num2str(c)];
  decisions = zeros(length(labels_test),datacf.numOfActions);
  model = train(double(labels_training'), sparse(features_histogram_training'), options);
  [predicted_label, accuracy2, decision_values] = predict(double(labels_test'), sparse(features_histogram_test'), model);

save result
