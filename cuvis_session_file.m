classdef cuvis_session_file < handle
    properties
        sdk_handle;
    end
    properties (Access = private)
        cleanup;
    end
    methods (Access = private)
        
    end
    methods
        function calibObj = cuvis_session_file(data)
            
            cuvis_helper_chklib
            calibObj.sdk_handle=-1;
            calibObj.cleanup = onCleanup(@()delete(calibObj));
            
            
            
            
            
            sessPtr = libpointer('int32Ptr',0);
            
            [code,~,calibObj.sdk_handle]=calllib('cuvis','cuvis_session_file_load', data, sessPtr);
            clear sessPtr;
            
            cuvis_helper_chklasterr(code);
            
            
        end
        
        function measurement = get_measurement(sessObj,frameNo)
            
            mesuPtr = libpointer('int32Ptr',0);
            [code,copy_handle]=calllib('cuvis','cuvis_session_file_get_mesu',sessObj.sdk_handle, frameNo-1, mesuPtr );
            clear mesuPtr ;
            cuvis_helper_chklasterr(code);
            
            measurement = cuvis_measurement(copy_handle);
            
        end
        
        function measurement = get_measurement_non_dropped(sessObj,frameNo)
            
            mesuPtr = libpointer('int32Ptr',0);
            [code,copy_handle]=calllib('cuvis','cuvis_session_file_get_mesu_non_dropped',sessObj.sdk_handle, frameNo-1, mesuPtr );
            clear mesuPtr ;
            cuvis_helper_chklasterr(code);
            
            measurement = cuvis_measurement(copy_handle);
            
        end
        
        function value = get_size(sessObj)
            szPtr = libpointer('int32Ptr',0);
            [code, value]=calllib('cuvis','cuvis_session_file_get_size', sessObj.sdk_handle, szPtr  );
            
            clear szPtr ;
            cuvis_helper_chklasterr(code);
        end
        
        function value = get_size_non_dropped(sessObj)
            szPtr = libpointer('int32Ptr',0);
            [code, value]=calllib('cuvis','cuvis_session_file_get_size_non_dropped', sessObj.sdk_handle, szPtr  );
            
            clear szPtr ;
            cuvis_helper_chklasterr(code);
        end
        
        
        function value  = get_fps(sessObj)
            fpsPtr = libpointer('doublePtr',0);
            [code, value]=calllib('cuvis','cuvis_session_file_get_fps', sessObj.sdk_handle, fpsPtr);
            
            clear fpsPtr;
            cuvis_helper_chklasterr(code);
        end
        
        function value  = get_operation_mode(sessObj)
            opPtr = libpointer('cuvis_operation_mode_t',0);
            [code, value]=calllib('cuvis','cuvis_session_file_get_operation_mode', sessObj.sdk_handle, opPtr );
            
            clear opPtr;
            cuvis_helper_chklasterr(code);
        end
        
        function delete(sessObj)
            
            if (sessObj.sdk_handle >=0)
                calllib('cuvis','cuvis_session_file_free',sessObj.sdk_handle);
                
            end
            
        end
        
    end
end