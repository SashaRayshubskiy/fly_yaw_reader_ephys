function [] = motion_sensor_frame_capture(port_num)

PIXELS_PER_FRAME = 900;
myPort = setupSerialPort(port_num);

figure;
frame_id = 0;
while( 1 )
    
    fwrite(myPort, 11);
    %  Read the header byte, should be 'ff'
    headerByte = fread(myPort,1);
    
    frame = zeros( 1, PIXELS_PER_FRAME , 'uint8');
    if(headerByte == 15)
    
        % Iterate until a 900 bytes are read         
        pixels_to_read = PIXELS_PER_FRAME;
        start_idx = 1;
        end_idx = -1;
        while(pixels_to_read > 0)
            
            cur_pixels_to_read = min(pixels_to_read, myPort.BytesAvailable);            
            if( cur_pixels_to_read == 0 )
                continue;
            end
            
            bytesIn = fread(myPort,cur_pixels_to_read);
            bytesIn_Len = length(bytesIn);
            
            % disp(['cur_pixels_to_read: ' num2str(cur_pixels_to_read) ' bytesIn: ' num2str(bytesIn_Len)]);
            
            pixels_to_read = pixels_to_read - bytesIn_Len;
            end_idx = start_idx + bytesIn_Len;
            
            frame(start_idx:end_idx-1) = bytesIn;
            start_idx = end_idx;            
        end
    else
        disp(['ERROR: Header: ' num2str(headerByte) ' is not recognized.'])
        return;        
    end
    
    imagesc(reshape(frame', [30 30]));
    colormap gray;
    %caxis([80 200]);
    colorbar;
    axis image;
    title(['Frame: ' num2str(frame_id)]);
    pause(0.1);
    frame_id = frame_id + 1;
end
end

