classdef cuvis_measurement < handle
    properties
        name;
        path;
        comment;
        capture_time;
        factory_calibration;
        product_name;
        serial_number;
        assembly;
        integration_time;
        averages;
        sequence_no;
        session_no;
        sesesion_name;
        processing_mode;
        measurement_flags;
        flags;
        capabilites;
        frame_id;
        
        data;
        
        sdk_handle;
    end
    properties (Access = private)
        
        cleanup;
    end
    methods
        function cpyObj = copy(srcObj)
            
        mesuPtr = libpointer('int32Ptr',0);
        [code,copy_handle]=calllib('cuvis','cuvis_measurement_deep_copy',srcObj.sdk_handle, mesuPtr );    
        clear mesuPtr ;
        cuvis_helper_chklasterr(code);
        
        cpyObj = cuvis_measurement(copy_handle);
        end
        
        function mesuObj=refreshData(mesuObj)
            
            
            mesuMetaDataPtr = calllib('cuvis','cuvis_mesu_metadata_allocate');
            [code,mesu_data]=calllib('cuvis','cuvis_measurement_get_metadata',mesuObj.sdk_handle, mesuMetaDataPtr);
            calllib('cuvis','cuvis_mesu_metadata_free',mesuMetaDataPtr);
            %clear mesu_data;
            clear mesuMetaDataPtr;
            cuvis_helper_chklasterr(code);
            

            mesuObj.name = deblank(char(mesu_data.name));
            mesuObj.path = deblank(char(mesu_data.path));
            mesuObj.comment = deblank(char(mesu_data.comment));
            mesuObj.product_name = deblank(char(mesu_data.product_name));
            mesuObj.serial_number = deblank(char(mesu_data.serial_number));
            mesuObj.assembly = deblank(char(mesu_data.assembly));
            
            mesuObj.sesesion_name = deblank(char(mesu_data.session_info_name));
            mesuObj.sequence_no = mesu_data.session_info_sequence_no;
            mesuObj.session_no = mesu_data.session_info_session_no;
            
            mesuObj.processing_mode = deblank(char(mesu_data.processing_mode));
            mesuObj.capture_time = cuvis_helper_mktime( mesu_data.capture_time);
            mesuObj.factory_calibration = cuvis_helper_mktime(mesu_data.factory_calibration);
            mesuObj.integration_time = mesu_data.integration_time;
            mesuObj.averages = mesu_data.averages;
            
            mesuObj.frame_id = mesu_data.measurement_frame_id;
            
            
             capaPtr = libpointer('int32Ptr',0);
            [code,capa]=calllib('cuvis','cuvis_measurement_get_capabilities', mesuObj.sdk_handle, capaPtr);
            clear capaPtr;
            cuvis_helper_chklasterr(code);
            
            mesuObj.capabilites = cuvis_load_capabilites(capa);
            
            
            mesuObj.readflags(mesu_data.measurement_flags);
            
            
            
            
                dataCntPtr = libpointer('int32Ptr',0);
                [code,dataCnt]=calllib('cuvis','cuvis_measurement_get_data_count',mesuObj.sdk_handle,dataCntPtr);
                clear dataCntPtr;
                cuvis_helper_chklasterr(code);
            
            
            
            mesuObj.data=[];
            
            
            for k=0:dataCnt-1
                
                
                
                typePtr = libpointer('cuvis_data_type_t',0);
                keyStr= libpointer('cstring', repmat(' ',1,256));
                [code,key,type]=calllib('cuvis','cuvis_measurement_get_data_info',mesuObj.sdk_handle,keyStr,typePtr,k);
                clear typePtr;
                clear keyStr;
                
                if (isempty(key))
                    continue;
                end
                
                contentdata=[];
                
                switch type
                    case 'data_type_image' % image
                        imbufptr = calllib('cuvis','cuvis_imbuffer_allocate');
                        [code , ~, image] =calllib('cuvis','cuvis_measurement_get_data_image',mesuObj.sdk_handle, key ,imbufptr);
                        calllib('cuvis','cuvis_imbuffer_free',imbufptr);
                        
                        
                        len = image.width * image.height * image.channels;
                        
                        switch image.format
                            case 'imbuffer_format_uint8'
                                setdatatype(image.raw,'uint8Ptr',len);
                            case 'imbuffer_format_uint16'
                                setdatatype(image.raw,'uint16Ptr',len);
                            case 'imbuffer_format_uint32'
                                setdatatype(image.raw,'uint32Ptr',len);
                            case 'imbuffer_format_float'
                                setdatatype(image.raw,'singlePtr',len);
                        end
                        
                        
                        
                        
                        
                        if isempty(image.wavelength)
                            contentdata = permute(reshape(image.raw.Value,[image.channels image.width image.height]),[3,2,1]);
                            
                            
                        else
                            
                            contentdata.value = permute(reshape(image.raw.Value,[image.channels  image.width image.height]),[3,2,1]);
                            setdatatype(image.wavelength,'uint32Ptr', image.channels);
                            contentdata.wl = image.wavelength.Value;
                        end
                        
                        
                        
                        
                        
                        
                    case 'data_type_gps' % GPS
                        gpsPtr = calllib('cuvis','cuvis_gps_allocate');
                        
                        [code,~,gps]=calllib('cuvis','cuvis_measurement_get_data_gps',mesuObj.sdk_handle,key,gpsPtr);
                        
                        calllib('cuvis','cuvis_gps_free',gpsPtr);
                        
                        cuvis_helper_chklasterr(code);
                        
                        contentdata.longitude = gps.longitude;
                        contentdata.latitude = gps.latitude;
                        contentdata.altitude = gps.altitude;
                        contentdata.time = cuvis_helper_mktime(gps.time);
                        
                        
                        
                    case 'data_type_string' % string
                        
                        lenPtr = libpointer('uint64Ptr',0);
                        [code,~,len]=calllib('cuvis','cuvis_measurement_get_data_string_length',mesuObj.sdk_handle,key,lenPtr);
                        clear lenPtr;
                        cuvis_helper_chklasterr(code);
                        
                        valueStr= libpointer('cstring', repmat(' ',1,len));
                        [code,~,value]=calllib('cuvis','cuvis_measurement_get_data_string',mesuObj.sdk_handle,key,len,valueStr);
                        clear valueStr;
                        cuvis_helper_chklasterr(code);
                        
                        contentdata = value;
                        
                    case 'data_type_sensor_info' % string
                        
                       gpsPtr = calllib('cuvis','cuvis_sensor_info_allocate');
                        
                        [code,~,sinfo]=calllib('cuvis','cuvis_measurement_get_data_sensor_info',mesuObj.sdk_handle,key,gpsPtr);
                        
                        calllib('cuvis','cuvis_sensor_info_free',gpsPtr);
                        
                        cuvis_helper_chklasterr(code);
                        
                        contentdata.averages = sinfo.averages;
                        contentdata.temperature = sinfo.temperature;
                        contentdata.gain = sinfo.gain;
                        contentdata.readout_time = cuvis_helper_mktime(sinfo.readout_time);
                        contentdata.width = sinfo.width;
						contentdata.height = sinfo.height;
                        contentdata.pixel_format = sinfo.pixel_format
                        contentdata.binning = sinfo.binning
                        contentdata.raw_frame_id = sinfo.raw_frame_id;
                    otherwise
                        contentdata.key=key;
                        contentdata.type='unkown';
                        
                end
                
                mesuObj.data.(key)= contentdata;
                
                cuvis_helper_chklasterr(code);
            end
            
        end
        
        
        function mesuObj = cuvis_measurement(data)
            
            cuvis_helper_chklib
            mesuObj.cleanup = onCleanup(@()delete(mesuObj));
            
            switch class(data)
                case 'char'
                    
                    
                    mesuObj.sdk_handle=-1;
                    
                    
                    
                    pathStr = libpointer('cstring', data);
                    mesuPtr = libpointer('int32Ptr',0);
                    [code,~,mesuObj.sdk_handle]=calllib('cuvis','cuvis_measurement_load',pathStr, mesuPtr);
                    clear pathStr;
                    clear mesuPtr;
                    cuvis_helper_chklasterr(code);
                case 'int32'
                    mesuObj.sdk_handle=data;
                otherwise
                    error('unkown argument type');
            end
            
            mesuObj.refreshData();
            
            
            
        end
        
        
        function set_name(mesuObj,name)
            cuvis_helper_chklib
            
            
            nameStr = libpointer('cstring', name);
            
            [code]=calllib('cuvis','cuvis_measurement_set_name', mesuObj.sdk_handle,nameStr);
            
            
            cuvis_helper_chklasterr(code);
            
            refreshData(mesuObj);
        end
        
        function save(mesuObj, path, varargin)
            cuvis_helper_chklib
            
            p = inputParser;
            p.KeepUnmatched=false;
            
            validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            
            addParameter(p,'allow_fragmentation',false,@islogical);
            addParameter(p,'allow_overwrite',false,@islogical);
            addParameter(p,'allow_drop',false,@islogical);
            %addParameter(p,'allow_session_file',true,@islogical);
            addParameter(p,'allow_info_file',true,@islogical);
            addParameter(p,'operation_mode','Software',@ischar);
            addParameter(p,'fps',0.0,@isdouble);
            addParameter(p,'soft_limit',20,validScalarPosNum);
            addParameter(p,'hard_limit',100,validScalarPosNum);
            addParameter(p,'max_buftime',10000,validScalarPosNum);
            
            parse(p,varargin{:});
            
            
            
            cargs=calllib('cuvis','cuvis_save_args_allocate');
            
            
            cargs.Value.allow_fragmentation = p.Results.allow_fragmentation;
            cargs.Value.allow_overwrite = p.Results.allow_overwrite;
            cargs.Value.allow_drop = p.Results.allow_drop;
            cargs.Value.allow_session_file = false;%p.Results.allow_session_file;
            cargs.Value.allow_info_file = p.Results.allow_info_file;
            
             if strcmp(p.Results.operation_mode, 'Software')
                cargs.Value.operation_mode = 1;
            elseif strcmp(p.Results.operation_mode, 'Internal')
                cargs.Value.operation_mode = 2;
            elseif strcmp(p.Results.operation_mode, 'External')
                cargs.Value.operation_mode = 3;
            else
               cargs.Value.operation_mode = 4; 
            end
            
            cargs.Value.fps = p.Results.fps;
            cargs.Value.soft_limit = p.Results.soft_limit;
            cargs.Value.hard_limit = p.Results.hard_limit;
            cargs.Value.max_buftime = p.Results.max_buftime;
            
            
            pathStr = libpointer('cstring', path);
            
            [code]=calllib('cuvis','cuvis_measurement_save', mesuObj.sdk_handle,pathStr, cargs );
            
            calllib('cuvis','cuvis_save_args_free',cargs);
            clear cargs;
            
            cuvis_helper_chklasterr(code);
            
            
            
        end
        
        function delete(mesuObj)
            if (mesuObj.sdk_handle >=0)
                calllib('cuvis','cuvis_measurement_free',mesuObj.sdk_handle);
                
            end
        end
        
        function readflags(mesuObj,flags)
            
            mesuObj.flags = [];
            flagidx = 1;
            
            if bitand(flags,1 )
                mesuObj.flags{flagidx}='CUBERT_MESU_FLAG_OVERILLUMINATED';
                flagidx = flagidx+1;
            end
            if bitand(flags,2)
                mesuObj.flags{flagidx}='CUBERT_MESU_FLAG_POOR_REFERENCE';
                flagidx = flagidx+1;
            end
            if bitand(flags,4 )
                mesuObj.flags{flagidx}='CUBERT_MESU_FLAG_POOR_WHITE_BALANCING';
                flagidx = flagidx+1;
            end
            if bitand(flags,8 )
                mesuObj.flags{flagidx}='CUBERT_MESU_FLAG_DARK_INTTIME';
                flagidx = flagidx+1;
            end
            if bitand(flags,16 )
                mesuObj.flags{flagidx}='CUBERT_MESU_FLAG_DARK_TEMP';
                flagidx = flagidx+1;
            end
            if bitand(flags,32)
                mesuObj.flags{flagidx}='CUBERT_MESU_FLAG_WHITE_INTTIME';
                flagidx = flagidx+1;
            end
            if bitand(flags,64)
                mesuObj.flags{flagidx}='CUBERT_MESU_FLAG_WHITE_TEMP';
                flagidx = flagidx+1;
            end
            if bitand(flags,128)
                mesuObj.flags{flagidx}='CUBERT_MESU_FLAG_WHITEDARK_INTTIME';
                flagidx = flagidx+1;
            end
            if bitand(flags,256)
                mesuObj.flags{flagidx}='CUBERT_MESU_FLAG_WHITEDARK_TEMP';
                flagidx = flagidx+1;
            end
            
            
        end
    end
end
