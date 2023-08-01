
function cuvis_helper_chklasterr(code)
if strcmp(code,'status_ok')==0
    
    [msg]=calllib('cuvis','cuvis_get_last_error_msg');
        error(msg);
    
end
end