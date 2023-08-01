classdef cuvis_exporter_view < cuvis_exporter
    properties
    end
    properties (Access = private)
        cleanup;
        
    end
    methods (Access = private)
        
    end
    methods
        function exporterObj = cuvis_exporter_view(varargin)
            exporterObj@cuvis_exporter(varargin{:});
            
            cuvis_helper_chklib
            
            p = inputParser;
            p.KeepUnmatched=true;
            
            
            addParameter(p,'userplugin',@ischar);
            
            
            parse(p,varargin{:});
            
            
            
            cargs=calllib('cuvis','cuvis_export_view_settings_allocate');
            
            
            ptr = libpointer('cstring', p.Results.userplugin);
            exporterPtr = libpointer('int32Ptr',0);
            cargs.Value.userplugin = ptr;
            
            [code,exporterObj.sdk_handle]=calllib('cuvis','cuvis_exporter_create_view', exporterPtr, exporterObj.gargs,cargs);
            clear exporterPtr;
            calllib('cuvis','cuvis_export_view_settings_free',cargs);
            clear cargs;
            clear ptr;
            
            cuvis_helper_chklasterr(code);
            
        end
        
    end
end
