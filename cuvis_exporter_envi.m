classdef cuvis_exporter_envi < cuvis_exporter
    properties
    end
    properties (Access = private)
        cleanup;
        
    end
    methods (Access = private)
        
    end
    methods
        function exporterObj = cuvis_exporter_envi(varargin)
            exporterObj@cuvis_exporter(varargin{:});
            
            cuvis_helper_chklib
            
            %             p = inputParser;
            %             p.KeepUnmatched=true;
            %             validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            %
            %             addParameter(p,'export_dir','.',@ischar);
            %             addParameter(p,'spectra_multiplier',1.0,validScalarPosNum);
            %             addParameter(p,'channel_selection','full',@ischar);
            %
            %             parse(p,varargin{:});
            %
            %             exporterObj.general_args.export_dir = p.Results.export_dir;
            %             exporterObj.general_args.channel_selection = p.Results.channel_selection;
            %             exporterObj.general_args.spectra_multiplier=p.Results.spectra_multiplier;
            
            
            
            
            
            exporterPtr = libpointer('int32Ptr',0);
            
            [code,exporterObj.sdk_handle]=calllib('cuvis','cuvis_exporter_create_envi', exporterPtr, exporterObj.gargs);
            clear exporterPtr;
            
            
            cuvis_helper_chklasterr(code);
            
        end
        
    end
end
