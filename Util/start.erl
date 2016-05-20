-module(start).
-export([fac/1, bla/1, len/1, append/2, lookup/2]).

fac(0) -> 1;
fac(N) when N>0 -> N * fac(Nm1).

bla({X,Y}) -> {hallo,Y,X};
bla(_) -> 42.

len([]) -> 0;
len([_|Xs]) -> 1+len(Xs).

append([],Ys) -> Ys;
append([X|Xs],Ys) -> [X|append(Xs,Ys)].

lookup([],        _) -> nothing;
lookup([{K,V}|_], K) -> {just,V};
lookup([_|KVs],   K) -> lookup(KVs,K).

