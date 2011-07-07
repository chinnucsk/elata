%%
%%   Copyright (c) 2011, Nokia Corporation
%%   All rights reserved.
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
-module(agt_rest_api).
-author(dmitry.kolesnikov@nokia.com).
-include("include/def.hrl").

-export([
   resources/0,
   content_types/0
]).

%% end-points
-export([
   telemetry/1,
   config/1
]).

%%
%% List of supported resources
resources() ->
   [
      {"r", "/telemetry", fun ?MODULE:telemetry/1},
      {"c", "/config",    fun ?MODULE:config/1}
   ].
   
content_types() ->
   [
      {"text/plain",               fun rest_mime_util:text_plain/1},
      {"application/octet-stream", fun rest_mime_util:octet_stream/1}
   ].
   
%%%------------------------------------------------------------------   
%%%
%%%   /telemetry
%%%
%%%------------------------------------------------------------------   
telemetry({read, _Path, _Req}) ->   
   keyval_store:to_list(kv_telemetry). 

%%%------------------------------------------------------------------   
%%%
%%%   /config
%%%
%%%------------------------------------------------------------------   
config({create, _Path, _Req, Input}) when is_list(Input) ->   
   lists:foreach(
      fun
         (X) when is_binary(X) ->
            keyval_store:create(kv_telemetry, kvset:new(X));
         (_) ->
            ok
      end,
      Input
   ),
   ok.