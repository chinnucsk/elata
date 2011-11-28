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
-module(hf_http).
-author(sergey.boldyrev@nokia.com).
-author(dmitry.kolesnikov@nokia.com).

%%
%% High order-function: http computation
%%

-export([
   get/3,
   recv/2,
   recv/3
]).


%%
%% get(Uri, Sock, Opts) -> [Uri, Sock]
%%
%% sends GET request
%%
get({Mod, Sock}, {Schema, Auth, Path} = Uri, Opts) ->
   % authority & path depends on proxy option
   {Rauth, Rpath} = case proplists:get_value(proxy, Opts) of
      undefined ->
         {Auth, Path};
      Proxy     -> 
         {ek_uri:authority(Proxy), ek_uri:to_binary(Uri)}      
   end,
   % request headers
   Head = case proplists:get_value(header, Opts) of
      undefined -> <<>>;
      List      -> list_to_binary([<<H/binary, ": ", V/binary, "\r\n">> || {H, V} <- List])
   end,
   Req = <<
      "GET ", Rpath/binary, " HTTP/1.1\r\n",
      "Connection: close\r\n",
      "Accept: */*\r\n",
      "Host: ", Rauth/binary, "\r\n",
      Head/binary,
      "\r\n"
   >>,
   Mod:send(Sock, Req),
   [{Mod, Sock}, Uri].
   

%%
%% Receive 1st byte
recv({Mod, Sock}, Uri) ->
   case Mod:recv(Sock, 0) of
      {ok, Pckt}  -> [{Mod, Sock}, Uri, Pckt];
      {error, _}  -> [{Mod, Sock}, Uri]
   end.   

%%
%%
recv({Mod, Sock}, Uri, Data) -> 
   case Mod:recv(Sock, 0) of
      {ok,      Pckt}  ->
         recv({Mod, Sock}, Uri, <<Data/binary, Pckt/binary>>);
      {error, closed}  ->
         [{Mod, Sock}, Uri, Data]
   end.
      
   