-module(echess).

% TODO reduce exports to minimal interface
-compile(export_all).

-define(SQUARES, [a1, b1, c1, d1, e1, f1, g1, h1,
                  a2, b2, c2, d2, e2, f2, g2, h2,
                  a3, b3, c3, d3, e3, f3, g3, h3,
                  a4, b4, c4, d4, e4, f4, g4, h4,
                  a5, b5, c5, d5, e5, f5, g5, h5,
                  a6, b6, c6, d6, e6, f6, g6, h6,
                  a7, b7, c7, d7, e7, f7, g7, h7,
                  a8, b8, c8, d8, e8, f8, g8, h8]).

-define(HORIZ_SLOPE, 1).
-define(VERT_SLOPE, 8).
-define(NE_DIAG_SLOPE, 9).
-define(SE_DIAG_SLOPE, -7).
-define(SW_DIAG_SLOPE, -9).
-define(NW_DIAG_SLOPE, 7).

%% @doc File names.
-type file() :: a | b | c | d | e | f | g | h.

%% @doc Square names (from coordinate/algebraic notations).
-type square() :: a8 | b8 | c8 | d8 | e8 | f8 | g8 | h8 |
                  a7 | b7 | c7 | d7 | e7 | f7 | g7 | h7 |
                  a6 | b6 | c6 | d6 | e6 | f6 | g6 | h6 |
                  a5 | b5 | c5 | d5 | e5 | f5 | g5 | h5 |
                  a4 | b4 | c4 | d4 | e4 | f4 | g4 | h4 |
                  a3 | b3 | c3 | d3 | e3 | f3 | g3 | h3 |
                  a2 | b2 | c2 | d2 | e2 | f2 | g2 | h2 |
                  a1 | b1 | c1 | d1 | e1 | f1 | g1 | h1.

%% @doc Classes of piece. In chess, "piece" seems to refer to both the piece
%% type and an individual piece on the board.
-type piece_class() :: king | queen | rook | bishop | knight | pawn.

%% @doc Piece/player colours.
-type colour() :: white | black.

%% @doc Piece is a tuple of the piece class and colour.
-type piece() :: {piece, piece_class(), colour()} | empty.

%% @doc Moves are implemented using the coordinate system split into a tuple of
%% from and to squares.
-type move() :: {move, From :: square(), To :: square()}.
-type moves() :: [move()].

%% @doc Represent which castling options are available for the current game.
-record(castling, {white_kingside=true :: boolean(),
                   white_queenside=true :: boolean(),
                   black_kingside=true :: boolean(),
                   black_queenside=true :: boolean()}).

-type castling() :: #castling{}.

%% @doc A board is a list of 64 pieces (empty is a pseudo-piece representing no
%% piece). The first square in the list (a1) is the bottom left of the board as
%% viewed by white.
-type board() :: [piece()].

%% @doc Game follows the data model of FEN, consisting of a board, metadata
%% about castling, en passant target square, half move clock for detecting
%% repeated moves and a full move number. We also store a list of moves.
-record(game, {board=[] :: board(),
               current_player=white :: colour(),
               castling=#castling{} :: castling(),
               en_passant_square :: square(),
               half_move_clock :: non_neg_integer(),
               full_move_number :: pos_integer(),
               moves=[] :: moves()}).

-type game() :: #game{}.

%%
%% Constructors
%%

%% @doc Create a brand new game in the starting position.
-spec new() -> game().
new() -> game(starting_position()).

%% @doc Create a game with the specified board.
-spec game(board()) -> game().
game(Board) ->
    #game{board=Board}.

%% @doc Create a game with the specified board and options.
-spec game(board(), colour(), castling(), square(), non_neg_integer(),
           pos_integer()) -> game().
game(Board, CurrentPlayer, Castling, EnPassantSquare, HalfMoveClock,
     FullMoveNumber) ->
    game(Board, CurrentPlayer, Castling, EnPassantSquare, HalfMoveClock,
         FullMoveNumber, []).

