-module(stick).
-export([start_stick/0,start_phil/3,append/2,programm/0]).
-import(base,[print/1,printLn/1,getLn/0,getLn/1,show/1]).

start_stick() -> spawn(fun() -> stick_server(true, nothing) end).

start_phil(Name, St_L, St_R) -> spawn(fun() -> phil_left(Name, St_L, St_R) end).

phil_left(Name, St_L, St_R) ->
  printLn("Philisoph: " ++ Name ++ " will take Left"),
  St_L!{take, self()},
    receive
      {took} -> printLn("Philisoph: " ++ Name ++ " took Left"),
                phil_right(Name, St_L, St_R)
    end.

phil_right(Name, St_L, St_R) ->
  printLn("Philisoph: " ++ Name ++ " will take Right"),
  St_R!{take, self()},
    receive
      {took} -> printLn("Philisoph: " ++ Name ++ " took Right"),
                phil_release(Name, St_L, St_R)
    end.

phil_release(Name, St_L, St_R) ->
  printLn("Philisoph: " ++ Name ++ " released sticks."),
  St_L!{release},
  St_R!{release},
  phil_left(Name, St_L, St_R).

stick_take(Phil) ->
  Phil!{took},
  stick_server(false, nothing).

update_server(Available, Waiting) ->
  case Available of
    true -> stick_take(Waiting);
    _     -> stick_server(false, Waiting)
  end.

stick_server(Available, Phil) ->
  receive
    {take,Next} ->
      case Available of
        true  -> stick_take(Next);
        _     -> stick_server(false, Next)
      end;
    {release} ->
      case Phil of
        nothing  -> stick_server(true, nothing);
        _     -> stick_take(Phil)
      end
  end.


programm() -> Stick1 = start_stick(),
              Stick2 = start_stick(),
              Stick3 = start_stick(),
              Stick4 = start_stick(),
              Stick5 = start_stick(),
              Phil1 = start_phil("Phil1", Stick1, Stick2),
              Phil2 = start_phil("Phil2", Stick2, Stick3),
              Phil3 = start_phil("Phil3", Stick3, Stick4),
              Phil4 = start_phil("Phil4", Stick4, Stick5),
              Phil5 = start_phil("Phil5", Stick5, Stick1).

lookup([],        _) -> nothing;
lookup([{K,V}|_], K) -> {just,V};
lookup([_|KVs],   K) -> lookup(KVs,K).

append([],Ys) -> Ys;
append([X|Xs],Ys) -> [X|append(Xs,Ys)].

first([]) -> nothing;
first([X|_]) -> X.

rest([]) -> nothing;
rest([_|X]) -> X.
