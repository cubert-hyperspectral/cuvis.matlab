function cuvis_init(settings_path)
    
    
    [filepath,~,~]=fileparts(mfilename('fullpath'));
    addpath(filepath);
    addpath([filepath,'/../../../bin']);
    addpath([filepath,'/../../cuvis_c/lib']);
    
    files = dir([filepath,'/../../../bin/*.dll']);
    for k=1:length(files)
        if ~strcmp(files(k).name,'cuvis.dll')
            if ~exist([pwd,'/',files(k).name],'file')
              copyfile([filepath,'/../../../bin/',files(k).name], pwd);  
            end
        end
    end
    
      files = dir([filepath,'/../../../bin/*.xml']);
    for k=1:length(files)
        if ~strcmp(files(k).name,'cuvis.dll')
            if ~exist([pwd,'/',files(k).name],'file')
              copyfile([filepath,'/../../../bin/',files(k).name], pwd);  
            end
        end
    end
    
      files = dir([filepath,'/../../../bin/*.cti']);
    for k=1:length(files)
        if ~strcmp(files(k).name,'cuvis.dll')
            if ~exist([pwd,'/',files(k).name],'file')
              copyfile([filepath,'/../../../bin/',files(k).name], pwd);  
            end
        end
    end
    
    
    loadlibrary('cuvis');
    calllib('cuvis','cuvis_set_log_level',3);
    if ~(exist('settings_path','var'))
        calllib('cuvis','cuvis_init','C:\Program Files\CubertFuchsia\Bin\user\settings');
    else
        calllib('cuvis','cuvis_init',settings_path);
    end
    
    
end