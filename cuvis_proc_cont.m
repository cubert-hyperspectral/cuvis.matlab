classdef cuvis_proc_cont < handle
    properties
        sdk_handle;
    end
    properties (Access = private)
        cleanup;
        args;
    end
    methods (Access = private)
        
    end
    methods
        function procContObj = cuvis_proc_cont(data)
            
            cuvis_helper_chklib
            
            procContObj.sdk_handle=-1;
            procContObj.cleanup = onCleanup(@()delete(procContObj));
            
            procContObj.args=calllib('cuvis','cuvis_proc_args_allocate');
            
            switch class(data)
                case 'cuvis_calibration'
                    procContPtr = libpointer('int32Ptr',0);
                    
                    [code,procContObj.sdk_handle]=calllib('cuvis','cuvis_proc_cont_create_from_calib', data.sdk_handle,procContPtr);
                    clear procContPtr;
                    cuvis_helper_chklasterr(code);
                    
                    procContObj.set_processing_mode('Cube_Raw');
                case 'cuvis_measurement'
                    procContPtr = libpointer('int32Ptr',0);
                    [code,procContObj.sdk_handle]=calllib('cuvis','cuvis_proc_cont_create_from_mesu', data.sdk_handle, procContPtr);
                    clear procContPtr;
                    cuvis_helper_chklasterr(code);
                case 'cuvis_session_file'
                    procContPtr = libpointer('int32Ptr',0);
                    [code,procContObj.sdk_handle]=calllib('cuvis','cuvis_proc_cont_create_from_session_file', data.sdk_handle, procContPtr);
                    clear procContPtr;
                    cuvis_helper_chklasterr(code);
                    
                otherwise
                    
                    error('cannot create proc_context from argument');
            end
            
            procContObj.set_processing_mode('Cube_Raw');
            procContObj.set_allow_recalib(false);
        end
        
        function  set_processing_mode(procContObj, mode)
            
            procContObj.args.Value.processing_mode = mode;
            
            [code] = calllib('cuvis','cuvis_proc_cont_set_args', procContObj.sdk_handle, procContObj.args);
            cuvis_helper_chklasterr(code)
            
        end
        
        function set_allow_recalib(procContObj, allowRecalib)
            procContObj.args.Value.allow_recalib = allowRecalib;
            
            [code] = calllib('cuvis','cuvis_proc_cont_set_args', procContObj.sdk_handle, procContObj.args);
            
            cuvis_helper_chklasterr(code)
        end
        
        function  isCapable = is_capable(procContObj, mesu, mode, allow_recalib)
            
            
            if nargin < 4
                allow_recalib=false;
            end
            
            
            isCapablePtr = libpointer('int32Ptr',-1);
            
            cargs=calllib('cuvis','cuvis_proc_args_allocate');
            
            cargs.Value.processing_mode = mode;
            cargs.Value.allow_recalib = allow_recalib;
            
            
            [code, isCapable] = calllib('cuvis','cuvis_proc_cont_is_capable', procContObj.sdk_handle, mesu.sdk_handle,cargs, isCapablePtr);
            
            
            calllib('cuvis','cuvis_proc_args_free',cargs);
            clear cargs;
            
            clear isCapablePtr;
            
            
            
            cuvis_helper_chklasterr(code)
        end
        
        function  apply(procContObj, mesu)
            
            
            code = calllib('cuvis','cuvis_proc_cont_apply',procContObj.sdk_handle, mesu.sdk_handle);
            cuvis_helper_chklasterr(code)
            
            mesu.refreshData();
            
            
        end
        
        function set_reference(procContObj, mesu, type)
            
            switch(type)
                case 'dark'
                    type = 'Reference_Dark';
                case 'white'
                    type = 'Reference_White';
                case 'sprad'
                    type = 'Reference_SpRad';
                case 'distance'
                    type = 'Reference_Distance';
                    
                case 'whitedark'
                    type = 'Reference_WhiteDark';
            end
            
            [code] = calllib('cuvis','cuvis_proc_cont_set_reference', procContObj.sdk_handle, mesu.sdk_handle, type);
            
            cuvis_helper_chklasterr(code)
        end
        
        function clear_reference(procContObj, type)
            
            switch(type)
                case 'dark'
                    type = 'Reference_Dark';
                case 'white'
                    type = 'Reference_White';
                case 'sprad'
                    type = 'Reference_SpRad';
                case 'distance'
                    type = 'Reference_Distance';
                    
                case 'whitedark'
                    type = 'Reference_WhiteDark';
            end
            
            [code] = calllib('cuvis','cuvis_proc_cont_clear_reference', procContObj.sdk_handle, type);
            
            cuvis_helper_chklasterr(code)
        end
        
        function calc_distance(procContObj, distance_mm)
            
            [code] = calllib('cuvis','cuvis_proc_cont_calc_distance', procContObj.sdk_handle, distance_mm);
            
            cuvis_helper_chklasterr(code)
        end
        
        
        function mesu=get_reference(procContObj, type)
            
            switch(type)
                case 'dark'
                    type = 0;
                case 'white'
                    type = 1;
                case 'sprad'
                    type = 2;
                case 'distance'
                    type = 3;
            end
            
            
            mesuPtr = libpointer('int32Ptr',0);
            [code,sdk_handle]=calllib('cuvis','cuvis_proc_cont_get_reference', procContObj.sdk_handle, mesuPtr, type);
            
            clear mesuPtr;
            cuvis_helper_chklasterr(code);
            
            
            mesu=cuvis_measurement(sdk_handle);
            
            
        end
        
        function hasReference=has_reference(procContObj, type)
            
            
            
            switch(type)
                case 'dark'
                    type = 0;
                case 'white'
                    type = 1;
                case 'sprad'
                    type = 2;
                case 'distance'
                    type = 3;
            end
            
            hasReferencePtr = libpointer('int32Ptr',-1);
            
            
            
            [code, hasReference] = calllib('cuvis','cuvis_proc_cont_has_reference', procContObj.sdk_handle, type, hasReferencePtr);
            
            clear hasReferencePtr;
            
            cuvis_helper_chklasterr(code)
            
        end
        
        
        function delete(procContObj)
            
            if (procContObj.sdk_handle >=0)
                calllib('cuvis','cuvis_proc_cont_free',procContObj.sdk_handle);
            end
            
            calllib('cuvis','cuvis_proc_args_free',procContObj.args);
            
        end
    end
end
