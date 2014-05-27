function conf = configDailyAcitity()
% Returns the configurations of MSR-DailyActivity dataset.
% the correspondence between Kinect joint id, and joint name.
% the value conf.Name corresponds to the id of the given joint.
% conf.all is the ids of all the joints used for classification.
conf.num_actions = 16; % number of actions.
conf.num_subjects = 10; % number of subjects.
conf.num_env = 2; % number of enviornments. (standing/sitting on soffa)
conf.data_dir = './data';
conf.feature_dir = './features';
conf.SHOULDER_LEFT = 5;
conf.SHOULDER_RIGHT = 9;
conf.HIP =1;
conf.NECK = 3;
conf.HEAD = 4;
conf.ELBOW_LEFT = 6;
conf.ELBOW_RIGHT = 10;
conf.WRIST_LEFT = 7;
conf.WRIST_RIGHT = 11;
conf.HIP_LEFT = 13;
conf.HIP_RIGHT = 17;
conf.ANKLE_LEFT = 14;
conf.ANKLE_RIGHT = 18;
conf.joints_all = [conf.HEAD conf.NECK conf.ANKLE_LEFT conf.ANKLE_RIGHT ...
            conf.ELBOW_LEFT conf.WRIST_LEFT conf.ELBOW_RIGHT conf.WRIST_RIGHT
            conf.SHOULDER_LEFT conf.SHOULDER_RIGHT];