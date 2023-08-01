function time_str = cuvis_helper_mktime(tm)

 time_str =datetime(tm,'ConvertFrom','epochtime','TicksPerSecond',1000);

end