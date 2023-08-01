classdef cuvis_viewer < handle
    properties
        sdk_handle;
    end
    properties (Access = private)
        cleanup;
    end
    methods (Access = private)
        
    end
    methods
        function viewerObj = cuvis_viewer(varargin)
            
            cuvis_helper_chklib
            viewerObj.sdk_handle=-1;
            cargs=[];
            viewerObj.cleanup = onCleanup(@()delete(viewerObj));
            
            
            
            p = inputParser;
            p.KeepUnmatched=false;
            %validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            
            
            
            addParameter(p,'pan_scale',0,@isnumeric);
            addParameter(p,'pan_sharpening_interpolation_type','NearestNeighbor',@ischar);
            addParameter(p,'pan_sharpening_algorithm','Noop',@ischar);
            addParameter(p,'complete',false,@islogical);
            addParameter(p,'userplugin',@ischar);
            
            
            
            parse(p,varargin{:});
            
            
            
            cargs=calllib('cuvis','cuvis_viewer_settings_allocate');
            
            
            
            cargs.Value.pan_scale=p.Results.pan_scale;
            
            cargs.Value.complete = p.Results.complete;
            
            switch p.Results.pan_sharpening_interpolation_type
                case 'NearestNeighbor'
                    cargs.Value.pan_interpolation_type = 0;
                case 'Linear'
                    cargs.Value.pan_interpolation_type = 1;
                case 'Cubic'
                    cargs.Value.pan_interpolation_type = 2;
                case 'Lanczos'
                    cargs.Value.pan_interpolation_type = 2;
                otherwise
                    error('pan_sharpening_interpolation_type not supported');
            end
            
            
            switch p.Results.pan_sharpening_algorithm
                case 'Noop'
                    cargs.Value.pan_algorithm = 0;
                case 'CubertMacroPixel'
                    cargs.Value.pan_algorithm = 1;
                otherwise
                    error('pan_sharpening_algorithm not supported');
            end
            
            ptr = libpointer('cstring', p.Results.userplugin);
            viewerPtr = libpointer('int32Ptr',0);
            cargs.Value.userplugin = ptr;
            
            
            [code,viewerObj.sdk_handle]=calllib('cuvis','cuvis_viewer_create', viewerPtr, cargs);
            
            clear viewerPtr;
            
            calllib('cuvis','cuvis_viewer_settings_free',cargs);
            clear cargs;
            clear ptr;
            
            cuvis_helper_chklasterr(code);
            
        end
        
        
        function view = apply(viewerObj, mesu)
            
            
            viewPtr = libpointer('int32Ptr',0);
            [code, viewHandle] = calllib('cuvis','cuvis_viewer_apply',viewerObj.sdk_handle, mesu.sdk_handle, viewPtr);
            clear viewPtr;
            cuvis_helper_chklasterr(code);
            
            dataCntPtr = libpointer('int32Ptr',0);
            [code,dataCnt]=calllib('cuvis','cuvis_view_get_data_count',viewHandle,dataCntPtr);
            clear dataCntPtr;
            cuvis_helper_chklasterr(code);
            
            view = [];
            
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
        
        
        
        function delete(viewerObj)
            
            if viewerObj.sdk_handle>0
                calllib('cuvis','cuvis_viewer_free',viewerObj.sdk_handle);
            end
            
            
        end
    end
end
