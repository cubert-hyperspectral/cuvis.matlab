classdef cuvis_worker < handle
    properties
        sdk_handle;
    end
    properties (Access = private)
        cleanup;
    end
    methods (Access = private)
        
    end
    methods
        function workerObj = cuvis_worker(varargin)
            
            cuvis_helper_chklib
            workerObj.sdk_handle=-1;
            
            
            
            p = inputParser;
            p.KeepUnmatched=true;
            validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            
            addParameter(p,'worker_count',8,@isinteger);
            addParameter(p,'poll_interval',10,@isinteger);
            addParameter(p,'keep_out_of_sequence',false,@keep_out_of_sequence);
            addParameter(p,'worker_queue_size',100,@isinteger);
            
            addParameter(p,'export_dir','.',@ischar);
            addParameter(p,'spectra_multiplier',1.0,validScalarPosNum);
            addParameter(p,'channel_selection','full',@ischar);
            addParameter(p,'pan_scale',0,@isnumeric);
            addParameter(p,'pan_sharpening_interpolation_type','NearestNeighbor',@ischar);
            addParameter(p,'pan_sharpening_algorithm','Noop',@ischar);
            
            addParameter(p,'add_fullscale_pan',false,@islogical);
            addParameter(p,'permissive',false,@islogical);
            
            
            
            parse(p,varargin{:});
            
            
            cworker_settings = calllib('cuvis','cuvis_worker_settings_allocate');
            cworker_settings.Value.worker_count = p.Results.worker_count;
            cworker_settings.Value.poll_interval = p.Results.poll_interval ;
            cworker_settings.Value.keep_out_of_sequence = p.Results.keep_out_of_sequence ;
            cworker_settings.Value.worker_queue_size = p.Results.worker_queue_size ;
            
            
            
            [code,workerObj.sdk_handle]=calllib('cuvis','cuvis_worker_create', workerObj.sdk_handle, cworker_settings  );
            calllib('cuvis','cuvis_worker_settings_free',cworker_settings);
            clear cworker_settings  ;
            cuvis_helper_chklasterr(code);
            
            workerObj.cleanup = onCleanup(@()delete(workerObj));
            
            
            
        end
        
        
        
        function set_queue_limit(acqContObj,value)
            [code]=calllib('cuvis','cuvis_worker_set_queue_limit', acqContObj.sdk_handle, value);
            cuvis_helper_chklasterr(code);
        end
        
        function value  = get_queue_limit(acqContObj)
            qPtr = libpointer('int32Ptr',0);
            [code, value]=calllib('cuvis','cuvis_worker_get_queue_limit', acqContObj.sdk_handle, qPtr  );
            
            clear qPtr ;
            cuvis_helper_chklasterr(code);
        end
        
        function value  = get_queue_used(acqContObj)
            qPtr = libpointer('int32Ptr',0);
            [code, value]=calllib('cuvis','cuvis_worker_get_queue_used', acqContObj.sdk_handle, qPtr  );
            
            clear qPtr ;
            cuvis_helper_chklasterr(code);
        end
        
        
        function set_acq_cont(workerObj,acqCont)
            [code]=calllib('cuvis','cuvis_worker_set_acq_cont', workerObj.sdk_handle, acqCont.sdk_handle);
            cuvis_helper_chklasterr(code);
        end
        function set_proc_cont(workerObj,procCont)
            [code]=calllib('cuvis','cuvis_worker_set_proc_cont', workerObj.sdk_handle, procCont.sdk_handle);
            cuvis_helper_chklasterr(code);
        end
        function set_exporter(workerObj,exporter)
            [code]=calllib('cuvis','cuvis_worker_set_exporter', workerObj.sdk_handle, exporter.sdk_handle);
            cuvis_helper_chklasterr(code);
        end
        function set_viewer(workerObj,viewer)
            [code]=calllib('cuvis','cuvis_worker_set_viewer', workerObj.sdk_handle, viewer.sdk_handle);
            cuvis_helper_chklasterr(code);
        end
        
        function hasNext = has_next_measurement(workerObj)
            hasNextPtr = libpointer('int32Ptr',0);
            [code,nextint]=calllib('cuvis','cuvis_worker_has_next_result', workerObj.sdk_handle,  hasNextPtr);
            clear hasNextPtr ;
            cuvis_helper_chklasterr(code);
            hasNext = (nextint ~= 0);
            
        end
        
        
        function [isok, mesu, view] = get_next_mesurement(workerObj)
            
            
            mesuHandlePtr = libpointer('int32Ptr',0);
            viewHandlePtr = libpointer('int32Ptr',0);
            [code, mesuHandle, viewHandle]=calllib('cuvis','cuvis_worker_get_next_result', workerObj.sdk_handle, mesuHandlePtr, viewHandlePtr);
            clear mesuHandlePtr;
            clear viewHandlePtr;
            
            mesu = [];
            view = [];
            
            if ~strcmp(code,'status_ok')
                
                
                [msg]=calllib('cuvis','cuvis_get_last_error_msg');
                warning(msg);
                isok = false;
            end
            
            
            isok = true;
            
            if mesuHandle > 0
                mesu = cuvis_measurement(mesuHandle);
            end
            
            if viewHandle > 0
                
                dataCntPtr = libpointer('int32Ptr',0);
                [code,dataCnt]=calllib('cuvis','cuvis_view_get_data_count',viewHandle,dataCntPtr);
                clear dataCntPtr;
                cuvis_helper_chklasterr(code);
                
                
                for k=0:dataCnt-1
                    
                    
                    
                    dataptr = calllib('cuvis','cuvis_view_data_allocate');
                    [code, view_data] =calllib('cuvis','cuvis_view_get_data',viewHandle, k , dataptr);
                    calllib('cuvis','cuvis_view_data_free',dataptr);
                    cuvis_helper_chklasterr(code);
                    
                    id = deblank(char(view_data.id));
                    
                    if (strcmp(id,''))
                        id = ['unnamed_',num2str(k)];
                    end
                    
                    switch view_data.category
                        case 'view_category_image' % data
                            vtup.category = 'image';
                        case 'view_category_data' % image
                            vtup.category = 'data';
                    end
                    
                    vtup.show = view_data.show ~= 0;
                    image = view_data.data;
                    
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
                    
                    
                    
                    vtup.value = permute(reshape(image.raw.Value,[image.channels image.width image.height]),[3,2,1]);
                    
                    view.(id) = vtup;
                    %view.elemetns{k+1} = vtup;
                end
                
                
                calllib('cuvis','cuvis_view_free',viewHandle);
            end
            
        end
        
        
        function delete(workerObj)
            
            if workerObj.sdk_handle>0
                calllib('cuvis','cuvis_worker_free',workerObj.sdk_handle);
            end
            
            
        end
    end
end
