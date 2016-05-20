-module(keyvaluestore).
-export([start/0,store/3,find/2]).

start() -> Server = spawn(fun() -> loop([]) end),
           register(kvserver,Server).

loop(DB) ->
  receive
    {store,K,V,P} -> case lookup(DB,K) of
                       nothing  -> P!stored,
                                   loop([{K,V}|DB]);
                       {just,_} -> P!allocated,
                                   loop(DB)
                     end;
    {lookup,K,P} -> P!lookup(DB,K),
                    loop(DB)
  end.

store(Server,K,V) ->
  Server!{store,K,V,self()},
  receive
    stored -> ok;
    allocated -> allocated
  end.

find(Server,K) ->
  Server!{lookup,K,self()},
  receive
    X -> X
  end.

lookup([],        _) -> nothing;
lookup([{K,V}|_], K) -> {just,V};
lookup([_|KVs],   K) -> lookup(KVs,K).

