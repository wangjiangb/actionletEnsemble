function joints_ids = skeletonKinect()
% Returns the correspondence between Kinect joint id, and joint name.
% the value joint_ids.Name corresponds to the id of the given joint.
% joint_ids.all is the ids of all the joints used for classification.
joint_ids.SHOULDER_LEFT = 5;
joint_ids.SHOULDER_RIGHT = 9;
joint_ids.HIP =1;
joint_ids.NECK = 3;
joint_ids.HEAD = 4;
joint_ids.ELBOW_LEFT = 6;
joint_ids.ELBOW_RIGHT = 10;
joint_ids.WRIST_LEFT = 7;
joint_ids.WRIST_RIGHT = 11;
joint_ids.HIP_LEFT = 13;
joint_ids.HIP_RIGHT = 17;
joint_ids.ANKLE_LEFT = 14;
joint_ids.ANKLE_RIGHT = 18;
joint_ids.all = [joint_ids.HEAD joint_ids.NECK joint_ids.ANKLE_LEFT joint_ids.ANKLE_RIGHT ...
          joint_ids.ELBOW_LEFT joint_ids.WRIST_LEFT joint_ids.ELBOW_RIGHT joint_ids.WRIST_RIGHT
          joint_ids.SHOULDER_LEFT joint_ids.SHOULDER_RIGHT];