function feature = fftPyramid(data_in, num_samples, use_cos_sin)
% Compute the Fourier temporal pyramid features.
% data_in: input features, where the first dimension is the number of
% the data, and the second dimension is the feature dimension.
% num_samples: number of low frequency coefficients for features.
% FFT is applied to each dimension of data_in.
    if nargin < 3
        use_cos_sin = 0;
    end

    nof = size(data_in,2); % feature dimension.

    % compute cosin and sin for the features, only good for angles.
    if use_cos_sin == 1
        data_cos = cos(data_in);
        data_cos(2:2:end,:) = data_cos(2:2:end,:)/2;
        data_sin = sin(data_in(2:2:end,:))/2;
        data_processed = cat(1, data_cos, data_sin);
    else
        data_processed = data_in;
    end

    % padding the data if needed.
    padding_num = num_samples- size(data_processed,2);
    if (padding_num > 0)
        data_processed = [data_processed ...
                         zeros(size(data_processed,1),padding_num)];
    end

    num_segments = 3;
    data_length = size(data_processed, 2);
    segments_data = int32(1:data_length/num_segments:data_length);
    segments_data(num_segments+1) = data_length + 1;
    segments_samples = int32(num_samples/num_segments);
    if (length(segments_data) > num_segments+1)
        printf('error: input feature length is too short.');
    end

    segments_all = [];
    num_dim  = size(data_processed,1);
    % compute the pyramid.
    for i=1:num_segments
        data_segments = data_processed(:,segments_data(i): ...
                                         segments_data(i+1)-1);
        data_segments_fft = zeros(size(data_segments));
        for j=1:size(data_segments,1)/3
            range = (j-1)*3+1:j*3;
            data_segments_fft(range,:) = (fft(data_segments(range,:)'))';
            data_segments_fft(:,1:end) = abs(data_segments_fft(:,1:end));
        end
        segments_all = [segments_all data_segments_fft(:,[1:int32(segments_samples/2) end-int32(segments_samples/2)+1:end])];
    end
    data_fft = (fft(data_processed'))';
    data_fft(:,1:end) = abs(data_fft(:,1:end));
    features_all = [segments_all data_fft(:,[1:num_samples/2 ...
                        end-num_samples/2+1:end])]*100/size(data_in,2);
    feature = features_all;
end
