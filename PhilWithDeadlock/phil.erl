-module(phil).
-export([start/0]).

newStick() -> spawn(fun() -> available() end).

available() ->
  receive
    {take,P} -> P!took,
                unavailable();
    put -> available()
  end.

unavailable() ->
  receive
    put -> available()
  end.

take(S) -> S!{take,self()},
           receive
             took -> ok
           end.

put(S) -> S!put.

phil(N,SL,SR) ->
  base:printLn(base:show(N)++": Thinking"),
  take(SL),
  take(SR),
  base:printLn(base:show(N)++": Eating"),
  put(SL),
  put(SR),
  phil(N,SL,SR).

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
  base:getLn(),
  phil(5,S5,S1).
