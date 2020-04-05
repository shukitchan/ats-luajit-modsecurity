Integrating ATS with ModSecurity V3 using LuaJIT and FFI
====

Opensource WAF for ATS.

Requirement 
====

libmodsecurity.so
----  
 - Tested on master branch 

```
git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity
cd ModSecurity
git submodule init
git submodule update
./build.sh
./configure
make 
make install
``` 

Apache Traffic Server with ts_lua plugin
----
 - Tested on master branch

```
./configure --enable-debug=yes
```

How to Use
====
 - Copy all lua files to /usr/local/var/lua
 - Put the example modsecurity rule file (example.conf) to /usr/local/var/modsecurity , readable by the ATS process
 - Add a line in /usr/local/etc/trafficserver/plugin.config and restart ats

```
tslua.so --enable-reload /usr/local/var/lua/ats-luajit-modsecurity.lua /usr/local/var/modsecurity/example.conf
```

 - Changes can be made to example.conf and can be reloaded without restarting ATS. Just follow instructions here - https://docs.trafficserver.apache.org/en/latest/appendices/command-line/traffic_ctl.en.html#cmdoption-traffic-ctl-config-arg-reload 

Contents/Rules inside example.conf
====
 - deny any request with query parameter of "testparam=test2" with a 403 status response 
 - return any request with query parameter of "testparam=test1" with 301 redirect response to https://www.yahoo.com/
 - override any response with header "test" equal to "1" with a 403 status response
 - override any response with header "test" equal to "2" with a 301 redirect response to https://www.yahoo.com/
 - write debug log out to /tmp/test.txt

Working with CRS
====
 - Go to https://github.com/SpiderLabs/owasp-modsecurity-crs and get release v3.2.0
 - Uncompress the contents and copy crs-setup.conf.example to /usr/local/var/modsecurity and rename it to crs-setup.conf
 - Copy all files in "rules" directory to /usr/local/var/modsecurity/rules
 - Copy owasp.conf in this repository to /usr/local/var/modsecurity
 - Change /usr/local/etc/trafficserver/plugin.config to the following and restart ats

```
tslua.so --enable-reload /usr/local/var/lua/ats-luajit-modsecurity.lua /usr/local/var/modsecurity/owasp.conf
``` 
 - Rule ID 910100 in REQUEST-910-IP-REPUTATION.conf in "rules" directory requires GeoIP and have to be commented it out if you do not built the modsecurity library with it.
 - To turn on debugging, you can uncomment the following inside owasp.conf

```
SecDebugLog /tmp/debug.log
SecDebugLogLevel 9

```

TODOs/Limitations
====
 - No support for REQUEST_BODY examination (We need to buffer the request body for examination first before we send to
   origin.)
 - No support for RESPONSE BODY examination (We need to uncompress the contents first if they are
   gzipped. And that will be expensive operation for proxy)
 - How does this work with the lua engine inside ModSecurity V3?
 - Unit Test using busted framework
 - More functional testing needed.
 - Performance testing - impact to latency and capacity 

