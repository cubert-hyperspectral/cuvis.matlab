function str = cuvis_version()

cuvis_helper_chklib
keyStr= libpointer('cstring', repmat(' ',1,256));
[code,str]=calllib('cuvis','cuvis_version',keyStr);
clear keyStr;
cuvis_helper_chklasterr(code);

end