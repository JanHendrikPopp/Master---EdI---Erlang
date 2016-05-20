-module(phil).
-export([start/0]).

newStick() -> spawn(fun() -> available() end).

available() ->
  receive
    {take,P} -> P!took,
                unavailable();
    put -> available();
    {lookup,P}  -> P!available
  end.

unavailable() ->
  receive
    put         -> available();
    {lookup,P}  -> P!unavailable
  end.

take(S) -> S!{take,self()},
           receive
             took -> ok
           end.

put(S) -> S!put.

phil(N,SL,SR) ->
  base:printLn(base:show(N)++": Thinking"),
  take(SL),
  SR!{lookup,self()},
   receive
     available    -> take(SR),
                     base:printLn(base:show(N)++": Eating"),
                     put(SL),
                     put(SR),
                     phil(N,SL,SR);
     unavailable  -> base:printLn(base:show(N)++": Put L"),
                     put(SL),
                     phil(N,SL,SR)
  end.

start() ->
  S1 = newStick(),
  S2 = newStick(),
  S3 = newStick(),
  S4 = newStick(),
  S5 = newStick(),
  spawn(fun() -> phil(1,S1,S2) end),
  spawn(fun() -> phil(2,S2,S3) end),
  spawn(fun() -> phil(3,S3,S4) end),
  spawn(fun() -> phil(4,S4,S5) end),
  phil(5,S5,S1).
