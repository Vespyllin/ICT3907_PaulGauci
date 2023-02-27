-module(calc_server).
-author("Duncan Paul Attard").

-include_lib("stdlib/include/assert.hrl").

-export([start/1]).
-export([loop/1]).

-spec start(N :: integer()) -> pid().
start(N) ->
    spawn(?MODULE, loop, [N]).

-spec loop(Tot :: integer()) -> no_return().
loop(Tot) ->
    receive
        {Clt, {add, A, B}} ->
            Clt ! {ok, A + B},
            loop(Tot + 1);
        {Clt, {mul, A, B}} ->
            Clt ! {ok, A * B},
            loop(Tot + 1);
        {Clt, stp} ->
            Clt ! {bye, Tot}
    end.
