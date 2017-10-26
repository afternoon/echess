-module(echess_tests).

-include_lib("eunit/include/eunit.hrl").

-define(assert_legal_move(Game, From, To), ?assert(echess:is_legal_move(Game, echess:move(From, To)))).
-define(assert_not_legal_move(Game, From, To), ?assertNot(echess:is_legal_move(Game, echess:move(From, To)))).

show_piece_test() ->
    ?assertEqual($♔, echess:show_piece(echess:bk())).

board_ranks_test() ->
    Expected = [lists:seq(A, A+7) || A <- lists:seq(1, 64, 8)],
    Actual = echess:board_ranks(lists:seq(1, 64)),
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
    ?assertEqual(echess:wp(), echess:piece_at(Game, e2)),
    ?assertEqual(echess:wq(), echess:piece_at(Game, d1)),
    ?assertEqual(echess:bk(), echess:piece_at(Game, e8)).

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

is_ne_diagonal_test() ->
    ?assert(echess:is_ne_diagonal(a1, b2)),
    ?assertNot(echess:is_ne_diagonal(b2, a1)).

fen_starting_position_test() ->
    ExpectedBoard = echess:starting_position(),
    Game = echess:fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"),
    ?assertEqual(ExpectedBoard, echess:game_board(Game)).

fen_empty_test() ->
    ExpectedBoard = [empty || _ <- lists:seq(1, 64)],
    Game = echess:fen("8/8/8/8/8/8/8/8"),
    ?assertEqual(ExpectedBoard, echess:game_board(Game)).

fen_beppel_game_test() ->
    ExpectedBoard = [
        empty,       empty,       empty,       echess:wq(), empty,       echess:wr(), echess:wk(), empty,
        echess:wp(), empty,       echess:wp(), empty,       empty,       echess:wp(), echess:wp(), echess:wp(),
        empty,       empty,       empty,       echess:wp(), echess:wb(), echess:wn(), empty,       empty,
        empty,       empty,       empty,       empty,       echess:wp(), empty,       echess:bb(), empty,
        echess:bq(), echess:wb(), echess:bp(), empty,       empty,       empty,       empty,       empty,
        empty,       empty,       echess:bn(), echess:bp(), empty,       empty,       empty,       empty,
        echess:bp(), echess:wr(), empty,       echess:bn(), echess:bp(), echess:bp(), echess:bp(), echess:bp(),
        echess:wn(), empty,       empty,       echess:bk(), empty,       echess:bb(), empty,       echess:br()
    ],
    Game = echess:fen("N2k1b1r/pR1npppp/2np4/qBp5/4P1b1/3PBN2/P1P2PPP/3Q1RK1 b - - 3 13"),
    ?assertEqual(ExpectedBoard, echess:game_board(Game)).

fen_current_player_test() ->
    WhiteGame = echess:fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"),
    ?assertEqual(white, echess:game_current_player(WhiteGame)),
    BlackGame = echess:fen("N2k1b1r/pR1npppp/2np4/qBp5/4P1b1/3PBN2/P1P2PPP/3Q1RK1 b - - 3 13"),
    ?assertEqual(black, echess:game_current_player(BlackGame)).

pawn_should_push_one_or_two_spaces_test() ->
    Game = echess:new(),
    % pawn can push
    ?assert_legal_move(Game, e2, e3),
    % pawn can double push
    ?assert_legal_move(Game, e2, e4),
    % pawn can't move 3 squares
    ?assert_not_legal_move(Game, e2, e5).

moved_pawn_should_not_be_able_to_double_push_test() ->
    Game = echess:fen("rnbqkbnr/pppppppp/8/8/8/4P3/PPPP1PPP/RNBQKBNR"),
    ?assert_legal_move(Game, e3, e4),
    ?assert_not_legal_move(Game, e3, e5).

pawn_should_be_able_to_take_test() ->
    WhiteGame = echess:fen("rnbqkbnr/ppp1pppp/8/3p4/4P3/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 2"),
    ?assert_legal_move(WhiteGame, e4, d5),
    BlackGame = echess:fen("rnbqkbnr/ppp1pppp/8/3p4/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 2"),
    ?assert_legal_move(BlackGame, d5, e4).

pawn_should_not_be_able_to_move_diagonally_unless_taking_test() ->
    ?assert_not_legal_move(echess:new(), d2, e3).

