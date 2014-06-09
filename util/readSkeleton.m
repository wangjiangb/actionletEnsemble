function skeleton = readSkeleton(filename)
% Read skeleton positions from a text file.
% filename: text file of the skeleton positions.
% skeleton: skeleton positions.
if(nargin ~= 1)
    message = 'Missing file name!';
    display(message);
    skeleton = -1;
    npt = -1;
    return;
end

fid = fopen(filename,'r');
if (fid == -1)
    message = ['Cannot open the file: ' filename];
    display(message);
    skeleton = -1;
    npt = -1;
    return;
end

tmp = fscanf(fid,'%f %f\n',[2,1]);
num_frames = tmp(1);
num_joints = tmp(2);

skeleton = zeros(num_frames,num_joints*2,4);
for f=1:num_frames
    num_joints_current_frame = fscanf(fid,'%f\n',[1 1]);
    skeleton_current_frame = fscanf(fid,'%f %f %f %f\n',[4 ...
                        num_joints_current_frame]);
    skeleton_current_frame = skeleton_current_frame';
    if (num_joints_current_frame>=num_joints*2)
        skeleton(f,:,:) = skeleton_current_frame(1:num_joints*2,:);
    end
end
fclose(fid);
