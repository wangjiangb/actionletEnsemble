function [depth, skeleton_id] =  readDepthBin(depth_filename)
% Warpper for ReadDepthBin. Make sure the file exists.
if (exist(depth_filename, 'file'))
    [depth, skeleton_id] =  ReadDepthBin(fullfile(depth_filename));
else
    throw(sprintf('%s not exist', depth_filename));
end
end