%% @doc Create a game with the specified board, options .
-spec game(board(), colour(), castling(), square(), non_neg_integer(),
           pos_integer(), moves()) -> game().
game(Board, CurrentPlayer, Castling, EnPassantSquare, HalfMoveClock,
     FullMoveNumber, Moves) ->
    #game{board=Board,
          current_player=CurrentPlayer,
          castling=Castling,
          en_passant_square=EnPassantSquare,
          half_move_clock=HalfMoveClock,
          full_move_number=FullMoveNumber,
          moves=Moves}.

%% @doc Create a board in the standard starting position.
%% N.B. board coordinates start at the bottom left.
-spec starting_position() -> board().
starting_position() ->
    [wR(),  wN(),  wB(),  wQ(),  wK(),  wB(),  wN(),  wR(),
     wP(),  wP(),  wP(),  wP(),  wP(),  wP(),  wP(),  wP(),
     empty, empty, empty, empty, empty, empty, empty, empty,
     empty, empty, empty, empty, empty, empty, empty, empty,
     empty, empty, empty, empty, empty, empty, empty, empty,
     empty, empty, empty, empty, empty, empty, empty, empty,
     bP(),  bP(),  bP(),  bP(),  bP(),  bP(),  bP(),  bP(),
     bR(),  bN(),  bB(),  bQ(),  bK(),  bB(),  bN(),  bR()].

wP() -> piece(pawn, white).
wN() -> piece(knight, white).
wB() -> piece(bishop, white).
wR() -> piece(rook, white).
wQ() -> piece(queen, white).
wK() -> piece(king, white).
bP() -> piece(pawn, black).
bN() -> piece(knight, black).
bB() -> piece(bishop, black).
bR() -> piece(rook, black).
bQ() -> piece(queen, black).
bK() -> piece(king, black).

%% @doc Piece constructor.
-spec piece(piece_class(), colour()) -> piece().
piece(Class, Colour) -> {piece, Class, Colour}.

%% @doc Move constructor.
-spec move(_From, _To) -> move().
move(From, To) ->
    case (From =/= To) andalso valid_square(From) andalso valid_square(To) of
        true -> {move, From, To};
        false -> badarg
    end.

%%
%% Game accessors
%%

