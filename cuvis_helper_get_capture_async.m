
function [isok, mesu] = cuvis_helper_get_capture_async(waitHandle,time_ms)
    mesu=0;

    mesuHandlePtr = libpointer('int32Ptr',0);
    [code, ~, mesuHandle] = calllib('cuvis','cuvis_async_capture_get',waitHandle,time_ms,mesuHandlePtr);
    clear mesuHandlePtr;
    
    if strcmp(code,'status_ok')
        % nothing to do.
        isok = true;
        mesu = cuvis_measurement(mesuHandle);
    else
        [msg]=calllib('cuvis','cuvis_get_last_error_msg');
        warning(msg);
        isok = false;
    end

end