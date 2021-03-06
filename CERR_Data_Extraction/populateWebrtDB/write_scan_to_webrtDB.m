function write_scan_to_webrtDB(patient_id)
%function write_scan_to_db(conn,patient_id)
%
%Input: Writes all scans from global planC to database
%
%APA, 02/27/2011

global planC
indexS = planC{end};

columnNames = {'patient_id', 'scan_type', 'scan_uid', 'ct_offset', 'rescale_slope',...
    'rescale_intercept', 'grid1units', 'grid2units', 'size_of_dimension_1', 'size_of_dimension_2', 'size_of_dimension_3', 'x_offset',...
    'y_offset','ct_air','ct_water', 'slice_thickness', 'site_of_interest', 'scanner_type', 'head_in_out', 'ct_scale', 'minimum_HU', 'maximum_HU'};


%MySQL database (Development)
% conn = database('webCERR_development','xxxx','xxxx','com.mysql.jdbc.Driver','jdbc:mysql://xxxx/xxxx');
conn = database('xxxx','xxxx','xxxx','com.mysql.jdbc.Driver','jdbc:mysql://xxxx.xxx.xxx/xxxx');

%Find the scan with scanUID matching this scan's CERR scan UID

for scanNum = 1:length(planC{indexS.scan})
    scanUID = planC{indexS.scan}(scanNum).scanUID;
    whereclause = {['where scan_uid = ''', scanUID,'''']};
    sqlq_find_scan = ['Select id from scans where scan_uid = ''', scanUID,''''];
    scan_raw = exec(conn, sqlq_find_scan);
    scan = fetch(scan_raw);
    scan = scan.Data;
    if ~isstruct(scan)
        %scan_id = char(java.util.UUID.randomUUID);
        scan_id = '';
        isNewRecord = 1;
    else
        scan_id = scan.id;
        isNewRecord = 0;
    end
    
    %patient_id
    recC{1} = patient_id;
    
%     %scanArray
%     recC{3} = ''; %store the pointer to location of scanArray
    
    %scanType
    recC{end+1} = planC{indexS.scan}(scanNum).scanType;
    
    %scanUID
    recC{end+1} = scanUID;
    
%     %transformationMatrix
%     transM = planC{indexS.scan}(scanNum).transM;
%     recC{6} = transM;
    
    %CTOffset
    recC{end+1} = planC{indexS.scan}(scanNum).scanInfo(1).CTOffset;
    
    %rescaleSlope
    if isempty(planC{indexS.scan}(scanNum).scanInfo(1).rescaleSlope)
        recC{end+1} = NaN;
    else
        recC{end+1} = planC{indexS.scan}(scanNum).scanInfo(1).rescaleSlope;
    end
    
    %rescaleIntercept
    if isempty(planC{indexS.scan}(scanNum).scanInfo(1).rescaleIntercept)
        recC{end+1} = NaN;
    else
        recC{end+1} = planC{indexS.scan}(scanNum).scanInfo(1).rescaleIntercept;
    end
    
    %grid1Units
    recC{end+1} = planC{indexS.scan}(scanNum).scanInfo(1).grid1Units;
    
    %grid2Units
    recC{end+1} = planC{indexS.scan}(scanNum).scanInfo(1).grid2Units;
    
    %sizeOfDimension1
    recC{end+1} = planC{indexS.scan}(scanNum).scanInfo(1).sizeOfDimension1;
    
    %sizeOfDimension2
    recC{end+1} = planC{indexS.scan}(scanNum).scanInfo(1).sizeOfDimension2;
    
    %sizeOfDimension3
    zValues = [planC{indexS.scan}(scanNum).scanInfo.zValue];
    recC{end+1} = length(zValues);
    
%     %zValues
%     recC{15} = zValues;
    
    %xOffset
    recC{end+1} = planC{indexS.scan}.scanInfo(scanNum).xOffset;
    
    %yOffset
    recC{end+1} = planC{indexS.scan}.scanInfo(scanNum).yOffset;
    
    %CTAir
    recC{end+1} = planC{indexS.scan}.scanInfo(scanNum).CTAir;
    if isempty(recC{end})
        recC{end} = NaN;
    end
    
    %CTWater
    recC{end+1} = planC{indexS.scan}.scanInfo(scanNum).CTWater;
    if isempty(recC{end})
        recC{end} = NaN;
    end
    
    %sliceThickness
    recC{end+1} = planC{indexS.scan}.scanInfo(scanNum).sliceThickness;
    
    %siteOfInterest
    recC{end+1} = planC{indexS.scan}.scanInfo(scanNum).siteOfInterest;
    if isempty(recC{end})
        recC{end} = '';
    end
    
    %scannerType
    recC{end+1} = planC{indexS.scan}.scanInfo(scanNum).scannerType;
    if isempty(recC{end})
        recC{end} = '';
    end
    
    %headInOut
    recC{end+1} = planC{indexS.scan}.scanInfo(scanNum).headInOut;
    if isempty(recC{end})
        recC{end} = '';
    end
    
    %CTScale
    recC{end+1} = planC{indexS.scan}.scanInfo(scanNum).CTScale;
    if isempty(recC{end})
        recC{end} = NaN;
    end 
    
    %minimum HU
    CTOffset = planC{indexS.scan}(1).scanInfo(1).CTOffset;
    minHU = min(planC{indexS.scan}.scanArray(:)) - CTOffset;
    recC{end+1} = minHU;
    
    %maximum HU
    maxHU = max(planC{indexS.scan}.scanArray(:)) - CTOffset;
    recC{end+1} = maxHU;
    
    if isNewRecord
        insert(conn,'scans',columnNames,recC);
    else        
        % scan_id to update
        recNewC = recC;
        recNewC{end+1} = scan_id;
        update(conn,'scans',[columnNames, 'id'],recNewC,whereclause);
    end    
    
    pause(0.05)     
    
end

close(conn)

