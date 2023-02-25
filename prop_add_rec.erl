-module(prop_add_rec).
-author("detectEr").
-generated("2023/ 2/23 18:38:40").
-export([mfa_spec/1]).
mfa_spec(_Mfa = {'Elixir.Demo.CalcServer', loop, [_]}) ->
    {ok,
     begin
         io:format([self(), _Mfa]),
         fun(_E =
                 {trace, _, spawned, _,
                  {'Elixir.Demo.CalcServer', loop, [_]}}) ->
                io:format([self(), _E]),
                fun X() ->
                        fun(_E = {trace, _, 'receive', {_, {add, A, B}}}) ->
                               io:format([self(), _E]),
                               fun(_E = {trace, _, send, {ok, Res}, _})
                                      when Res =/= A + B ->
                                      io:format([self(), _E]),
                                      begin
                                          io:format([self()]),
                                          no
                                      end;
                                  (_E = {trace, _, send, {ok, Res}, _})
                                      when Res =:= A + B ->
                                      io:format([self(), _E]),
                                      begin
                                          io:format([self(), 'X']),
                                          X()
                                      end;
                                  (_E) ->
                                      begin
                                          io:format([self(), _E]),
                                          'end'
                                      end
                               end;
                           (_E) ->
                               begin
                                   io:format([self(), _E]),
                                   'end'
                               end
                        end
                end();
            (_E) ->
                begin
                    io:format([self(), _E]),
                    'end'
                end
         end
     end};
mfa_spec(_Mfa = {'Elixir.Demo.CalcServerBug', loop, [_]}) ->
    {ok,
     begin
         io:format([self(), _Mfa]),
         fun(_E =
                 {trace, _, spawned, _,
                  {'Elixir.Demo.CalcServerBug', loop, [_]}}) ->
                io:format([self(), _E]),
                fun X() ->
                        fun(_E = {trace, _, 'receive', {_, {add, A, B}}}) ->
                               io:format([self(), _E]),
                               fun(_E = {trace, _, send, {ok, Res}, _})
                                      when Res =/= A + B ->
                                      io:format([self(), _E]),
                                      begin
                                          io:format([self()]),
                                          no
                                      end;
                                  (_E = {trace, _, send, {ok, Res}, _})
                                      when Res =:= A + B ->
                                      io:format([self(), _E]),
                                      begin
                                          io:format([self(), 'X']),
                                          X()
                                      end;
                                  (_E) ->
                                      begin
                                          io:format([self(), _E]),
                                          'end'
                                      end
                               end;
                           (_E) ->
                               begin
                                   io:format([self(), _E]),
                                   'end'
                               end
                        end
                end();
            (_E) ->
                begin
                    io:format([self(), _E]),
                    'end'
                end
         end
     end};
mfa_spec(_Mfa) ->
    io:format([self(), _Mfa]),
    undefined.
