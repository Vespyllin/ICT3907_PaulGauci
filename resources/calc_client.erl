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
    To ! {self(), Req},
    receive
        Resp ->
            Resp
    end.
