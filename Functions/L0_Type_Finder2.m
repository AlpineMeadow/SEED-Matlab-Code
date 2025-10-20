len_packet_types = length(PACKET_TYPES);
%%toc
%for i=1:len_packet_types
hsmode1_pattern = '4D45534101';
hsmode0_pattern = '4D45534100';

for i=1:len_packet_types

    packet_type = [PACKET_TYPES(i)];
%     if ~contains(FileName,packet_type)
%         continue;
%     end
        
%    disp(strjoin(['STATUS: Looking for Type',num2str(i),PACKET_TYPES(i),'packets:']));
    
%    textprogressbar('STATUS: Searching telemetry file: ');

    % Look up the packet parameters for packet type i.
    sync_pattern = eval(genvarname(['TYPE',num2str(i),'_PKT_SYNC']));
    foot_pattern = eval(genvarname(['TYPE',num2str(i),'_PKT_FOOT']));
    len_packet = eval(genvarname(['TYPE',num2str(i),'_PKT_LEN']));
    id_packet = eval(genvarname(['TYPE',num2str(i),'_PKT_ID']));
    idloc_packet = eval(genvarname(['TYPE',num2str(i),'_PKT_IDLOC']));
    
    len_sync = length(sscanf(sync_pattern,'%2x'));
    len_foot = length(sscanf(foot_pattern,'%2x'));
    len_id = length(sscanf(id_packet,'%2x'));
    
    data_packet_name = ['data_packet_type_',num2str(i)]; % 1,2,3...etc
    num_packet_name = ['num_packet_type_',num2str(i)]; % 1,2,3...etc
    len_packet_name = ['len_packet_type_',num2str(i)];

    j=1;
    k=1;


    %%
    % rlb 20191204


    % convert to row array
    data = data';
    % convert sync patterns to row arrays
    sync_pattern_ra = sscanf(sync_pattern,'%2x')';
    foot_pattern_ra = sscanf(foot_pattern,'%2x')';
    hsmode0_pattern_ra = sscanf(hsmode0_pattern,'%2x')';
    hsmode1_pattern_ra = sscanf(hsmode1_pattern,'%2x')';

    % if CADUs have been extracted, it ended up a column vector.  Need to
    % convert it back to a row vector.
    if iscolumn(data)
        data=data';
    end

    % find all the matches to sync_pattern
    packet_start_index = strfind(data,sync_pattern_ra);
    % no longer used: packet_end_index = packet_start_index + len_packet - 1;
    mode0find = strfind(data,hsmode0_pattern_ra);
    mode1find = strfind(data,hsmode1_pattern_ra);
    if length(mode1find) ~= 0
%        disp(['Found ',num2str(length(mode1find)),' non-mode-zero mode spectra.']);
    end
    

    % Drop off any sync patterns at the end that have incomplete packets
    packet_start_index = packet_start_index(find((packet_start_index + len_packet) < length(data)));
    
    num_packet_matches = length(packet_start_index);
    %disp(['Found ',num2str(num_packet_matches),' sync_patterns']);
    
%     if(num_packet_matches == 0)
%         warning('erk45');
%     end
    
    % I can't see how to not have this as an array.
    data_packets.(data_packet_name) = uint16(zeros(num_packet_matches,len_packet));
    all_data_packets.(data_packet_name) = uint16(zeros(num_packet_matches,len_packet));
    temp_packet_array = uint16(zeros(num_packet_matches,len_packet));
    aaa=1;
    for k=1:num_packet_matches
        % extract the (potential) packets into the data_packets structure
        %all_data_packets.(data_packet_name)(k,1:len_packet) = data(packet_start_index(k):packet_start_index(k) + len_packet - 1);
        %if (data(packet_start_index(k)+idloc_packet-1) == str2num(id_packet))
            data_packets.(data_packet_name)(aaa,1:len_packet) = data(packet_start_index(k):packet_start_index(k) + len_packet - 1);
            temp_packet_array(aaa,1:len_packet) = data(packet_start_index(k):packet_start_index(k) + len_packet - 1);
            %disp(num2str(k));
            aaa=aaa+1;
        %else
            %disp([num2str(k),' Bad packet ID = ',dec2hex(data(packet_start_index(k)+idloc_packet-1))]);
        %end
        

    end
    [t1,t2] = size(temp_packet_array);
%    disp(['Extracted ',num2str(t1),' packets into a 2D array']);
	

    
    
 

    numpackets = num_packet_matches;
    
    data_packets.(num_packet_name) = numpackets;
    data_packets.(len_packet_name) = len_packet;
    data_packets.(data_packet_name) = temp_packet_array;
    totpackets = totpackets + numpackets;
    
    if numpackets > 0 % if we actually have found any packets
        dummy='N';
%         prompt = 'ACTION: Do you want to check the CRCs? This can take a while. Y/[N] ';
%         dummy = input(prompt,'s');
%         if isempty(dummy)
%                 dummy='N';
%         end
        if strcmp(dummy,'Y')
%            disp(['STATUS: Reading and recalculating CRCs']);
            % Check the CRCs
%            disp(['STATUS: Reading CRCs']);
            
            
            calc_crcs=uint16(zeros(numpackets,1));
            
            % Extract the CRCs from each packet.
            read_crcs=cellfun(@(x) bytesum(x,0), num2cell(temp_packet_array(:,end-1:end),2));
%            disp(['STATUS: Finished reading CRCs']);
            %%toc
            
%            disp(['STATUS: Recalculating CRCs']);
            tic
            % Calculate the CRCs for each packet.
            % CELL ARRAY TOO BIG calc_crcs=cellfun(@(x) CRC_16_CCITT(x), num2cell(temp_packet_array(:,1:end-2),2));
            calc_crcs = arrayfun(@(x) CRC_16_CCITT(temp_packet_array(x,1:end-2)),1:size(temp_packet_array,1));
            calc_crcs = calc_crcs';
            
            %calc_crcs=arrayfun(@(x) x,CRC_16_CCITT(temp_packet_array(x,1:end-2)),(1:size(temp_packet_array,1)).');
%            disp(['STATUS: Finished recalculating CRCs']);
            %%toc
            
            count_badcrc = length(find(calc_crcs~=read_crcs));
            if count_badcrc > 0
%                disp(['**WARNING** Found ',num2str(count_badcrc),' bad ',INSTRUMENT,' packet CRCs.']);
                %disp(['**WARNING** Discarding these ',INSTRUMENT,' packets.']);
            else
%                disp(['INFO: Found no bad ',INSTRUMENT,' packet CRCs.']);
            end
        else
%            disp('WARNING:  packet CRCs have NOT been checked.');
        end

    end % if numpackets > 0
    
end
