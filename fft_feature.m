function feature = fft_feature(angles, num_samples)
            nof = size(angles,2);
            spacing = nof/num_samples;
            sample_point = int16(spacing/2:spacing:nof);
            angle_samples = zeros(size(angles,1),num_samples );
            for i=1:num_samples
                range = int16(1+(i-1)*spacing:(i*spacing));
                angle_samples(:,i) = mean(angles(:,range)');
            end
            %angles = angle_samples;           
            %angles = angles(:,sample_point);
            angle_cos = cos(angles);            
            angle_cos(2:2:end,:) = angle_cos(2:2:end,:)/2;
            angle_sin = sin(angles(2:2:end,:))/2;            
            angle_cos_sin = cat(1, angle_cos,angle_sin);
            %angle_cos_sin = angle_cos(1:2:end,:);
            angle_cos_sin = angles;
            %padding the data to the same size
            padding_num = num_samples- size(angle_cos_sin,2);
            if (padding_num>0)
                angle_cos_sin = [angle_cos_sin ...
                                 zeros(size(angle_cos_sin,1),padding_num)];
            else
                %angle_cos_sin = angle_cos_sin(:,1:num_samples);
            end            
            num_segments = 3;      
            data_length = size(angle_cos_sin, 2);
            segments_data = int32(1:data_length/num_segments: ...
                                  data_length);
            segments_data(num_segments+1) = data_length+1;
            segments_samples = int32(num_samples/num_segments);
            if (length(segments_data)>num_segments+1)
                printf('error');
            end
            segments_all = [];
            num_dim  = size(angle_cos_sin,1);
            for i=1:num_segments
                angles_segments = angle_cos_sin(:,segments_data(i): ...
                                        segments_data(i+1)-1);
                angles_segments_fft = zeros(size(angles_segments));
                for j=1:size(angles_segments,1)/3
                    range = (j-1)*3+1:j*3;
                    angles_segments_fft(range,:) = (fft(angles_segments(range,:)'))';
                    angles_segments_fft(:,1:end) = abs(angles_segments_fft(:,1:end));
                end
                                
                
                %angles_dwt = [];
                %for j=1:num_dim
                %    [c,l] = wavedec(angles_segments(j,:),8,'db1');
                %    segments_all = [segments_all; c(1:segments_samples)];
                %end                
                segments_all = [segments_all angles_segments_fft(:,[1:int32(segments_samples/2) end-int32(segments_samples/2)+1:end])];
            end            
            angle_fft = (fft(angle_cos_sin'))';            
            angle_fft(:,1:end) = abs(angle_fft(:,1:end));
            angle_cos_sin = [segments_all angle_fft(:,[1:num_samples/2 ...
                                end-num_samples/2+1:end])]*100/size(angles,2);
            %angle_cos_sin = cat(2, angle_cos_sin,[vars; means]');
            feature = angle_cos_sin;
end