-spec game_current_player(game()) -> colour().
game_current_player(#game{current_player=CurrentPlayer}) ->
    CurrentPlayer.

-spec game_board(game()) -> board().
game_board(#game{board=Board}) ->
    Board.

%%
%% Board operations
%%

board_ranks([A,B,C,D,E,F,G,H]) ->
    [[A,B,C,D,E,F,G,H]];
board_ranks([A,B,C,D,E,F,G,H|Tail]) ->
    [[A,B,C,D,E,F,G,H]|board_ranks(Tail)].

%% @doc Get the numerical index of a square.
-spec square_index(square()) -> pos_integer().
square_index(Square) ->
    SquareIndexMap = lists:zip(?SQUARES, lists:seq(1, 64)),
    proplists:get_value(Square, SquareIndexMap).

%% @doc Get the square name for a numerical square index.
-spec index_square(pos_integer()) -> square().
index_square(not_found) ->
    not_found;
index_square(Index) ->
    lists:nth(Index, ?SQUARES).

%% @doc Get the piece at a square.
-spec piece_at(game(), square()) -> piece().
piece_at(#game{board=Board}, Square) ->
    N = square_index(Square),
    lists:nth(N, Board).

piece_colour({piece, _, Colour}) ->
    Colour;
piece_colour(_) ->
    badarg.

piece_index(#game{board=Board}, Piece) ->
    piece_index(Board, Piece, 1).

piece_index([{piece, Class, Colour}|Tail], Piece, Index) ->
    case Piece of
        {piece, Class, Colour} -> Index;
        _ -> piece_index(Tail, Piece, Index+1)
    end;
piece_index([empty|Tail], Piece, Index) ->
    piece_index(Tail, Piece, Index+1);
piece_index([], _, _) ->
    not_found.

piece_square(Game, Piece) ->
    index_square(piece_index(Game, Piece)).

%% @doc Rank of a square.
-spec rank(square()) -> non_neg_integer().
rank(a1) -> 1;
rank(b1) -> 1;
rank(c1) -> 1;
rank(d1) -> 1;
rank(e1) -> 1;
rank(f1) -> 1;
rank(g1) -> 1;
rank(h1) -> 1;
rank(a2) -> 2;
rank(b2) -> 2;
rank(c2) -> 2;
rank(d2) -> 2;
rank(e2) -> 2;
rank(f2) -> 2;
rank(g2) -> 2;
rank(h2) -> 2;
rank(a3) -> 3;
rank(b3) -> 3;
rank(c3) -> 3;
rank(d3) -> 3;
rank(e3) -> 3;
rank(f3) -> 3;
rank(g3) -> 3;
rank(h3) -> 3;
rank(a4) -> 4;
rank(b4) -> 4;
rank(c4) -> 4;
rank(d4) -> 4;
rank(e4) -> 4;
rank(f4) -> 4;
rank(g4) -> 4;
rank(h4) -> 4;
rank(a5) -> 5;
rank(b5) -> 5;
rank(c5) -> 5;
rank(d5) -> 5;
rank(e5) -> 5;
rank(f5) -> 5;
rank(g5) -> 5;
rank(h5) -> 5;
rank(a6) -> 6;
rank(b6) -> 6;
rank(c6) -> 6;
rank(d6) -> 6;
rank(e6) -> 6;
rank(f6) -> 6;
rank(g6) -> 6;
rank(h6) -> 6;
rank(a7) -> 7;
rank(b7) -> 7;
rank(c7) -> 7;
rank(d7) -> 7;
rank(e7) -> 7;
rank(f7) -> 7;
rank(g7) -> 7;
rank(h7) -> 7;
rank(a8) -> 8;
rank(b8) -> 8;
rank(c8) -> 8;
rank(d8) -> 8;
rank(e8) -> 8;
rank(f8) -> 8;
rank(g8) -> 8;
rank(h8) -> 8.

%% @doc File of a square.
-spec file(square()) -> file().
file(a1) -> a;
file(b1) -> b;
file(c1) -> c;
file(d1) -> d;
file(e1) -> e;
file(f1) -> f;
file(g1) -> g;
file(h1) -> h;
file(a2) -> a;
file(b2) -> b;
file(c2) -> c;
file(d2) -> d;
file(e2) -> e;
file(f2) -> f;
file(g2) -> g;
file(h2) -> h;
file(a3) -> a;
file(b3) -> b;
file(c3) -> c;
file(d3) -> d;
file(e3) -> e;
file(f3) -> f;
file(g3) -> g;
file(h3) -> h;
file(a4) -> a;
file(b4) -> b;
file(c4) -> c;
file(d4) -> d;
file(e4) -> e;
file(f4) -> f;
file(g4) -> g;
file(h4) -> h;
file(a5) -> a;
file(b5) -> b;
file(c5) -> c;
file(d5) -> d;
file(e5) -> e;
file(f5) -> f;
file(g5) -> g;
file(h5) -> h;
file(a6) -> a;
file(b6) -> b;
file(c6) -> c;
file(d6) -> d;
file(e6) -> e;
file(f6) -> f;
file(g6) -> g;
file(h6) -> h;
file(a7) -> a;
file(b7) -> b;
file(c7) -> c;
file(d7) -> d;
file(e7) -> e;
file(f7) -> f;
file(g7) -> g;
file(h7) -> h;
file(a8) -> a;
file(b8) -> b;
file(c8) -> c;
file(d8) -> d;
file(e8) -> e;
file(f8) -> f;
file(g8) -> g;
file(h8) -> h.

%%
%% Moves
%%

-spec is_legal_move(game(), move()) -> boolean().
is_legal_move(Game, {move, From, To}) ->
    valid_square(From)
    andalso valid_square(To)
    andalso not square_empty(Game, From)
    andalso friendly_occupied(Game, From)
    andalso not friendly_occupied(Game, To)
    andalso is_valid_move(Game, From, To)
    andalso not current_player_in_check(Game).

-spec valid_square(square()) -> boolean().
valid_square(Square) ->
    lists:member(Square, ?SQUARES).

square_empty(Game, Square) ->
    piece_at(Game, Square) =:= empty.

friendly_occupied(Game, Square) ->
    piece_colour(piece_at(Game, Square)) =:= game_current_player(Game).

enemy_occupied(Game, Square) ->
    Piece = piece_at(Game, Square),
    Colour = piece_colour(Piece),
    (Piece =/= empty) andalso (Colour =/= game_current_player(Game)).

is_valid_move(Game, From, To) ->
    Piece = piece_at(Game, From),
    is_valid_move_for_piece(Game, Piece, From, To).

pawn_has_moved(Colour, Square) ->
    case Colour of
        white -> rank(Square) =/= 2;
        black -> rank(Square) =/= 7
    end.

%% @doc Determine if this piece can make this move, e.g. a pawn pushing forward
%% one or 2 spaces, a knight making an L-shaped move. 2D moves map to 1D moves:
%%
%%      1 space right           1 space along
%%      1 space forward         8 spaces along
%%      N spaces forward        Distance rem 8 =:= 0
%%      NE diagonal moves       Distance rem 9 =:= 0
%%      NW diagonal moves       Distance rem 7 =:= 0
%%      Knight moves            Distance in [6, 10, 15, 17, -6, -10, -15, -17]
%%
%% Assumes that both From and To are valid board squares.
%%
is_valid_move_for_piece(Game, {piece, pawn, Colour}, From, To) ->
    Dir = case Colour of white -> 1; black -> -1 end,
    Distance = distance(From, To),
    (Distance =:= ?VERT_SLOPE * Dir)
    orelse (((Distance =:= NW_DIAG_SLOPE * Dir)
             orelse (Distance =:= NE_DIAG_SLOPE * Dir))
            andalso enemy_occupied(Game, To))
    orelse ((Distance =:= ?VERT_SLOPE * 2 * Dir)
            andalso not pawn_has_moved(Colour, From)
            andalso not vert_move_is_blocked(Game, From, To));
is_valid_move_for_piece(Game, {piece, rook, _Colour}, From, To) ->
    is_unblocked_lateral(Game, From, To);
is_valid_move_for_piece(Game, {piece, bishop, _Colour}, From, To) ->
    is_unblocked_diagonal(Game, From, To);
is_valid_move_for_piece(_Game, _Piece, _From, _To) ->
    false.

-spec distance(square(), square()) -> integer().
distance(From, To) ->
    square_index(To) - square_index(From).

is_unblocked_lateral(Game, From, To) ->
    is_unblocked_horiz(Game, From, To) orelse is_unblocked_vert(Game, From, To).

is_unblocked_horiz(Game, From, To) ->
    (rank(From) =:= rank(To)) andalso not horiz_move_is_blocked(Game, From, To).

horiz_move_is_blocked(Game, From, To) ->
    is_blocked(Game, From, To, ?HORIZ_SLOPE).

is_unblocked_vert(Game, From, To) ->
    (file(From) =:= file(To)) andalso not vert_move_is_blocked(Game, From, To).

vert_move_is_blocked(Game, From, To) ->
    is_blocked(Game, From, To, ?VERT_SLOPE).

is_blocked(Game, From, To, Slope) ->
    IntermediateSquares = intermediate_squares(Game, From, To, Slope),
    lists:any(fun(P) -> P =/= empty end, IntermediateSquares).

intermediate_squares(Game, From, To, Interval) ->
    Start = square_index(From),
    End = square_index(To),
    Step = case Start < End of
        true -> abs(Interval);
        false -> -abs(Interval)
    end,
    AllSquareIndices = lists:seq(Start, End, Step),
    IntermediateSquareIndices = lists:sublist(AllSquareIndices, 2,
                                              length(AllSquareIndices) - 2),
    [piece_at(Game, index_square(I)) || I <- IntermediateSquareIndices].

is_unblocked_diagonal(Game, From, To) ->
    is_unblocked_ne_diagonal(Game, From, To)
    orelse is_unblocked_se_diagonal(Game, From, To)
    orelse is_unblocked_sw_diagonal(Game, From, To)
    orelse is_unblocked_nw_diagonal(Game, From, To).

is_ne_diagonal(From, To) ->
    D = distance(From, To),
    (D > 0) andalso (D rem ?NE_DIAG_SLOPE =:= 0).

is_unblocked_ne_diagonal(Game, From, To) ->
    is_ne_diagonal(From, To) andalso not is_blocked(Game, From, To, ?NE_DIAG_SLOPE).

is_se_diagonal(From, To) ->
    D = distance(From, To),
    (D < 0) andalso (D rem ?SE_DIAG_SLOPE =:= 0).

is_unblocked_se_diagonal(Game, From, To) ->
    is_se_diagonal(From, To) andalso not is_blocked(Game, From, To, ?SE_DIAG_SLOPE).

is_sw_diagonal(From, To) ->
    D = distance(From, To),
    (D < 0) andalso (D rem ?SW_DIAG_SLOPE =:= 0).

is_unblocked_sw_diagonal(Game, From, To) ->
    is_sw_diagonal(From, To) andalso not is_blocked(Game, From, To, ?SW_DIAG_SLOPE).

is_nw_diagonal(From, To) ->
    D = distance(From, To),
    (D > 0) andalso (D rem ?NW_DIAG_SLOPE =:= 0).

is_unblocked_nw_diagonal(Game, From, To) ->
    is_nw_diagonal(From, To) andalso not is_blocked(Game, From, To, ?NW_DIAG_SLOPE).

current_player_in_check(#game{board=Board} = Game) ->
    Colour = game_current_player(Game),
    case piece_square(Game, piece(king, Colour)) of
        not_found ->
            false;
        KingSquare ->
            lists:any(fun(P) -> is_attacking(Game, P, KingSquare) end, Board)
    end.

is_attacking(_Game, Piece, Target) ->
    (Piece =/= Target)
    andalso (piece_colour(Piece) =/= piece_colour(Target))
    %% TODO other stuff...
    andalso false.

%%
%% Text output
%%

%% @doc Return string representation of a game.
-spec show_game(game()) -> string().
show_game(#game{board=Board}) ->
    show_board(Board).

-spec show_board(board()) -> string().
show_board(Board) ->
    show_ranks(lists:reverse(board_ranks(Board))).

show_ranks(Ranks) ->
    string:join([show_rank(R) || R <- Ranks], "\n").

show_rank(Rank) ->
    [show_piece(P) || P <- Rank].

-spec show_piece(piece()) -> char().
show_piece({piece, king, black}) -> $♔;
show_piece({piece, queen, black}) -> $♕;
show_piece({piece, rook, black}) -> $♖;
show_piece({piece, bishop, black}) -> $♗;
show_piece({piece, knight, black}) -> $♘;
show_piece({piece, pawn, black}) -> $♙;
show_piece({piece, king, white}) -> $♚;
show_piece({piece, queen, white}) -> $♛;
show_piece({piece, rook, white}) -> $♜;
show_piece({piece, bishop, white}) -> $♝;
show_piece({piece, knight, white}) -> $♞;
show_piece({piece, pawn, white}) -> $♟;
show_piece(empty) -> $\s;
show_piece(_) -> $?.

%%
%% Forsyth–Edwards Notation
%%

%% @doc Create a game from a FEN string.
-spec fen(string()) -> game().
fen(Fen) ->
    FenTokens = string:tokens(Fen, " "),
    case length(FenTokens) of
        1 ->
            [FenBoard] = FenTokens,
            fen_game(FenBoard);
        4 ->
            [FenBoard, CurrentPlayer, Castling, EnPassantSquare] = FenTokens,
            fen_game(FenBoard, CurrentPlayer, Castling, EnPassantSquare);
        6 ->
            [FenBoard, CurrentPlayer, Castling, EnPassantSquare, HalfMoveClock,
             FullMoveNumber] = FenTokens,
            fen_game(FenBoard, CurrentPlayer, Castling, EnPassantSquare,
                     HalfMoveClock, FullMoveNumber);
        _ ->
            badarg
    end.

fen_game(FenBoard) ->
    fen_game(FenBoard, "w", "KQkq", "-").

fen_game(FenBoard, CurrentPlayer, Castling, EnPassantSquare) ->
    fen_game(FenBoard, CurrentPlayer, Castling, EnPassantSquare, "0", "1").

fen_game(FenBoard, CurrentPlayer, Castling, EnPassantSquare, HalfMoveClock,
         FullMoveNumber) ->
    Board = fen_board(lists:flatten(lists:reverse(string:tokens(FenBoard, "/")))),
    game(Board,
         fen_current_player(CurrentPlayer),
         fen_castling(Castling),
         list_to_atom(EnPassantSquare),
         list_to_integer(HalfMoveClock),
         list_to_integer(FullMoveNumber)).

%% @doc Convert FEN board representation to our list representation.
-spec fen_board(string()) -> board().
fen_board([]) -> [];
fen_board([$P|T]) -> [wP()|fen_board(T)];
fen_board([$N|T]) -> [wN()|fen_board(T)];
fen_board([$B|T]) -> [wB()|fen_board(T)];
fen_board([$R|T]) -> [wR()|fen_board(T)];
fen_board([$Q|T]) -> [wQ()|fen_board(T)];
fen_board([$K|T]) -> [wK()|fen_board(T)];
fen_board([$p|T]) -> [bP()|fen_board(T)];
fen_board([$n|T]) -> [bN()|fen_board(T)];
fen_board([$b|T]) -> [bB()|fen_board(T)];
fen_board([$r|T]) -> [bR()|fen_board(T)];
fen_board([$q|T]) -> [bQ()|fen_board(T)];
fen_board([$k|T]) -> [bK()|fen_board(T)];
fen_board([$1|T]) -> [empty|fen_board(T)];
fen_board([$2|T]) -> [empty,empty|fen_board(T)];
fen_board([$3|T]) -> [empty,empty,empty|fen_board(T)];
fen_board([$4|T]) -> [empty,empty,empty,empty|fen_board(T)];
fen_board([$5|T]) -> [empty,empty,empty,empty,empty|fen_board(T)];
fen_board([$6|T]) -> [empty,empty,empty,empty,empty,empty|fen_board(T)];
fen_board([$7|T]) -> [empty,empty,empty,empty,empty,empty,empty|fen_board(T)];
fen_board([$8|T]) -> [empty,empty,empty,empty,empty,empty,empty,empty|fen_board(T)].

-spec fen_current_player(string()) -> colour().
fen_current_player(Player) ->
    case Player of "w" -> white; "b" -> black end.

-spec fen_castling(string()) -> castling().
fen_castling(CastlingString) ->
    #castling{white_kingside=lists:member($K, CastlingString),
              white_queenside=lists:member($Q, CastlingString),
              black_kingside=lists:member($k, CastlingString),
              black_queenside=lists:member($q, CastlingString)}.
