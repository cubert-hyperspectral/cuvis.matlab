function vec= cuvis_load_capabilites(bitfield)
idx = 0;
vec = [];
if bitand(bitfield, 1) vec{idx+1}='ACQUISITION_CAPTURE'; idx = idx+1; end
if bitand(bitfield, 2) vec{idx+1}='ACQUISITION_TIMELAPSE'; idx = idx+1; end
if bitand(bitfield, 4) vec{idx+1}='ACQUISITION_CONTINUOUS'; idx = idx+1; end
if bitand(bitfield, 8) vec{idx+1}='ACQUISITION_SNAPSHOT'; idx = idx+1; end
if bitand(bitfield, 16) vec{idx+1}='ACQUISITION_SETINTEGRATIONTIME'; idx = idx+1; end
if bitand(bitfield, 32) vec{idx+1}='ACQUISITION_SETGAIN'; idx = idx+1; end
if bitand(bitfield, 64) vec{idx+1}='ACQUISITION_AVERAGING'; idx = idx+1; end
if bitand(bitfield, 128) vec{idx+1}='PROCESSING_SENSOR_RAW'; idx = idx+1; end
if bitand(bitfield, 256) vec{idx+1}='PROCESSING_CUBE_RAW'; idx = idx+1; end
if bitand(bitfield, 512) vec{idx+1}='PROCESSING_CUBE_REF'; idx = idx+1; end
if bitand(bitfield, 1024) vec{idx+1}='PROCESSING_CUBE_DARKSUBTRACT'; idx = idx+1; end
if bitand(bitfield, 2048) vec{idx+1}='PROCESSING_CUBE_FLATFIELDING'; idx = idx+1; end
if bitand(bitfield, 4096) vec{idx+1}='PROCESSING_CUBE_SPECTRALRADIANCE'; idx = idx+1; end
if bitand(bitfield, 8192) vec{idx+1}='PROCESSING_SAVE_FILE'; idx = idx+1; end
if bitand(bitfield, 16384) vec{idx+1}='PROCESSING_CLEAR_RAW'; idx = idx+1; end
if bitand(bitfield, 32768) vec{idx+1}='PROCESSING_CALC_LIVE'; idx = idx+1; end
if bitand(bitfield, 65536) vec{idx+1}='PROCESSING_AUTOEXPOSURE'; idx = idx+1; end
if bitand(bitfield, 131072) vec{idx+1}='PROCESSING_ORIENTATION'; idx = idx+1; end
if bitand(bitfield, 262144) vec{idx+1}='PROCESSING_SET_WHITE'; idx = idx+1; end
if bitand(bitfield, 524288) vec{idx+1}='PROCESSING_SET_DARK'; idx = idx+1; end
if bitand(bitfield, 1048576) vec{idx+1}='PROCESSING_SET_SPRADCALIB'; idx = idx+1; end
if bitand(bitfield, 2097152) vec{idx+1}='PROCESSING_SET_DISTANCECALIB'; idx = idx+1; end
if bitand(bitfield, 4194304) vec{idx+1}='PROCESSING_SET_DISTANCE_VALUE'; idx = idx+1; end
if bitand(bitfield, 8388608) vec{idx+1}='PROCESSING_USE_DARK_SPRADCALIB'; idx = idx+1; end
if bitand(bitfield, 16777216) vec{idx+1}='PROCESSING_USE_WHITE_SPRADCALIB'; idx = idx+1; end
if bitand(bitfield, 33554432) vec{idx+1}='PROCESSING_REQUIRE_WHITEDARK_REFLECTANCE'; idx = idx+1; end

end