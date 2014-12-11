-module(erlang_chess_game_tests).

-include_lib("eunit/include/eunit.hrl").

show_piece_test() ->
    ?assertEqual($♔, erlang_chess_game:show_piece(erlang_chess_game:bK())).

ranks_test() ->
    RowRanges = [{1, 8}, {9, 16}, {17, 24}, {25, 32},
                 {33, 40}, {41, 48}, {49, 56}, {57, 64}],
    Expected = [lists:seq(A, B) || {A, B} <- RowRanges],
    Actual = erlang_chess_game:ranks(lists:seq(1, 64)),
    ?assertEqual(Expected, Actual).

show_game_test() ->
    Expected = "♖♘♗♕♔♗♘♖\n" ++
               "♙♙♙♙♙♙♙♙\n" ++
               "        \n" ++
               "        \n" ++
               "        \n" ++
               "        \n" ++
               "♟♟♟♟♟♟♟♟\n" ++
               "♜♞♝♛♚♝♞♜",
    Actual = erlang_chess_game:show_game(erlang_chess_game:new()),
    ?assertEqual(Expected, Actual).

is_legal_move_test() ->
    Game = erlang_chess_game:new(),
    Move = erlang_chess_game:move(e2, e4),
    ?assert(erlang_chess_game:is_legal_move(Game, Move)).
