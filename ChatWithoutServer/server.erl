-module(server).
-export([start/0]).

start() -> register(chat,self()),
           process_flag(trap_exit,true),
           loop([]).

loop(Clients) ->
  receive
    {connect,P,Name} ->
       case lookup(Clients,Name) of
         nothing  -> link(P),
                     P!{success,lists:map(fun({N,_}) -> N end,Clients),
                        self()},
                     broadcast({login,Name},Clients,42),
                     loop([{Name,P}|Clients]);
         {just,_} -> P!name_allocated,
                     loop(Clients)
       end;
    {logout,P} -> case lookup2(Clients,P) of
                    nothing -> loop(Clients);
                    {just,Name} -> NewClients = remove2(Clients,P),
                                   broadcast({logout,Name}, NewClients,42),
                                   loop(NewClients)
                  end;
    {msg,Msg,P} -> case lookup2(Clients,P) of
                     nothing -> loop(Clients);
                     {just,Name} -> broadcast({msg,Name,Msg}, Clients,P),
                                    loop(Clients)
                  end;
    {'EXIT',P,_} -> self()!{logout,P},
                    loop(Clients);
    Other -> base:printLn("unknown message: "++base:show(Other)),
             loop(Clients)
  end.

broadcast(_  ,[], _) -> ok;
broadcast(Msg,[{_,P}|Cs],P)  -> broadcast(Msg,Cs,P);
broadcast(Msg,[{_,P}|Cs],P1) -> P!Msg, broadcast(Msg,Cs,P1).

lookup([],        _) -> nothing;
lookup([{K,V}|_], K) -> {just,V};
lookup([_|KVs],   K) -> lookup(KVs,K).

lookup2([],        _) -> nothing;
lookup2([{V,K}|_], K) -> {just,V};
lookup2([_|VKs],   K) -> lookup2(VKs,K).

remove2([],_)         -> [];
remove2([{_,K}|Cs],K) -> Cs;
remove2([C|Cs], K)    -> [C|remove2(Cs,K)].

