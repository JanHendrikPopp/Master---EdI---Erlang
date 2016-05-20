-module(client).
-export([connect/2,create/1]).
-import(base,[print/1,printLn/1,getLn/0,getLn/1,show/1]).
-import(lists,[delete/2]).

connect(Name,Node) ->
  {chat,Node} ! {connect, self(), Name},
  receive
    {success,Clients,_} ->
       register(chat,self()),
       process_flag(trap_exit,true),
       printLn("Welcome in this nice chat."),
       printLn(Clients),
       Me = self(),
       spawn(fun() -> keyboard(Me, Name) end),
       clientReceiver(Clients);
    name_allocated -> printLn("Name already in use, sorry.")
  after 2000 ->
    printLn("No connection to server.")
  end.

create(Name) ->
  register(chat,self()),
  process_flag(trap_exit,true),
  printLn("You created a chat room."),
  Me = self(),
  spawn(fun() -> keyboard(Me, Name) end),
  clientReceiver([{Name,Me}]).

clientReceiver(Clients) ->
  receive
    {connect,P,Name}      -> case lookup(Clients,Name) of
                                nothing  -> link(P),
                                            P!{success,[{Name,P}|Clients],self()},
                                            printLn(Name++" joined the chat."),
                                            broadcast({login,Name,P},[{Name,P}|Clients],self()),
                                            clientReceiver([{Name,P}|Clients]);
                                {just,_} -> P!name_allocated,
                                            clientReceiver(Clients)
                              end,
                              clientReceiver(Clients);
    {login,Name,P}        -> printLn(Name++" joined the chat."),
                             clientReceiver([{Name,P}|Clients]);
    {logout,Name,P}       -> printLn(Name++" left the chat."),
                             clientReceiver(delete({Name,P}, Clients));
    {msg,Name,Msg}        -> printLn(Name++": "++Msg),
                             clientReceiver(Clients);
    {broadcast,Name,Str}  -> broadcast({msg,Name,Str}, Clients,self()),
                             clientReceiver(Clients);
    {stop,Name}           -> broadcast({logout,Name,self()},Clients,self()),
                             ok;
    {'EXIT',P,_}          -> case lookup2(Clients,P) of
                              nothing -> clientReceiver(Clients);
                              {just,Name} -> broadcast({logout,Name,P}, Clients,P),
                                             clientReceiver(Clients)
                              end
  end.

keyboard(Client,Name) ->
  Str = getLn(Name++"> "),
  case Str of
    "bye" -> Client!{stop,Name};
    _     -> Client!{broadcast, Name, Str},
             keyboard(Client, Name)
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
