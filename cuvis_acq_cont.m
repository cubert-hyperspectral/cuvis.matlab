classdef cuvis_acq_cont < handle
    properties
        sdk_handle;
        components;
    end
    properties (Access = private)
        cleanup;
    end
    methods (Access = private)
        
    end
    methods
        function acqContObj = cuvis_acq_cont(data)
            
            
            
            
            
            cuvis_helper_chklib
            acqContObj.sdk_handle=-1;
            acqContObj.cleanup = onCleanup(@()delete(acqContObj));
            
            
            
            acquContPtr = libpointer('int32Ptr',0);
            
            [code,acqContObj.sdk_handle]=calllib('cuvis','cuvis_acq_cont_create_from_calib', data.sdk_handle, acquContPtr );
            clear acquContPtr ;
            cuvis_helper_chklasterr(code);
            
            
            
            
            countptr = libpointer('int32Ptr',0);
            [code, compcount] = calllib('cuvis','cuvis_acq_cont_get_component_count', acqContObj.sdk_handle, countptr);
            clear countptr;
            cuvis_helper_chklasterr(code);
            
            for k=0:compcount-1
                
                comInfoPtr = calllib('cuvis','cuvis_cuvis_component_info_allocate');
                [code,compInfo]=calllib('cuvis','cuvis_acq_cont_get_component_info',acqContObj.sdk_handle, k, comInfoPtr);
                calllib('cuvis','cuvis_cuvis_component_info_free',comInfoPtr);
                clear comInfoPtr;
                cuvis_helper_chklasterr(code);
                
                acqContObj.components{k+1}.type = compInfo.type;
                acqContObj.components{k+1}.id = k;
                acqContObj.components{k+1}.displayname =  deblank(char(compInfo.displayname));
                acqContObj.components{k+1}.sensorinfo =  deblank(char(compInfo.sensorinfo));
                acqContObj.components{k+1}.userfield =  deblank(char(compInfo.userfield));
                acqContObj.components{k+1}.pixelformat =  deblank(char(compInfo.pixelformat));
                
            end
            
        end
        
        function hasNext = has_next_measurement(acqContObj)
            hasNextPtr = libpointer('int32Ptr',0);
            [code,nextint]=calllib('cuvis','cuvis_acq_cont_has_next_measurement', acqContObj.sdk_handle,  hasNextPtr);
            clear hasNextPtr ;
            cuvis_helper_chklasterr(code);
            hasNext = (nextint ~= 0);
            
        end
        
        
        function [isok, mesu] = get_next_mesurement(acqContObj, time_ms)
            
            
            mesuHandlePtr = libpointer('int32Ptr',0);
            [code, mesuHandle]=calllib('cuvis','cuvis_acq_cont_get_next_measurement', acqContObj.sdk_handle, mesuHandlePtr, time_ms);
            clear mesuHandlePtr;
            
            if strcmp(code,'status_ok')
                % nothing to do.
                isok = true;
                mesu = cuvis_measurement(mesuHandle);
            else
                [msg]=calllib('cuvis','cuvis_get_last_error_msg');
                warning(msg);
                isok = false;
            end
        end
        
        
        
        
        
        function waitObj = capture(acqContObj)
            waitHandlePtr = libpointer('int32Ptr',0);
            
            [code, waitHandle]=calllib('cuvis','cuvis_acq_cont_capture_async', acqContObj.sdk_handle, waitHandlePtr);
            clear waitHandlePtr ;
            cuvis_helper_chklasterr(code);
            waitObj=@(time_ms) cuvis_helper_get_capture_async(waitHandle,time_ms);
        end
        
        
        
        function waitObj = set_operation_mode(acqContObj,value)
            if strcmp(value, 'Software')
                mode = 1;
            elseif strcmp(value, 'Internal')
                mode = 2;
            elseif strcmp(value, 'External')
                mode = 3;
            else
                error('unkown mode');
            end
            waitHandlePtr = libpointer('int32Ptr',0);
            
            [code, waitHandle]=calllib('cuvis','cuvis_acq_cont_operation_mode_set_async', acqContObj.sdk_handle, waitHandlePtr, mode);
            clear waitHandlePtr ;
            cuvis_helper_chklasterr(code);
            waitObj=@(time_ms) cuvis_helper_chkasync(calllib('cuvis','cuvis_async_call_get',waitHandle,time_ms));
        end
        
        
        function value  = get_operation_mode(acqContObj)
            opPtr = libpointer('cuvis_operation_mode_t',0);
            [code, value]=calllib('cuvis','cuvis_acq_cont_operation_mode_get', acqContObj.sdk_handle, opPtr );
            
            clear opPtr;
            cuvis_helper_chklasterr(code);
        end
        
        function waitObj = set_average(acqContObj,value)
            waitHandlePtr = libpointer('int32Ptr',0);
            
            [code, waitHandle]=calllib('cuvis','cuvis_acq_cont_average_set_async', acqContObj.sdk_handle, waitHandlePtr, value);
            clear waitHandlePtr ;
            cuvis_helper_chklasterr(code);
            waitObj=@(time_ms) cuvis_helper_chkasync(calllib('cuvis','cuvis_async_call_get',waitHandle,time_ms));
        end
        
        function value  = get_average(acqContObj)
            avgPtr = libpointer('int32Ptr',0);
            [code, value]=calllib('cuvis','cuvis_acq_cont_average_get', acqContObj.sdk_handle, avgPtr );
            
            clear avgPtr;
            cuvis_helper_chklasterr(code);
        end
        
        function value  = get_bandwidth(acqContObj)
            bwPtr = libpointer('int32Ptr',0);
            [code, value]=calllib('cuvis','cuvis_acq_cont_bandwidth_get', acqContObj.sdk_handle, bwPtr );
            
            clear bwPtr;
            cuvis_helper_chklasterr(code);
        end
        
        
        
        function set_queue_size(acqContObj,value)
            [code]=calllib('cuvis','cuvis_acq_cont_queue_size_set', acqContObj.sdk_handle, value);
            cuvis_helper_chklasterr(code);
        end
        
        function value  = get_queue_size(acqContObj)
            qPtr = libpointer('int32Ptr',0);
            [code, value]=calllib('cuvis','cuvis_acq_cont_queue_size_get', acqContObj.sdk_handle, qPtr  );
            
            clear qPtr ;
            cuvis_helper_chklasterr(code);
        end
        
        function value  = get_queue_used(acqContObj)
            qPtr = libpointer('int32Ptr',0);
            [code, value]=calllib('cuvis','cuvis_acq_cont_queue_used_get', acqContObj.sdk_handle, qPtr  );
            
            clear qPtr ;
            cuvis_helper_chklasterr(code);
        end
        
        
        function waitObj = set_integration_time(acqContObj,value)
            waitHandlePtr = libpointer('int32Ptr',0);
            
            [code, waitHandle]=calllib('cuvis','cuvis_acq_cont_integration_time_set_async', acqContObj.sdk_handle, waitHandlePtr, value);
            clear waitHandlePtr ;
            cuvis_helper_chklasterr(code);
            waitObj=@(time_ms) cuvis_helper_chkasync(calllib('cuvis','cuvis_async_call_get',waitHandle,time_ms));
        end
        
        function value  = get_integration_time(acqContObj)
            inttimePtr = libpointer('doublePtr',0);
            [code, value]=calllib('cuvis','cuvis_acq_cont_integration_time_get', acqContObj.sdk_handle, inttimePtr );
            
            clear inttimePtr;
            cuvis_helper_chklasterr(code);
        end
        
        function waitObj = set_auto_exp(acqContObj,value)
            waitHandlePtr = libpointer('int32Ptr',0);
            
            [code, waitHandle]=calllib('cuvis','cuvis_acq_cont_auto_exp_set_async', acqContObj.sdk_handle, waitHandlePtr, value);
            clear waitHandlePtr ;
            cuvis_helper_chklasterr(code);
            waitObj=@(time_ms) cuvis_helper_chkasync(calllib('cuvis','cuvis_async_call_get',waitHandle,time_ms));
        end
        
        function value  = get_auto_exp(acqContObj)
            inttimePtr = libpointer('int32Ptr',0);
            [code, value]=calllib('cuvis','cuvis_acq_cont_auto_exp_get', acqContObj.sdk_handle, inttimePtr );
            
            clear inttimePtr;
            cuvis_helper_chklasterr(code);
        end
        
        function waitObj = set_fps(acqContObj,value)
            waitHandlePtr = libpointer('int32Ptr',0);
            
            [code, waitHandle]=calllib('cuvis','cuvis_acq_cont_fps_set_async', acqContObj.sdk_handle, waitHandlePtr, value);
            clear waitHandlePtr ;
            cuvis_helper_chklasterr(code);
            waitObj=@(time_ms) cuvis_helper_chkasync(calllib('cuvis','cuvis_async_call_get',waitHandle,time_ms));
        end
        
        function value  = get_fps(acqContObj)
            fpsPtr = libpointer('doublePtr',0);
            [code, value]=calllib('cuvis','cuvis_acq_cont_fps_get', acqContObj.sdk_handle, fpsPtr);
            
            clear fpsPtr;
            cuvis_helper_chklasterr(code);
        end
        
        
        function waitObj = set_preview_mode(acqContObj,value)
            waitHandlePtr = libpointer('int32Ptr',0);
            
            [code, waitHandle]=calllib('cuvis','cuvis_acq_cont_preview_mode_set_async', acqContObj.sdk_handle, waitHandlePtr, value);
            clear waitHandlePtr ;
            cuvis_helper_chklasterr(code);
            waitObj=@(time_ms) cuvis_helper_chkasync(calllib('cuvis','cuvis_async_call_get',waitHandle,time_ms));
        end
        
        function value  = get_preview_mode(acqContObj)
            prevModePtr = libpointer('doublePtr',0);
            [code, value]=calllib('cuvis','cuvis_acq_cont_preview_mode_get', acqContObj.sdk_handle, prevModePtr);
            
            clear prevModePtr;
            cuvis_helper_chklasterr(code);
        end
        
        
        function value = get_state(acqContObj)
            cstate=libpointer('cuvis_hardware_state_t',1);
            [code,value]=calllib('cuvis','cuvis_acq_cont_get_state', acqContObj.sdk_handle,cstate);
            clear cstate;
            
            cuvis_helper_chklasterr(code);
            
        end
        
        
        
        function waitObj = set_gain(acqContObj,id,value)
            waitHandlePtr = libpointer('int32Ptr',0);
            
            [code, waitHandle]=calllib('cuvis','cuvis_comp_gain_set_async', acqContObj.sdk_handle, id -1, waitHandlePtr, value);
            clear waitHandlePtr ;
            cuvis_helper_chklasterr(code);
            waitObj=@(time_ms) cuvis_helper_chkasync(calllib('cuvis','cuvis_async_call_get',waitHandle,time_ms));
        end
        
        function value  = get_gain(acqContObj,id)
            gainPtr = libpointer('doublePtr',0);
            [code, value]=calllib('cuvis','cuvis_comp_gain_get', acqContObj.sdk_handle, id -1, gainPtr );
            
            clear gainPtr ;
            cuvis_helper_chklasterr(code);
        end
        
        function value  = get_temperature(acqContObj,id)
            tempPtr = libpointer('intPtr',0);
            [code, value]=calllib('cuvis','cuvis_comp_temperature_get', acqContObj.sdk_handle, id -1, tempPtr  );
            
            clear tempPtr;
            cuvis_helper_chklasterr(code);
        end
        
        function value  = get_comp_bandwidth(acqContObj,id)
            bwPtr = libpointer('int32Ptr',0);
            [code, value]=calllib('cuvis','cuvis_comp_bandwidth_get', acqContObj.sdk_handle, id -1, bwPtr );
            
            clear bwPtr;
            cuvis_helper_chklasterr(code);
        end
        
        function value  = get_comp_driver_queue_size(acqContObj,id)
            bwPtr = libpointer('int32Ptr',0);
            [code, value]=calllib('cuvis','cuvis_comp_driver_queue_size_get', acqContObj.sdk_handle, id -1, bwPtr );
            
            clear bwPtr;
            cuvis_helper_chklasterr(code);
            
        end
        
        function value  = get_comp_driver_queue_used(acqContObj,id)
            bwPtr = libpointer('int32Ptr',0);
            [code, value]=calllib('cuvis','cuvis_comp_driver_queue_used_get', acqContObj.sdk_handle, id -1, bwPtr );
            
            clear bwPtr;
            cuvis_helper_chklasterr(code);
            
        end
        
        
        function value  = get_comp_hardware_queue_size(acqContObj,id)
            bwPtr = libpointer('int32Ptr',0);
            [code, value]=calllib('cuvis','cuvis_comp_hardware_queue_size_get', acqContObj.sdk_handle, id -1, bwPtr );
            
            clear bwPtr;
            cuvis_helper_chklasterr(code);
            
        end
        
        function value  = get_comp_hardware_queue_used(acqContObj,id)
            bwPtr = libpointer('int32Ptr',0);
            [code, value]=calllib('cuvis','cuvis_comp_hardware_queue_used_get', acqContObj.sdk_handle, id -1, bwPtr );
            
            clear bwPtr;
            cuvis_helper_chklasterr(code);
            
        end
        
        function waitObj = set_integration_time_factor(acqContObj,id,value)
            waitHandlePtr = libpointer('int32Ptr',0);
            
            [code, waitHandle]=calllib('cuvis','cuvis_comp_integration_time_factor_set_async', acqContObj.sdk_handle, id -1, waitHandlePtr, value);
            clear waitHandlePtr ;
            cuvis_helper_chklasterr(code);
            waitObj=@(time_ms) cuvis_helper_chkasync(calllib('cuvis','cuvis_async_call_get',waitHandle,time_ms));
        end
        
        function value  = get_integration_time_factor(acqContObj,id)
            integration_time_factorPtr = libpointer('doublePtr',0);
            [code, value]=calllib('cuvis','cuvis_comp_integration_time_factor_get', acqContObj.sdk_handle, id -1, integration_time_factorPtr );
            
            clear integration_time_factor;
            cuvis_helper_chklasterr(code);
        end
        
        function value  = get_online(acqContObj,id)
            onlinePtr = libpointer('int32Ptr',0);
            [code, value_int]=calllib('cuvis','cuvis_comp_online_get', acqContObj.sdk_handle, id -1, onlinePtr );
            
            value = value_int ~= 0;
            
            clear onlinePtr;
            cuvis_helper_chklasterr(code);
        end
        
        
        function [name, session_no, sequence_no] = get_session_info(acqContObj)
            
            sessPtr = calllib('cuvis','cuvis_session_info_allocate');
            [code,sess]=calllib('cuvis','cuvis_acq_cont_get_session_info',acqContObj.sdk_handle, sessPtr );
            calllib('cuvis','cuvis_session_info_free',sessPtr );
            clear sessPtr ;
            cuvis_helper_chklasterr(code);
            
            name = deblank(char(sess.name));
            session_no = sess.session_no;
            sequence_no= sess.sequence_no;
            
        end
        
        function set_session_info(acqContObj,name, session_no, sequence_no)
            if nargin <= 2
                session_no = 0;
            end
            if nargin <= 3
                sequence_no = 0;
            end
            sessPtr = calllib('cuvis','cuvis_session_info_allocate');
            
            
            
            
            sessPtr.Value.name(:) = 0;
            
            if length(name) > length(sessPtr.Value.name) -1
                error('parameter exceeds max. length');
            end
            
            sessPtr.Value.name(1:length(name)) = name;
            
            sessPtr.Value.session_no = session_no;
            sessPtr.Value.sequence_no= sequence_no;
            
            
            [code]=calllib('cuvis','cuvis_acq_cont_set_session_info',acqContObj.sdk_handle, sessPtr );
            calllib('cuvis','cuvis_session_info_free',sessPtr );
            clear sessPtr ;
            cuvis_helper_chklasterr(code);
        end
        
        function waitObj = set_continuous(acqContObj,value)
            waitHandlePtr = libpointer('int32Ptr',0);
            
            [code, waitHandle]=calllib('cuvis','cuvis_acq_cont_continuous', acqContObj.sdk_handle, waitHandlePtr, value);
            clear waitHandlePtr ;
            cuvis_helper_chklasterr(code);
            waitObj=@(time_ms) cuvis_helper_chkasync(calllib('cuvis','cuvis_async_call_get',waitHandle,time_ms));
        end
        
        function delete(acqContObj)
            
            if (acqContObj.sdk_handle >=0)
                calllib('cuvis','cuvis_acq_cont_free',acqContObj.sdk_handle);
                
            end
            
        end
        
    end
end