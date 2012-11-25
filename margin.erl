%% Create date: Sat May  8 16:08:51 BST 2010 -primus
%% erlang script to get margin for selected instruments

-module(margin).
-export([start/0, gen_list/0, parse_file/1]).
-import(string, [tokens/2, strip/1]).
-import(lists, [prefix/2, suffix/2, map/2, concat/1]).

-define(EXCHANGES, ["ECBOT", "GLOBEX", "IPE", "NYBOT", "NYMEX"]).
-define(TRADE, ["EUR", "E7", "CL", "QM", "ZN"]).
-define(FILE_PREFIX, "ib_margin-").
-define(FLATTEN(X), lists:flatten(io_lib:format("~2..0w", [X]))).
-define(CMD, "links -dump http://interactivebrokers.com/en/p.php?f=margin").
-define(OUTDIR, get_homedir() ++ "/margin/").

start() ->
  parse_file("margin.stm-09052010").

gen_list() ->
  Margin = os:cmd(?CMD),
  L = tokens(Margin, "\n"),
  [Yr,Mo,Dy] = map(fun(X) -> X end, tuple_to_list(date())),
  Data = map(fun(X) -> [strip(Y) || Y <- L, prefix(X, Y), suffix("USD", strip(Y))] end, ?EXCHANGES),
  %Date = ?FLATTEN(Dy) ++ ?FLATTEN(Mo) ++ Yr,
  File = lists:concat([?OUTDIR, ?FILE_PREFIX, ?FLATTEN(Dy), ?FLATTEN(Mo), Yr]),
  %File = concat([?FILE_PREFIX, Date]),
  case file:open(File, write) of
    {ok, F} ->
      lists:foreach(fun(X) -> io:format(F, "~p.~n", [X]) end, Data),
      file:close(F);
    Error ->
      Error
  end.

parse_file(File) ->
  case file:read_file(File) of
    {ok, B} ->
      L = [strip(X) || X <- tokens(binary_to_list(B), "\r\n")],
      map(fun(X) -> [strip(Y) || Y <- tokens(X, ";")] end, L);
    Error ->
      {File, Error}
  end.

get_homedir() ->
    os:getenv("HOME").

%% lists:map(fun(X) -> string:strip(X) end, string:tokens(binary_to_list(B), ";\r\n"))
%%lists:map(fun(X) -> string:strip(X) end, string:tokens(margin:parse_file("margin.stm-09052010"), ";")).


%% vim: set et ts=2 sw=2 ai invlist si cul nu:
