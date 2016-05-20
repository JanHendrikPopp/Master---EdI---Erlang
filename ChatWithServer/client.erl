-module(client).
-export([connect/2]).
-import(base,[print/1,printLn/1,getLn/0,getLn/1,show/1]).

connect(Name,Node) ->
  {chat,Node} ! {connect, self(), Name},
  receive
    {success,Clients,Server} ->
       printLn("Welcome in this nice chat."),
       printLn(Clients),
       Me = self(),
       spawn(fun() -> keyboard(Server, Name, Me) end),
       clientReceiver();
    name_allocated -> printLn("Name already in use, sorry.")
  after 2000 ->
    printLn("No connection to server.")
  end.

clientReceiver() -> 
  receive
    {login,Name}  -> printLn(Name++" joined the chat."),
                     clientReceiver();
    {logout,Name} -> printLn(Name++" left the chat."),
                     clientReceiver();
    {msg,Name,Msg} -> printLn(Name++": "++Msg),
                      clientReceiver();
    stop          -> ok                  
  end.

keyboard(Server,Name,Client) ->
  Str = getLn(Name++"> "),
  case Str of
    "bye" -> Server!{logout,Client},
             Client!stop;
    _     -> Server!{msg,Str,Client},
             keyboard(Server,Name,Client)
  end.

