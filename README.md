Integrating ATS with ModSecurity V3 using LuaJIT and FFI
====

Now you can have a WAF for ATS.

Requirement 
====

libmodsecurity.so
----  

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
 - Configure with option to enable experimental plugins

```
./configure --enable-experimental-plugins=yes --enable-debug=yes
```

httpbin
----
 - We need a service to generate error response code 
 - Accept request in this format "http[s]://<your domain>/<response code>" and generate a response with that status
   code.
 - Any service will do. httpbin is just one of many that does the job.

How to Use
====
 - Copy all lua files to /usr/local/var/lua
 - Put the example modsecurity rule file (example.conf) to /usr/local/var/modsecurity , readable by the ATS process
 - Add a line in /usr/local/etc/trafficserver/plugin.config and restart ats

```
tslua.so /usr/local/var/lua/ats-luajit-modsecurity.lua /usr/local/var/modsecurity/example.conf
```

 - Changes can be made to example.conf and can be reloaded without restarting ATS. Just follow instructions here - https://docs.trafficserver.apache.org/en/latest/appendices/command-line/traffic_ctl.en.html#cmdoption-traffic-ctl-config-arg-reload 
 - Open "ats-luajit-modsecurity.lua" and update the "STATUS_SERVICE" variable to your httpbin service accordingly.

Example rules (example.conf)
====
 - deny any request with query parameter of "testparam=test2" with a 403 status response 
 - return any request with query parameter of "testparam=test1" with 301 redirect response to https://www.yahoo.com/
 - override any response with header "test" equal to "1" with a 403 status response
 - override any response with header "test" equal to "2" with a 301 redirect response to https://www.yahoo.com/
 - write debug log out to /tmp/test.txt

TODOs/Limitations
====
 - Do not support REQUEST_BODY / RESPONSE BODY examination (We need to uncompress the contents first if they are
   gzipped. And that will be expensive operation for proxy)
 - How does this work with the lua engine inside ModSecurity V3?
 - Unit Test using busted framework
 - More functional testing needed. Ideally should test extensively with OWASP CRS ruleset
 - Performance testing - impact to latency and capacity 

License
====

This software is distributed under MIT-like license:

#### Copyright (c) 2018-2019 Shu Kit Chan

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
