function angles = computePairwiseJointPositions(skeleton,joint_id, target_ids)
% Compute the paireise joint positions from joint joint_id to all the joints in target_ids.

count = 1;
jnts = skeleton(:,1:3);
normalization_factor = 1;

for t=1:length(target_ids)
    target_id  = target_ids(t);
    if (target_id==joint_id)
        continue;
    end
    target = jnts(joint_id,:)- jnts(target_id,:);
    angles(count:count+2) = target/normalization_factor; %features
    count = count +3;
end