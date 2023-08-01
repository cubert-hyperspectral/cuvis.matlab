function cuvis_helper_chklib

if ~libisloaded('cuvis')
    error('library cuvis is not loaded');
end
