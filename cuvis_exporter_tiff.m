classdef cuvis_exporter_tiff < cuvis_exporter
    properties
    end
    properties (Access = private)
        cleanup;
        
    end
    methods (Access = private)
        
    end
    methods
        function exporterObj = cuvis_exporter_tiff(varargin)
            exporterObj@cuvis_exporter(varargin{:});
            
            cuvis_helper_chklib
            
            p = inputParser;
            p.KeepUnmatched=true;
            
            
            addParameter(p,'format','MultiChannel',@ischar);
            addParameter(p,'compression_mode','None',@ischar);
            
            
            parse(p,varargin{:});
            
            
            
            cargs=calllib('cuvis','cuvis_export_tiff_settings_allocate');
            
            
            exporterPtr = libpointer('int32Ptr',0);
            cargs.Value.format = ['tiff_format_',p.Results.format];
            cargs.Value.compression_mode = ['tiff_compression_mode_',p.Results.compression_mode];
            
            [code,exporterObj.sdk_handle]=calllib('cuvis','cuvis_exporter_create_tiff', exporterPtr, exporterObj.gargs,cargs);
            clear exporterPtr;
            calllib('cuvis','cuvis_export_tiff_settings_free',cargs);
            clear cargs;
            
            cuvis_helper_chklasterr(code);
            
        end
        
    end
end
