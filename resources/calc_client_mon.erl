-module(calc_client).
-author("Duncan Paul Attard").

-export([add/2, mul/2]).
-export([rpc/2]).

-spec add(A :: number(), B :: number()) -> number().
add(A, B) ->
    {add, Res} = rpc(calc_server, {add, A, B}),
    Res.

-spec mul(A :: number(), B :: number()) -> number().
mul(A, B) ->
    {mul, Res} = rpc(calc_server, {mul, A, B}),
    Res.

-spec rpc(To :: pid() | atom(), Req :: any()) -> any().
rpc(To, Req) ->
    begin
        (_Pid@0 = To) ! _Msg@0 = {self(), Req},
        case analyzer:filter(_Msg@0) of
            true ->
                analyzer:dispatch({send, self(), _Pid@0, _Msg@0});
            false ->
                _Msg@0
        end
    end,
    receive
        _Msg@1 = Resp ->
            case analyzer:filter(_Msg@1) of
                true ->
                    analyzer:dispatch({recv, self(), _Msg@1});
                false ->
                    ok
            end,
            Resp
    end.
