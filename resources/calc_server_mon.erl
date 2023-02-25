-module(calc_server).
-author("Duncan Paul Attard").

-file("/usr/lib/erlang/lib/stdlib-3.17/include/assert.hrl", 1).
-file("src/demo/calc_server.erl", 27).

-export([start/1]).
-export([loop/1]).

-spec start(N :: integer()) -> pid().
start(N) ->
    begin
        _Pid@0 =
            case prop_add_rec:mfa_spec({_Mod@0 = calc_server, _Fun@0 = loop, _Args@0 = [N]}) of
                undefined ->
                    spawn(_Mod@0, _Fun@0, _Args@0);
                {ok, _MonFun@0} ->
                    _PidParent@0 = self(),
                    spawn(fun() ->
                        put('$monitor', _MonFun@0),
                        analyzer:dispatch({init, self(), _PidParent@0, {_Mod@0, _Fun@0, _Args@0}}),
                        apply(_Mod@0, _Fun@0, _Args@0)
                    end)
            end,
        analyzer:dispatch({fork, self(), _Pid@0, {_Mod@0, _Fun@0, _Args@0}}),
        _Pid@0
    end.

-spec loop(Tot :: integer()) -> no_return().
loop(Tot) ->
    receive
        _Msg@2 = {Clt, {add, A, B}} ->
            case analyzer:filter(_Msg@2) of
                true ->
                    analyzer:dispatch({recv, self(), _Msg@2});
                false ->
                    ok
            end,
            begin
                (_Pid@1 = Clt) ! _Msg@1 = {ok, A + B},
                case analyzer:filter(_Msg@1) of
                    true ->
                        analyzer:dispatch({send, self(), _Pid@1, _Msg@1});
                    false ->
                        _Msg@1
                end
            end,
            loop(Tot + 1);
        _Msg@4 = {Clt, {mul, A, B}} ->
            case analyzer:filter(_Msg@4) of
                true ->
                    analyzer:dispatch({recv, self(), _Msg@4});
                false ->
                    ok
            end,
            begin
                (_Pid@3 = Clt) ! _Msg@3 = {ok, A * B},
                case analyzer:filter(_Msg@3) of
                    true ->
                        analyzer:dispatch({send, self(), _Pid@3, _Msg@3});
                    false ->
                        _Msg@3
                end
            end,
            loop(Tot + 1);
        _Msg@6 = {Clt, stp} ->
            case analyzer:filter(_Msg@6) of
                true ->
                    analyzer:dispatch({recv, self(), _Msg@6});
                false ->
                    ok
            end,
            begin
                (_Pid@5 = Clt) ! _Msg@5 = {bye, Tot},
                case analyzer:filter(_Msg@5) of
                    true ->
                        analyzer:dispatch({send, self(), _Pid@5, _Msg@5});
                    false ->
                        _Msg@5
                end
            end
    end.
