
function isok = cuvis_helper_chkasync(code)
if strcmp(code,'status_ok')
    % nothing to do.
    isok = true;
else
    [msg]=calllib('cuvis','cuvis_get_last_error_msg');
    warning(msg);
    isok = false;
end

end