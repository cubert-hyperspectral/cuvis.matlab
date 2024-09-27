classdef cuvis_exporter_cube < cuvis_exporter
    properties
    end
    properties (Access = private)
        cleanup;
        
    end
    methods (Access = private)
        
    end
    methods
        function exporterObj = cuvis_exporter_cube(varargin)
            exporterObj@cuvis_exporter(varargin{:});
            
            cuvis_helper_chklib
            
            p = inputParser;
            p.KeepUnmatched=true;
            
            validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            
            addParameter(p,'allow_fragmentation',false,@islogical);
            addParameter(p,'allow_overwrite',false,@islogical);
            addParameter(p,'allow_drop',false,@islogical);
            addParameter(p,'allow_session_file',true,@islogical);
            addParameter(p,'allow_info_file',true,@islogical);
            addParameter(p,'operation_mode','Software',@ischar);
            addParameter(p,'fps',0.0,@isdouble);
            addParameter(p,'soft_limit',20,validScalarPosNum);
            addParameter(p,'hard_limit',100,validScalarPosNum);
            addParameter(p,'max_buftime',10000,validScalarPosNum);
            addParameter(p,'full_export',false,@islogical);
            
            parse(p,varargin{:});
            
            
            
            cargs=calllib('cuvis','cuvis_save_args_allocate');
            
            
            cargs.Value.allow_fragmentation = p.Results.allow_fragmentation;
            cargs.Value.allow_overwrite = p.Results.allow_overwrite;
            cargs.Value.allow_drop = p.Results.allow_drop;
            cargs.Value.allow_session_file = p.Results.allow_session_file;
            cargs.Value.allow_info_file = p.Results.allow_info_file;
            cargs.Value.full_export = p.Results.full_export;
            
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
            
                exporterPtr = libpointer('int32Ptr',0);
            [code,exporterObj.sdk_handle]=calllib('cuvis','cuvis_exporter_create_cube', exporterPtr, exporterObj.gargs,cargs);
            clear exporterPtr;
            calllib('cuvis','cuvis_save_args_free',cargs);
            clear cargs;
            
            cuvis_helper_chklasterr(code);
            
        end
        
    end
end
