-module(echess_tests).

-include_lib("eunit/include/eunit.hrl").

show_piece_test() ->
    ?assertEqual($♔, echess:show_piece(echess:bK())).

ranks_test() ->
    Expected = [lists:seq(A, A+7) || A <- lists:seq(1, 64, 8)],
    Actual = echess:ranks(lists:seq(1, 64)),
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
    Actual = echess:show_game(echess:new()),
    ?assertEqual(Expected, Actual).

square_index_test() ->
    ?assertEqual(1, echess:square_index(a1)),
    ?assertEqual(13, echess:square_index(e2)),
    ?assertEqual(64, echess:square_index(h8)).

piece_at_test() ->
    Game = echess:new(),
    ?assertEqual(echess:wP(), echess:piece_at(Game, e2)),
    ?assertEqual(echess:wQ(), echess:piece_at(Game, d1)),
    ?assertEqual(echess:bK(), echess:piece_at(Game, e8)).

current_player_test() ->
    Game = echess:new(),
    ?assertEqual(white, echess:current_player(Game)).

valid_square_test() ->
    ?assert(echess:valid_square(a1)),
    ?assert(echess:valid_square(h8)),
    ?assertNot(echess:valid_square(foo)),
    ?assertNot(echess:valid_square(1)),
    ?assertNot(echess:valid_square(a99)),
    ?assertNot(echess:valid_square(i1)).

square_empty_test() ->
    Game = echess:new(),
    ?assertNot(echess:square_empty(Game, a1)),
    ?assert(echess:square_empty(Game, a3)).

friendly_occupied_test() ->
    Game = echess:new(),
    ?assert(echess:friendly_occupied(Game, a1)),
    ?assertNot(echess:friendly_occupied(Game, a3)),
    ?assertNot(echess:friendly_occupied(Game, h8)).

enemy_occupied_test() ->
    Game = echess:new(),
    ?assert(echess:enemy_occupied(Game, h8)),
    ?assertNot(echess:enemy_occupied(Game, a3)),
    ?assertNot(echess:enemy_occupied(Game, a1)).

is_valid_move_green_pawn_test() ->
    Game = echess:new(),
    ?assert(echess:is_valid_move_for_piece(Game, echess:wP(), e2, e4)),
    ?assert(echess:is_valid_move_for_piece(Game, echess:wP(), e2, e3)),
    ?assert(echess:is_valid_move_for_piece(Game, echess:bP(), h7, h6)),
    ?assert(echess:is_valid_move_for_piece(Game, echess:bP(), h7, h5)).

is_valid_move_moved_pawn_test() ->
    Game = echess:new(),
    WPiece = echess:piece(pawn, white, [{moved, true}]),
    ?assert(echess:is_valid_move_for_piece(Game, WPiece, e3, e4)),
    ?assertNot(echess:is_valid_move_for_piece(Game, WPiece, e3, e5)),
    BPiece = echess:piece(pawn, black, [{moved, true}]),
    ?assert(echess:is_valid_move_for_piece(Game, BPiece, h6, h5)),
    ?assertNot(echess:is_valid_move_for_piece(Game, BPiece, h6, h4)).

is_valid_move_pawn_capture_test() ->
    Game = echess:new(),
    Piece = echess:piece(pawn, white, [{moved, true}]),
    ?assert(echess:is_valid_move_for_piece(Game, Piece, b6, a7)),
    ?assert(echess:is_valid_move_for_piece(Game, Piece, b6, b7)),
    ?assertNot(echess:is_valid_move_for_piece(Game, Piece, f5, e6)).

is_legal_move_test() ->
    Game = echess:new(),
    % pawn
    ?assert(echess:is_legal_move(Game, echess:move(e2, e4))).
    % knight
    % ?assert(echess:is_legal_move(Game, echess:move(b1, c3))),
    % % pawn push too far
    % ?assertNot(echess:is_legal_move(Game, echess:move(e2, e5))),
    % % blocked piece
    % ?assertNot(echess:is_legal_move(Game, echess:move(d4, d6))).

fen_test() ->
    ExpectedGame1 = echess:new(),
    ActualGame1 = echess:fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"),
    ?assertEqual(ExpectedGame1, ActualGame1),
    Board = [
        empty, empty, empty, echess:wQ(), empty, echess:wR(), echess:wK(), empty,
        echess:wP(), empty, echess:wP(), empty, empty, echess:wP(), echess:wP(), echess:wP(),
        empty, empty, empty, echess:wP(), echess:wB(), echess:wN(), empty, empty,
        empty, empty, empty, empty, echess:wP(), empty, echess:bB(), empty,
        echess:bQ(), echess:wB(), echess:bP(), empty, empty, empty, empty, empty,
        empty, empty, echess:bN(), echess:bP(), empty, empty, empty, empty,
        echess:bP(), echess:wR(), empty, echess:bN(), echess:bP(), echess:bP(), echess:bP(), echess:bP(),
        echess:wN(), empty, empty, echess:bK(), empty, echess:bB(), empty, echess:bR()
    ],
    ExpectedGame2 = echess:game(Board),
    ActualGame2 = echess:fen("N2k1b1r/pR1npppp/2np4/qBp5/4P1b1/3PBN2/P1P2PPP/3Q1RK1 b - - 3 13"),
    ?assertEqual(ExpectedGame2, ActualGame2).
