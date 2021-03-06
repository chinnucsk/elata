%%
%%   Copyright (c) 2011, Nokia Corporation
%%   All Rights Reserved.
%%
%%    Redistribution and use in source and binary forms, with or without
%%    modification, are permitted provided that the following conditions
%%    are met:
%% 
%%     * Redistributions of source code must retain the above copyright
%%     notice, this list of conditions and the following disclaimer.
%%     * Redistributions in binary form must reproduce the above copyright
%%     notice, this list of conditions and the following disclaimer in
%%     the documentation and/or other materials provided with the
%%     distribution.
%%     * Neither the name of Nokia nor the names of its contributors
%%     may be used to endorse or promote products derived from this
%%     software without specific prior written permission.
%% 
%%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
%%   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
%%   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
%%   FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
%%   COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
%%   INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
%%   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%%   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
%%   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%%   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
%%   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
%%   EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE
%%
-module(kvs_rrd_tests).
-author(dmitry.kolesnikov@nokia.com).
-include_lib("eunit/include/eunit.hrl").

kvs_rrd_ipc_test_() ->
   {
      setup,
      fun setup_rrd_ipc/0,
      fun cleanup/1,
      [
      { "Put item", fun put/0},
      { "Has item", fun has/0},
      { "Get item", fun get/0}
      ]
   }.
   
kvs_rrd_cache_test_() ->
   {
      setup,
      fun setup_rrd_cache/0,
      fun cleanup/1,
      [
      { "Put item", fun put/0},
      { "Has item", fun has/0},
      { "Get item", fun get/0}
      ]
   }.
   
setup_rrd_ipc() ->
   application:start(ek),
   application:start(kvs),
   {ok, _} = kvs:new("kvs:test", [
      {storage, kvs_rrd},
      {codepath, "/usr/local/macports"},
      {datapath, "/private/tmp/kvs"}
   ]).

setup_rrd_cache() ->
   application:start(ek),
   application:start(kvs),
   {ok, _} = kvs:new("kvs:test", [
      {storage, kvs_rrd},
      {codepath, "/usr/local/macports"},
      {datapath, "/private/tmp/kvs"},
      iocache,
      {daemon, {"127.0.0.1", 42217}},
      {flush,  120},
      {iotime, 60}
   ]).   

cleanup(Pid) ->
   application:stop(kvs),
   application:stop(ek),
   timer:sleep(100),  %% switch a context to kill supervisor
   os:cmd("rm -R /private/tmp/kvs"),
   os:cmd("killall rrdcached").
   
put() ->
   Key = "http://localhost:80/mycase/tcp",
   ?assert(
      ok =:= kvs:put("kvs:test", Key, 1000)
   ),
   timer:sleep(500), %% RRD put is async, we have to wait before file is created
   ?assert(
      kvs:has("kvs:test/cache", "/http/localhost/80/mycase/tcp")
   ),
   ?assert(
      filelib:is_file("/private/tmp/kvs/http/localhost/80/mycase/tcp")
   ).

has() ->
   Key1 = "http://localhost:80/mycase/tcp",
   Key2 = "http://localhost:81/mycase/tcp",  
   ?assert(
      true =:= kvs:has("kvs:test", Key1)
   ),
   ?assert(
      false =:= kvs:has("kvs:test", Key2)
   ).
   
get() ->
   Key1 = "http://localhost:80/mycase/tcp",
   Key2 = "http://localhost:81/mycase/tcp",  
   ?assert(
      {ok, 1000} =:= kvs:get("kvs:test", Key1)
   ),
   ?assert(
      {error, not_found} =:= kvs:get("kvs:test", Key2)
   ).
