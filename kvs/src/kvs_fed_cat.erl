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
-module(kvs_fed_cat).
-behaviour(gen_server).
-author(dmitry.kolesnikov@nokia.com).

%%
%% Handles kvs federate events 
%%

-export([
   start_link/2,
   %% gen_server
   init/1, 
   handle_call/3,
   handle_cast/2, 
   handle_info/2, 
   terminate/2, 
   code_change/3
]).

-record(srv, {
   cat,
   uri
}).

%%
%% debug macro
-ifdef(DEBUG).
-define(DEBUG(M), error_logger:info_report([{?MODULE, self()}] ++ M)).
-else.
-define(DEBUG(M), true).
-endif.

%%
%%
start_link(Uri, Cat) ->
   gen_server:start_link(?MODULE, [Uri, Cat], []).

init([Uri, Cat]) ->
   ek:register(Uri),
   ?DEBUG([{fed, listen}, {uri, Uri}, {cat, Cat}]),
   {ok,
      #srv{
         cat   = Cat,
         uri   = Uri
      }
   }.
   
%%%------------------------------------------------------------------   
%%%
%%% gen_server
%%%
%%%------------------------------------------------------------------

%%
%%
handle_call(_Req, _From, S) ->
   {reply, undefined, S}.   
  
%%
%%
handle_cast(_Req, S) ->
   {noreply, S}.

%%
%%
handle_info({kvs_fed_put, Key, Val}, S) ->
   kvs:put(S#srv.cat, Key, Val),
   {noreply, S};
handle_info({kvs_fed_remove, Key}, S) ->
   kvs:remove(S#srv.cat, Key),
   {noreply, S};
handle_info(_Msg, S) ->
   {noreply, S}.
   
%%
%% terminate
terminate(_Reason, _State) ->
   ok.
   
%%
%%
code_change(_OldVsn, State, _Extra) ->
   {ok, State}.   
   