pawn_should_not_be_able_to_double_push_if_blocked_test() ->
    Game = echess:fen("rnbqkbnr/ppp1pppp/8/3p4/8/N7/PPPPPPPP/R1BQKBNR w KQkq d6 0 2"),
    ?assert_not_legal_move(Game, a2, a4).

rook_should_be_able_to_move_laterally_test() ->
    Game = echess:fen("8/8/8/3R4/4r3/8/8/8"),
    ?assert_legal_move(Game, d5, d8),
    ?assert_legal_move(Game, d5, d1),
    ?assert_legal_move(Game, d5, a5),
    ?assert_legal_move(Game, d5, h5),
    BlackGame = echess:fen("8/8/8/3R4/4r3/8/8/8 b KQkq -"),
    ?assert_legal_move(BlackGame, e4, e8),
    HorizGame = echess:fen("R6r/8/8/8/8/8/8/8"),
    ?assert_legal_move(HorizGame, a8, h8).

rook_should_not_be_able_to_move_diagonally_test() ->
    Game = echess:fen("8/8/8/3R4/4r3/8/8/8"),
    ?assert_not_legal_move(Game, d5, g8),
    ?assert_not_legal_move(Game, e4, d5).

rook_should_not_be_able_to_move_in_knight_pattern_test() ->
    Game = echess:fen("8/8/8/3R4/4r3/8/8/8"),
    ?assert_not_legal_move(Game, d5, f7).

rook_should_not_be_able_to_move_if_blocked_test() ->
    VertBlockGame = echess:new(),
    ?assert_not_legal_move(VertBlockGame, a1, a3),
    HorizBlockGame = echess:fen("R2R3r/8/8/8/8/8/8/8"),
    ?assert_not_legal_move(HorizBlockGame, a8, h8).

bishop_should_be_able_to_move_diagonally_test() ->
    Game = echess:fen("8/8/8/8/3B4/8/5b2/8"),
    ?assert_legal_move(Game, d4, a1),
    ?assert_legal_move(Game, d4, a7),
    ?assert_legal_move(Game, d4, h8),
    ?assert_legal_move(Game, d4, e3).

bishop_should_not_be_able_to_move_if_blocked_test() ->
    Game = echess:fen("8/8/8/8/3B4/8/5b2/8"),
    ?assert_not_legal_move(Game, d4, g1).

queen_should_be_able_to_move_laterally_test() ->
    Game = echess:fen("8/8/5q2/8/8/3Q4/8/8 w - -"),
    ?assert_legal_move(Game, d3, d8),
    ?assert_legal_move(Game, d3, d1),
    ?assert_legal_move(Game, d3, a3),
    ?assert_legal_move(Game, d3, h3).

queen_should_be_able_to_move_diagonally_test() ->
    Game = echess:fen("8/8/5q2/8/8/3Q4/8/8 w - -"),
    ?assert_legal_move(Game, d3, h7),
    ?assert_legal_move(Game, d3, f1),
    ?assert_legal_move(Game, d3, b1),
    ?assert_legal_move(Game, d3, a6).

queen_cant_just_do_what_the_fuck_she_wants_test() ->
    Game = echess:fen("8/8/5q2/8/8/3Q4/8/8 w - -"),
    ?assertNot(echess:is_unblocked_ne_diagonal(Game, d3, h6)),
    ?assertNot(echess:is_unblocked_se_diagonal(Game, d3, h6)),
    ?assertNot(echess:is_unblocked_nw_diagonal(Game, d3, h6)),
    ?assertNot(echess:is_unblocked_sw_diagonal(Game, d3, h6)),
    ?assert_not_legal_move(Game, d3, h6),
    ?assert_not_legal_move(Game, d3, h5),
    ?assert_not_legal_move(Game, d3, h4),
    ?assert_not_legal_move(Game, d3, a8),
    ?assert_not_legal_move(Game, d3, f6).

queen_should_not_be_able_to_move_if_blocked_test() ->
    Game = echess:fen("8/8/5q2/8/4K3/3Q4/8/8 w - -"),
    ?assert_not_legal_move(Game, d3, h7),
    ?assert_not_legal_move(Game, d3, e4).

%% TODO
%% - king
%% - knight
%% - castling
%% - in check
%% - pawn can take en passant - relies on previous move!
