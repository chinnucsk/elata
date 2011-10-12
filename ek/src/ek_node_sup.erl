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
-module(ek_node_sup).
-behaviour(gen_event).
-author(dmitry.kolesnikov@nokia.com).

%%
%% Observes node connection and restart, if it is broken
%%

-export([
   % gen_event
   init/1,
   handle_event/2,
   handle_call/2,
   handle_info/2,
   terminate/2,                      
   code_change/3
]).


%%%------------------------------------------------------------------
%%%
%%%  gen_event
%%%
%%%------------------------------------------------------------------
init([]) ->
   {ok, []}.
   
handle_event({join, Node}, S) -> 
   {ok, proplists:delete(Node, S)};
handle_event({leave, Node}, S) ->
   Cnt  = proplists:get_value(Node, S, 0),
   Wait = erlang:round(math:pow(2, erlang:min(10, Cnt)) * 1000),
   timer:apply_after(Wait, ek, connect, [Node]),
   {ok, [{Node, Cnt + 1} | proplists:delete(Node, S)]};
handle_event(Evt, State) ->
   {ok, State}.
   
handle_call(_Req, State) ->
   {ok, undefined, State}.
   
handle_info(_Msg, State) ->
   {ok, State}.
   
terminate(_Reason, _State) ->
   ok.

code_change(_OldVsn, State, _Extra) -> 
   {ok, State}.   