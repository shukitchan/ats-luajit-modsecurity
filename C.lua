-- module containing common C functions to be used

local ffi = require("ffi")

ffi.cdef[[
  void free(void *ptr);
]]

return ffi.C
