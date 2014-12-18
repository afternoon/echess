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
    ?assertEqual(white, echess:game_current_player(Game)).

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

fen_starting_position_test() ->
    ExpectedBoard = echess:starting_position(),
    Game = echess:fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"),
    ?assertEqual(ExpectedBoard, echess:game_board(Game)).

fen_beppel_game_test() ->
    ExpectedBoard = [
        empty, empty, empty, echess:wQ(), empty, echess:wR(), echess:wK(), empty,
        echess:wP(), empty, echess:wP(), empty, empty, echess:wP(), echess:wP(), echess:wP(),
        empty, empty, empty, echess:wP(), echess:wB(), echess:wN(), empty, empty,
        empty, empty, empty, empty, echess:wP(), empty, echess:bB(), empty,
        echess:bQ(), echess:wB(), echess:bP(), empty, empty, empty, empty, empty,
        empty, empty, echess:bN(), echess:bP(), empty, empty, empty, empty,
        echess:bP(), echess:wR(), empty, echess:bN(), echess:bP(), echess:bP(), echess:bP(), echess:bP(),
        echess:wN(), empty, empty, echess:bK(), empty, echess:bB(), empty, echess:bR()
    ],
    Game = echess:fen("N2k1b1r/pR1npppp/2np4/qBp5/4P1b1/3PBN2/P1P2PPP/3Q1RK1 b - - 3 13"),
    ?assertEqual(ExpectedBoard, echess:game_board(Game)).

fen_current_player_test() ->
    WhiteGame = echess:fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"),
    ?assertEqual(white, echess:game_current_player(WhiteGame)),
    BlackGame = echess:fen("N2k1b1r/pR1npppp/2np4/qBp5/4P1b1/3PBN2/P1P2PPP/3Q1RK1 b - - 3 13"),
    ?assertEqual(black, echess:game_current_player(BlackGame)).

pawn_should_push_one_or_two_spaces_test() ->
    Game = echess:new(),
    % pawn can push
    ?assert(echess:is_legal_move(Game, echess:move(e2, e3))),
    % pawn can double push
    ?assert(echess:is_legal_move(Game, echess:move(e2, e4))),
    % pawn can't move 3 squares
    ?assertNot(echess:is_legal_move(Game, echess:move(e2, e5))).

moved_pawn_should_not_be_able_to_double_push_test() ->
    Game = echess:fen("rnbqkbnr/pppppppp/8/8/8/4P3/PPPP1PPP/RNBQKBNR w KQkq - 0 1"),
    ?assert(echess:is_legal_move(Game, echess:move(e3, e4))),
    ?assertNot(echess:is_legal_move(Game, echess:move(e3, e5))).

pawn_should_be_able_to_take_test() ->
    WhiteGame = echess:fen("rnbqkbnr/ppp1pppp/8/3p4/4P3/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 2"),
    ?assert(echess:is_legal_move(WhiteGame, echess:move(e4, d5))),
    BlackGame = echess:fen("rnbqkbnr/ppp1pppp/8/3p4/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 2"),
    ?assert(echess:is_legal_move(BlackGame, echess:move(d5, e4))).

%% TODO
%% - pawn can't move diagonally unless taking
%% - pawn can take en passant - relies on previous move!
%% - knight
%% - bishop
%% - rook
%% - queen
%% - king
%% - do any pieces block the move?
