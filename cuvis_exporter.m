classdef cuvis_exporter < handle
    properties
        sdk_handle;
        gargs;
    end
    properties (Access = private)
        cleanup;
    end
    methods (Access = private)
        
    end
    methods
        function exporterObj = cuvis_exporter(varargin)
            
            cuvis_helper_chklib
            exporterObj.sdk_handle=-1;
            exporterObj.gargs=[];
            exporterObj.cleanup = onCleanup(@()delete(exporterObj));
            
            p = inputParser;
            p.KeepUnmatched=true;
            validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            
            addParameter(p,'export_dir','.',@ischar);
            addParameter(p,'spectra_multiplier',1.0,validScalarPosNum);
            addParameter(p,'channel_selection','full',@ischar);
            addParameter(p,'pan_scale',0,@isnumeric);
            addParameter(p,'pan_sharpening_interpolation_type','NearestNeighbor',@ischar);
            addParameter(p,'pan_sharpening_algorithm','Noop',@ischar);
            addParameter(p,'add_pan',false,@islogical);
            addParameter(p,'add_fullscale_pan',false,@islogical);
            addParameter(p,'permissive',false,@islogical);
            
            parse(p,varargin{:});
            
            exporterObj.gargs=calllib('cuvis','cuvis_export_general_settings_allocate');
            exporterObj.gargs.Value.spectra_multiplier=p.Results.spectra_multiplier;
            exporterObj.gargs.Value.pan_scale=p.Results.pan_scale;
            exporterObj.gargs.Value.add_pan = p.Results.add_pan;
            exporterObj.gargs.Value.add_fullscale_pan = p.Results.add_fullscale_pan;
            exporterObj.gargs.Value.permissive = p.Results.permissive;
            
            switch p.Results.pan_sharpening_interpolation_type
                case 'NearestNeighbor'
                    exporterObj.gargs.Value.pan_interpolation_type = 0;
                case 'Linear'
                    exporterObj.gargs.Value.pan_interpolation_type = 1;
                case 'Cubic'
                    exporterObj.gargs.Value.pan_interpolation_type = 2;
                case 'Lanczos'
                    exporterObj.gargs.Value.pan_interpolation_type = 2;
                otherwise
                    error('pan_sharpening_interpolation_type not supported');
            end
            
            switch p.Results.pan_sharpening_algorithm
                case 'Noop'
                    exporterObj.gargs.Value.pan_algorithm = 0;
                case 'CubertMacroPixel'
                    exporterObj.gargs.Value.pan_algorithm = 1;
                otherwise
                    error('pan_sharpening_algorithm not supported');
            end
            
            exporterObj.gargs.Value.export_dir(:)  = 0;
            if length(p.Results.export_dir) > length(exporterObj.gargs.Value.export_dir) -1
                error('parameter exceeds max. length');
            end
            exporterObj.gargs.Value.export_dir(1:length(p.Results.export_dir)) = p.Results.export_dir;
            
            exporterObj.gargs.Value.channel_selection(:)=0;
            if length(p.Results.channel_selection) > length(exporterObj.gargs.Value.channel_selection)-1
                error('parameter exceeds max. length');
            end
            exporterObj.gargs.Value.channel_selection(1:length(p.Results.channel_selection)) = p.Results.channel_selection;
        end
        
        function apply(exporterObj, mesu)
            code = calllib('cuvis','cuvis_exporter_apply',exporterObj.sdk_handle, mesu.sdk_handle);
            cuvis_helper_chklasterr(code)
        end
        
        function flush(exporterObj)
            code = calllib('cuvis','cuvis_exporter_flush',exporterObj.sdk_handle);
            cuvis_helper_chklasterr(code)
        end
        
        function delete(exporterObj)
            if ~isempty(exporterObj.gargs)
                calllib('cuvis','cuvis_export_general_settings_free',exporterObj.gargs);
                clear gargs;
            end
            
            if exporterObj.sdk_handle>0
                calllib('cuvis','cuvis_exporter_free',exporterObj.sdk_handle);
            end
        end

    end
end
