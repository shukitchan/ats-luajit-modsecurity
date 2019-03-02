-- module containing values to be persisted across "traffic_ctl config reload"

local msc_config = {}

msc_config.rulesfile = "/usr/local/var/modsecurity/example.conf"
msc_config.rules = nil

return msc_config
