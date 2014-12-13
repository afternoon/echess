-module(erlang_chess_tests).

-include_lib("eunit/include/eunit.hrl").

show_piece_test() ->
    ?assertEqual($♔, erlang_chess:show_piece(erlang_chess:bK())).

ranks_test() ->
    Expected = [lists:seq(A, A+7) || A <- lists:seq(1, 64, 8)],
    Actual = erlang_chess:ranks(lists:seq(1, 64)),
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
    Actual = erlang_chess:show_game(erlang_chess:new()),
    ?assertEqual(Expected, Actual).

square_index_test() ->
    ?assertEqual(1, erlang_chess:square_index(a1)),
    ?assertEqual(13, erlang_chess:square_index(e2)),
    ?assertEqual(64, erlang_chess:square_index(h8)).

piece_at_test() ->
    Game = erlang_chess:new(),
    ?assertEqual(erlang_chess:wP(), erlang_chess:piece_at(Game, e2)),
    ?assertEqual(erlang_chess:wQ(), erlang_chess:piece_at(Game, d1)),
    ?assertEqual(erlang_chess:bK(), erlang_chess:piece_at(Game, e8)).

current_player_test() ->
    Game = erlang_chess:new(),
    ?assertEqual(white, erlang_chess:current_player(Game)).

valid_square_test() ->
    ?assert(erlang_chess:valid_square(a1)),
    ?assert(erlang_chess:valid_square(h8)),
    ?assertNot(erlang_chess:valid_square(foo)),
    ?assertNot(erlang_chess:valid_square(1)),
    ?assertNot(erlang_chess:valid_square(a99)),
    ?assertNot(erlang_chess:valid_square(i1)).

square_empty_test() ->
    Game = erlang_chess:new(),
    ?assertNot(erlang_chess:square_empty(Game, a1)),
    ?assert(erlang_chess:square_empty(Game, a3)).

friendly_occupied_test() ->
    Game = erlang_chess:new(),
    ?assert(erlang_chess:friendly_occupied(Game, a1)),
    ?assertNot(erlang_chess:friendly_occupied(Game, a3)),
    ?assertNot(erlang_chess:friendly_occupied(Game, h8)).

enemy_occupied_test() ->
    Game = erlang_chess:new(),
    ?assert(erlang_chess:enemy_occupied(Game, h8)),
    ?assertNot(erlang_chess:enemy_occupied(Game, a3)),
    ?assertNot(erlang_chess:enemy_occupied(Game, a1)).

is_valid_move_green_pawn_test() ->
    Game = erlang_chess:new(),
    ?assert(erlang_chess:is_valid_move_for_piece(Game, erlang_chess:wP(), e2, e4)),
    ?assert(erlang_chess:is_valid_move_for_piece(Game, erlang_chess:wP(), e2, e3)),
    ?assert(erlang_chess:is_valid_move_for_piece(Game, erlang_chess:bP(), h7, h6)),
    ?assert(erlang_chess:is_valid_move_for_piece(Game, erlang_chess:bP(), h7, h5)).

is_valid_move_moved_pawn_test() ->
    Game = erlang_chess:new(),
    WPiece = erlang_chess:piece(pawn, white, [{moved, true}]),
    ?assert(erlang_chess:is_valid_move_for_piece(Game, WPiece, e3, e4)),
    ?assertNot(erlang_chess:is_valid_move_for_piece(Game, WPiece, e3, e5)),
    BPiece = erlang_chess:piece(pawn, black, [{moved, true}]),
    ?assert(erlang_chess:is_valid_move_for_piece(Game, BPiece, h6, h5)),
    ?assertNot(erlang_chess:is_valid_move_for_piece(Game, BPiece, h6, h4)).

is_valid_move_pawn_capture_test() ->
    Game = erlang_chess:new(),
    Piece = erlang_chess:piece(pawn, white, [{moved, true}]),
    ?assert(erlang_chess:is_valid_move_for_piece(Game, Piece, b6, a7)),
    ?assert(erlang_chess:is_valid_move_for_piece(Game, Piece, b6, b7)),
    ?assertNot(erlang_chess:is_valid_move_for_piece(Game, Piece, f5, e6)).

is_legal_move_test() ->
    Game = erlang_chess:new(),
    % pawn
    ?assert(erlang_chess:is_legal_move(Game, erlang_chess:move(e2, e4))).
    % knight
    % ?assert(erlang_chess:is_legal_move(Game, erlang_chess:move(b1, c3))),
    % % pawn push too far
    % ?assertNot(erlang_chess:is_legal_move(Game, erlang_chess:move(e2, e5))),
    % % blocked piece
    % ?assertNot(erlang_chess:is_legal_move(Game, erlang_chess:move(d4, d6))).

fen_test() ->
    Board = [
        empty, empty, empty, erlang_chess:wQ(), empty, erlang_chess:wR(), erlang_chess:wK(), empty,
        erlang_chess:wP(), empty, erlang_chess:wP(), empty, empty, erlang_chess:wP(), erlang_chess:wP(), erlang_chess:wP(),
        empty, empty, empty, erlang_chess:wP(), erlang_chess:wB(), erlang_chess:wN(), empty, empty,
        empty, empty, empty, empty, erlang_chess:wP(), empty, erlang_chess:bB(), empty,
        erlang_chess:bQ(), erlang_chess:wB(), erlang_chess:bP(), empty, empty, empty, empty, empty,
        empty, empty, erlang_chess:bN(), erlang_chess:bP(), empty, empty, empty, empty,
        erlang_chess:bP(), erlang_chess:wR(), empty, erlang_chess:bN(), erlang_chess:bP(), erlang_chess:bP(), erlang_chess:bP(), erlang_chess:bP(),
        erlang_chess:wN(), empty, empty, erlang_chess:bK(), empty, erlang_chess:bB(), empty, erlang_chess:bR()
    ],
    ExpectedGame = erlang_chess:game(Board),
    ActualGame = erlang_chess:fen("N2k1b1r/pR1npppp/2np4/qBp5/4P1b1/3PBN2/P1P2PPP/3Q1RK1 b - - 3 13"),
    ?assertEqual(ExpectedGame, ActualGame).
