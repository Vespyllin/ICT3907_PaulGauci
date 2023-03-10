-module(prop_add_rec).
-author("detectEr").
-generated("2023/ 3/10 01:58:38").
-export([mfa_spec/1]).
mfa_spec(_Mfa = {'Elixir.Demo.CalcServer', loop, [_]}) ->
    {ok, begin
        io:format(
            "\e[1m\e[33m*** [~w] Instrumenting monitor for MFA p"
            "attern '~p'.~n\e[0m",
            [self(), _Mfa]
        ),
        fun
            (_E = {trace, _, spawned, _, {'Elixir.Demo.CalcServer', loop, [_]}}) ->
                io:format(
                    "\e[37m*** [~w] Analyzing event ~p.~n\e[0m",
                    [self(), _E]
                ),
                fun X() ->
                    fun
                        (_E = {trace, _, 'receive', {_, {add, A, B}}}) ->
                            io:format(
                                "\e[37m*** [~w] Analyzing even"
                                "t ~p.~n\e[0m",
                                [self(), _E]
                            ),
                            fun
                                (_E = {trace, _, send, {ok, Res}, _}) when Res =/= A + B ->
                                    io:format("\e[37m*** [~w] Analyzing event ~p.~n\e[0m", [
                                        self(), _E
                                    ]),
                                    begin
                                        io:format(
                                            "\e[1m\e[31m*** [~w] 3 Reached verdict 'no'.~n\e[0m",
                                            [self()]
                                        ),
                                        no
                                    end;
                                (_E = {trace, _, send, {ok, Res}, _}) when
                                    Res =:= A + B
                                ->
                                    io:format(
                                        "\e[37m*** [~w] Analyzi"
                                        "ng event ~p.~n\e[0m",
                                        [self(), _E]
                                    ),
                                    begin
                                        io:format(
                                            "\e[36m*** [~w] Unf"
                                            "olding rec. var. ~"
                                            "p.~n\e[0m",
                                            [self(), 'X']
                                        ),
                                        X()
                                    end;
                                (_E) ->
                                    begin
                                        io:format(
                                            "\e[1m\e[33m*** [~w] THIS: Reached verdict 'end' on event ~p.~n\e[0m",
                                            [self(), _E]
                                        ),
                                        'end'
                                    end
                            end;
                        (_E) ->
                            begin
                                io:format(
                                    "\e[1m\e[33m*** [~w] Reach"
                                    "ed verdict 'end' on event"
                                    " ~p.~n\e[0m",
                                    [self(), _E]
                                ),
                                'end'
                            end
                    end
                end();
            (_E) ->
                begin
                    io:format(
                        "\e[1m\e[33m*** [~w] 2 Reached verdict 'end"
                        "' on event ~p.~n\e[0m",
                        [self(), _E]
                    ),
                    'end'
                end
        end
    end};
mfa_spec(_Mfa = {'Elixir.Demo.CalcServerBug', loop, [_]}) ->
    {ok, begin
        io:format(
            "\e[1m\e[33m*** [~w] Instrumenting monitor for MFA p"
            "attern '~p'.~n\e[0m",
            [self(), _Mfa]
        ),
        fun
            (
                _E =
                    {trace, _, spawned, _, {'Elixir.Demo.CalcServerBug', loop, [_]}}
            ) ->
                io:format(
                    "\e[37m*** [~w] Analyzing event ~p.~n\e[0m",
                    [self(), _E]
                ),
                fun X() ->
                    fun
                        (_E = {trace, _, 'receive', {_, {add, A, B}}}) ->
                            io:format(
                                "\e[37m*** [~w] Analyzing even"
                                "t ~p.~n\e[0m",
                                [self(), _E]
                            ),
                            fun
                                (_E = {trace, _, send, {ok, Res}, _}) when
                                    Res =/= A + B
                                ->
                                    io:format(
                                        "\e[37m*** [~w] Analyzi"
                                        "ng event ~p.~n\e[0m",
                                        [self(), _E]
                                    ),
                                    begin
                                        io:format(
                                            "\e[1m\e[31m*** [~w"
                                            "] Reached verdict "
                                            "'no'.~n\e[0m",
                                            [self()]
                                        ),
                                        no
                                    end;
                                (_E = {trace, _, send, {ok, Res}, _}) when
                                    Res =:= A + B
                                ->
                                    io:format(
                                        "\e[37m*** [~w] Analyzi"
                                        "ng event ~p.~n\e[0m",
                                        [self(), _E]
                                    ),
                                    begin
                                        io:format(
                                            "\e[36m*** [~w] Unf"
                                            "olding rec. var. ~"
                                            "p.~n\e[0m",
                                            [self(), 'X']
                                        ),
                                        X()
                                    end;
                                (_E) ->
                                    begin
                                        io:format(
                                            "\e[1m\e[33m*** [~w"
                                            "] Reached verdict "
                                            "'end' on event ~p."
                                            "~n\e[0m",
                                            [self(), _E]
                                        ),
                                        'end'
                                    end
                            end;
                        (_E) ->
                            begin
                                io:format(
                                    "\e[1m\e[33m*** [~w] Reach"
                                    "ed verdict 'end' on event"
                                    " ~p.~n\e[0m",
                                    [self(), _E]
                                ),
                                'end'
                            end
                    end
                end();
            (_E) ->
                begin
                    io:format(
                        "\e[1m\e[33m*** [~w] 4 Reached verdict 'end"
                        "' on event ~p.~n\e[0m",
                        [self(), _E]
                    ),
                    'end'
                end
        end
    end};
mfa_spec(_Mfa) ->
    io:format(
        "\e[1m\e[31m*** [~w] Skipping instrumentation for MFA pat"
        "tern '~p'.~n\e[0m",
        [self(), _Mfa]
    ),
    undefined.
