Integrating ATS with ModSecurity V3 using LuaJIT with FFI
====

Using FFI, pure Lua. so you don't have to build when install. 
(still requires libmodsecurity.so)

Requirement 
====

libmodsecurity.so
----  

```
git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity
cd ModSecurity
git submodule init
git submodule update
git ./build.sh
git ./configure
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

How to Use
====
 - Copy ats-luajit-modsecurity.lua to specific location (e.g. /usr/local/var/lua)
 - Put the example modsecurity rule file (example.conf) to /usr/local/var/modsecurity , readable by the ATS process
 - Add a line in /usr/local/etc/trafficserver/plugin.config and restart ats

```
tslua.so /usr/local/var/lua/ats-luajit-modsecurity.lua
```

 - The example rule file will deny any request handled by the ATS with query parameter of (testparam=test) with a 403
   status response 

TODOs/Limitations
====
 - need to use "log" and "url" in ModSecurityIntervention and free the memory after use
 - pass in the ModSecurity conf instead of hardcoding it in the code
 - Extract out a luajit binding for ModSecuritythat can be reused in other place
 - Support for REQUEST_BODY / RESPONSE BODY examination (We need to uncompress the contents first if they are
   gzipped)
 - Support to reload the rule without restarting ATS
 - Need more thoughts on logging
 - How does this work with the lua engine inside ModSecurity V3?
 - Unit Test using busted
 - More functional testing needed. Ideally should test extensively with OWASP CRS ruleset
 - Performance testing - impact to latency and capacity 

License
====

This software is distributed under MIT-like license:

#### Copyright (c) 2017-2018 Shu Kit Chan

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
