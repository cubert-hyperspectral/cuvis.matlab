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

        % need to copy files to current directory in order to get it running
        files = dir(fullfile(getenv('CUVIS'),'*.dll'));
        for k=1:length(files)
            if ~strcmp(files(k).name,'cuvis.dll')
                if ~exist([pwd,'/',files(k).name],'file')
                  copyfile(fullfile(getenv('CUVIS'),files(k).name), pwd);  
                end
            end
        end
        
        files = dir(fullfile(getenv('CUVIS'),'*.xml'));
        for k=1:length(files)
            if ~strcmp(files(k).name,'cuvis.dll')
                if ~exist([pwd,'/',files(k).name],'file')
                  copyfile(fullfile(getenv('CUVIS'),files(k).name), pwd);  
                end
            end
        end

        files = dir(fullfile(getenv('CUVIS'),'*.cti'));
        for k=1:length(files)
            if ~strcmp(files(k).name,'cuvis.dll')
                if ~exist([pwd,'/',files(k).name],'file')
                  copyfile(fullfile(getenv('CUVIS'),files(k).name), pwd);  
                end
            end
        end


        loadlibrary('cuvis');
        calllib('cuvis','cuvis_set_log_level',3);
        if ~(exist('settings_path','var'))
            calllib('cuvis','cuvis_init',fullfile(getenv('CUVIS'),'../','settings'));
        else
            calllib('cuvis','cuvis_init',settings_path);
        end
        
        cuvis_is_initialized = 1;
    end
end