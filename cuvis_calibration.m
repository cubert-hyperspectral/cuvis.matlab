classdef cuvis_calibration < handle
    properties
        sdk_handle;
    end
    properties (Access = private)
        cleanup;
    end
    methods (Access = private)
        
    end
    methods
        function calibObj = cuvis_calibration(data)
            
            cuvis_helper_chklib
            calibObj.sdk_handle=-1;
            calibObj.cleanup = onCleanup(@()delete(calibObj));
            
            
            
            
            
            calibPtr = libpointer('int32Ptr',0);
            
            [code,~,calibObj.sdk_handle]=calllib('cuvis','cuvis_calib_create_from_path', data, calibPtr);
            clear calibPtr;
            
            cuvis_helper_chklasterr(code);
            
            
        end
        
         function value  = get_info(calibObj)
            ciPtr = libpointer('cuvis_calibration_info_allocate',0);
            [code, value]=calllib('cuvis','cuvis_calib_get_info', calibObj.sdk_handle, ciPtr );
            calllib('cuvis','cuvis_calibration_info_free',ciPtr  );
            clear ciPtr  ;
            cuvis_helper_chklasterr(code);
        end
        
        function capabilities = get_capabilities(calibObj, mode)
            if strcmp(mode, 'Software')
                op_mode = 1;
            elseif strcmp(mode, 'Internal')
                op_mode  = 2;
            elseif strcmp(mode, 'External')
                op_mode  = 3;
            else
                error('unkown mode');
            end
            capaPtr = libpointer('int32Ptr',0);
            [code,capa]=calllib('cuvis','cuvis_calib_get_capabilities', calibObj.sdk_handle, op_mode, capaPtr);
            clear capaPtr;
            cuvis_helper_chklasterr(code);
            
            capabilities = cuvis_load_capabilites(capa)
            
        end
        
        
        function delete(calibObj)
            
            if (calibObj.sdk_handle >=0)
                calllib('cuvis','cuvis_calib_free',calibObj.sdk_handle);
                
            end
            
        end
        
    end
end