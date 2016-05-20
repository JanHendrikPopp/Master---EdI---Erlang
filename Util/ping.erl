-module(ping).
-export([start_server/0,ping/1]).

start_server() -> spawn(fun() -> ping_server(0) end).

ping_server(N) ->
  receive
    {ping,P} -> P!{pong,N},
                ping_server(N+1)
  end.

ping(Server) -> Server!{ping,self()},
                receive
                  {pong,N} -> {pong,N}
                end.
