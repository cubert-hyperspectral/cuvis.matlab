function cuvis_init(settings_path)
    global cuvis_is_initialized

    if isempty(getenv('CUVIS'))
        error('Could not locate CUVIS installation')
    end

    if isempty(cuvis_is_initialized)

        [filepath,~,~]=fileparts(mfilename('fullpath'));
        addpath(filepath);
        addpath(getenv('CUVIS'));
        addpath(fullfile(getenv('CUVIS'),'../','sdk','cuvis_c'));

        if ~libisloaded('cuvis')
            loadlibrary(fullfile(getenv('CUVIS'),'../','sdk','cuvis_c','cuvis.dll'),fullfile(getenv('CUVIS'),'../','sdk','cuvis_c','cuvis.h'));
        end
        calllib('cuvis','cuvis_set_log_level',3);
        if ~(exist('settings_path','var'))
            calllib('cuvis','cuvis_init',fullfile(getenv('CUVIS'),'../','settings'));
        else
            calllib('cuvis','cuvis_init',settings_path);
        end
        
        cuvis_is_initialized = 1;
    end
end
