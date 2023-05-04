%% If this is STPSat-6 with CADUs interlaced, get rid of them.
if strcmp(HOST,'STPSat-6')
    LEN_CADU = 1038;
    LEN_BINCADU = 1028;
    LEN_UNK = 10;
    LEN_UNK2 = 21;
    LEN_CP_PDU_HEADER = 11;
    LEN_VCDU_HEADER = 20;

    
    caducount = 0;
    cadustart = strfind(data',sscanf('1ACFFC1D','%2x')');
    numcadus = length(cadustart);
    dataclean=data;
    for i=1:numcadus
        cs = cadustart(i);
        lo=cs-12;
        if lo<1
            lo=1;
        end
        hi=cs+20;
        if hi > length(data)
            hi=length(data);
        end
        hi-lo+1;
        caducounter(i) = bytesum(data(cs+6:cs+8),0);

        data(lo:hi)=NaN;

%good        data(cs:cs+LEN_VCDU_HEADER+LEN_CP_PDU_HEADER-1) = NaN; % nuke the CADU header
%good        data(cs+LEN_CADU-2:cs+LEN_CADU-1)=NaN; % nuke the CRC
        
%         data(cs+LEN_BINCADU-12:cs+LEN_BINCADU-11) = NaN;
%         if cs > LEN_CRC
%             data(cs-LEN_CRC:cs-LEN_CRC+1) = NaN;
%         end        
%         if cs > LEN_UNK
%             %data(cs-LEN_UNK:cs+LEN_UNK2-1) = NaN;
%         end
    end
    
    

    % Calculate duplicates and missing CADUs
    [cdu, ia, ic] = unique(caducounter,'first'); % sorted unique values
    
    missingcaducount = sum(diff(cdu))-(length(cdu)-1);
    try
        if (missingcaducount)
            str = ['**WARNING**: Found ',num2str(missingcaducount),' missing CADUs'];
            disp(str);
            allvals = cdu(1):1:cdu(end);
            
            if (length(setdiff(cdu,allvals)))
                str = ['**WARNING** missing VCDU counters = ',num2str(setdiff(allvals,cdu))];
                disp(str);
            end
        end
    end
    str='=====================================';
    disp(str);
%    fprintf(qqq,'%s\n',str);
    disp(FileName);
%    fprintf(qqq,'%s\n',FileName);
    aaa=find(diff(cdu)>1);
    for z=1:length(aaa)
        str=['VCDU Counter skips from ',num2str(cdu(aaa(z))),' to ',num2str(cdu(aaa(z)+1))];
        disp(str);
%    fprintf(qqq,'%s\n',str);


    end
    str = ['Found ',num2str(length(cdu)),' unique VCDU counter values'];
    disp(str);
%    fprintf(qqq,'%s\n',str);

    str = ['Found ',num2str(sum(diff(sort(caducounter))==0)),' duplicate VCDU counter values'];
    disp(str);
%    fprintf(qqq,'%s\n',str);


    
%     disp([' INFO: Extracted ',INSTRUMENT,' data from unique CADUs']);
%     % Extract unique data
%     cadudataunique = cadudata(ia,:);
%     lp=length(cadudataunique(:));
%     data=reshape(cadudataunique',[lp,1])';
    
    
    % Get rid of CP_PDU header
    data=data(find(~isnan(data)));
    %data = data';
    %disp([' INFO: Processing ',num2str(length(data)),' bytes of ',INSTRUMENT,' data.']);
    
end