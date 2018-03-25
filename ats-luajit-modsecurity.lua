local ffi = require("ffi")

ffi.cdef[[

typedef struct ModSecurity ModSecurity;
ModSecurity* msc_init();
void msc_set_connector_info(ModSecurity *msc, const char *connector);
void msc_cleanup(ModSecurity *msc);

typedef struct Rules Rules;
Rules* msc_create_rules_set();
int msc_rules_add_file(Rules *rules, const char *file, const char **error);
int msc_rules_cleanup(Rules *rules);

typedef struct Transaction Transaction;
Transaction *msc_new_transaction(ModSecurity *ms, Rules *rules, void *logCbData);
int msc_process_connection(Transaction *transaction, const char *client, int cPort, const char *server, int sPort);
int msc_process_uri(Transaction *transaction, const char *uri, const char *protocol, const char *http_version);
int msc_add_request_header(Transaction *transaction, const unsigned char *key, const unsigned char *value);
int msc_process_request_headers(Transaction *transaction);
int msc_add_response_header(Transaction *transaction, const unsigned char *key, const unsigned char *value);
int msc_process_response_headers(Transaction *transaction, int code, const char* protocol);
int msc_process_logging(Transaction *transaction);
void msc_transaction_cleanup(Transaction *transaction);

typedef struct ModSecurityIntervention_t {
    int status;
    int pause;
    char *url;
    char *log;
    int disruptive;
} ModSecurityIntervention;
int msc_intervention(Transaction *transaction, ModSecurityIntervention *it);

]]

local msc = ffi.load("/usr/local/modsecurity/lib/libmodsecurity.so")

local mst = msc.msc_init()
msc.msc_set_connector_info(mst, "ModSecurity-test")

local rules = msc.msc_create_rules_set()
local error = ffi.new("const char*[?]", 128)
local result = msc.msc_rules_add_file(rules, "/usr/local/var/modsecurity/example.conf", error)

function do_global_read_request()
  local txn = msc.msc_new_transaction(mst, rules ,nil)

  local client_ip, client_port, client_ip_family = ts.client_request.client_addr.get_addr()
  local incoming_port = ts.client_request.client_addr.get_incoming_port()
  msc.msc_process_connection(txn, client_ip, client_port, "127.0.0.1", incoming_port)

  local uri = ts.client_request.get_uri()
  local query_params = ts.client_request.get_uri_args() or ''
  if (query_params ~= '') then 
    uri = uri .. '?' .. query_params
  end 
  msc.msc_process_uri(txn, uri, ts.client_request.get_method(), ts.client_request.get_version())

  local hdrs = ts.client_request.get_headers()
  for k, v in pairs(hdrs) do
    msc.msc_add_request_header(txn, k, v)
  end
  msc.msc_process_request_headers(txn)

  ts.debug("done with processing request")

  local iv = ffi.new("ModSecurityIntervention")
  iv.status = 200
  iv.disruptive = 0
  local iv_res = msc.msc_intervention(txn, iv)
  ts.debug("done with intervention ".. iv_res .. ' with status ' .. iv.status )

  if (iv.status ~= 200) then 
    ts.http.set_resp(iv.status)
    msc.msc_transaction_cleanup(txn)
    ts.debug("done with setting custom response")
    return 1
  end  

  ts.ctx["mst"] = txn
  ts.debug("done with setting context")

  return 0
end

function do_global_read_response()
  local txn = ts.ctx["mst"]
  
  if(txn == nil) then
    ts.debug("no transaction object")
    return 0
  end

  local hdrs = ts.server_response.get_headers()
  for k, v in pairs(hdrs) do
    msc.msc_add_response_header(txn, k, v)
  end
  msc.msc_process_response_headers(ts.server_response.get_status(), "HTTP/"..ts.server_response.get_version())

  ts.debug("done with processing response")  

  local iv = ffi.new("ModSecurityIntervention")
  iv.status = 200
  iv.disruptive = 0
  local iv_res = msc.msc_intervention(txn, iv)
  ts.debug("done with intervention ".. iv_res .. ' with status ' .. iv.status )

  if (iv.status ~= 200) then
    ts.http.set_resp(iv.status, "ModSecurity message")
    ts.ctx["mst"] = nil
    msc.msc_transaction_cleanup(txn)
    return 1
  end

  ts.ctx["mst"] = nil
  msc.msc_transaction_cleanup(txn)
  ts.debug("done with cleaning up context")
end

