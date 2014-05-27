function fft_array = extract_shape_descriptor(depth_filename, points_filaname) 
[depth, skeleton_id] =  ReadDepthBin(depth_filename);
 fid = fopen(points_filaname);
 num_frames = fread(fid, [1 1], '*uint16');
 num_sample = 10;
 fft_array = zeros(num_sample*2,num_frames);
 for f= 1:num_frames
     depth_current = reshape(depth(:,:,f),[240 320]);
     depth_current_show = depth_current./max(max(depth_current));
     depth_current_show = zeros(size(depth_current));
     num_points = fread(fid, [1 1], '*uint32');
     points_right = fread(fid, [3  num_points], '*uint16');
     points_right = points_right +1;
     if (num_points>1)         
         indxs = sub2ind(size(depth_current), points_right(2,:), ...
                         points_right(1,:));
         depth_current_show(indxs) = 1;
         BW = bwboundaries(depth_current_show, 8);     
         center_right = [points_right(2,1); points_right(1,1)];
         diff = double(BW{1}) - double(repmat(center_right', [size(BW{1},1) 1]));
         diff2 = sqrt(sum(diff.^2,2));   
             
     else
         diff2 = [];
     end     
     depth_current_show = zeros(size(depth_current));
     num_points_right = fread(fid, [1 1], '*uint32');    
     points_left = fread(fid, [3  num_points_right], '*uint16');    
     points_left = points_left +1;
     if (num_points_right>1)
         indxs = sub2ind(size(depth_current), points_left(2,:), ...
                         points_left(1,:));
         depth_current_show(indxs) = 1;
         %imshow(depth_current_show);        
         BW = bwboundaries(depth_current_show, 8);          
         center_left = [points_left(2,1); points_left(1,1)];
         diff_left = double(BW{1}) - double(repmat(center_left', [size(BW{1},1) 1]));
         diff2_left = sqrt(sum(diff_left.^2,2));          
     else
         diff2_left=[];
     end     
     diff2_fft = abs(fft(diff2))/length(diff2);
     diff2_fft_left = abs(fft(diff2_left))/length(diff2_left);
     if (length(diff2)<num_sample)
        fft_array(1:int32(num_sample),int32(f)) =0; 
     else
        fft_array(1:int32(num_sample),int32(f)) = diff2_fft([1:int32(num_sample/2) length(diff2_fft)-int32(num_sample/2)+1:length(diff2_fft)]);
     end
     if (length(diff2_left)<num_sample)
        fft_array(int32(num_sample)+1:int32(num_sample)*2,int32(f)) = 0; 
     else
        fft_array(int32(num_sample)+1:int32(num_sample)*2,int32(f)) = diff2_fft_left([1:int32(num_sample/2),end-int32(num_sample/2)+1:end]);
     end
 end
 fclose(fid);