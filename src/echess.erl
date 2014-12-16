-module(echess).

-compile(export_all).

-define(SQUARES, [a1, b1, c1, d1, e1, f1, g1, h1,
                  a2, b2, c2, d2, e2, f2, g2, h2,
                  a3, b3, c3, d3, e3, f3, g3, h3,
                  a4, b4, c4, d4, e4, f4, g4, h4,
                  a5, b5, c5, d5, e5, f5, g5, h5,
                  a6, b6, c6, d6, e6, f6, g6, h6,
                  a7, b7, c7, d7, e7, f7, g7, h7,
                  a8, b8, c8, d8, e8, f8, g8, h8]).

%% @doc Flags are stored as proplists.
-type flags() :: [{atom(), any()}].

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

%% @doc A piece is a tuple of the piece type, colour and some flags, e.g.
%% whether a king has moved yet (so the availability of castling can be
%% determined), or if a pawn has yet pushed 2 squares.
-type piece() :: {piece, piece_class(), colour(), flags()}.

%% @doc Moves are implemented using the coordinate system split into a tuple of
%% from and to squares.
-type move() :: {move, From::square(), To::square()}.
-type moves() :: [move()].

%% @doc A board is a list of 64 elements, either a piece %% or the atom `empty`.
%% The first square (a1, head of the list) is the bottom left of the board as
%% viewed by white.
-type board() :: [piece() | empty, ...].

%% @doc A game consists of a board, a list of moves and some flags.
-type game() :: {game, board(), flags(), moves()}.

%%
%% Constructors
%%

%% @doc Create a brand new game in the starting position.
-spec new() -> game().
new() -> game(starting_position()).

%% @doc Create a game with the specified board.
-spec game(board()) -> game().
game(Board) ->
    game(Board, flags()).

%% @doc Create a game with the specified board and flags.
-spec game(board(), flags()) -> game().
game(Board, Flags) ->
    {game, Board, Flags, []}.

%% @doc Create a board in the standard starting position.
%% N.B. board coordinates start at the bottom left.
-spec starting_position() -> board().
starting_position() ->
    [
        wR(),  wN(),  wB(),  wQ(),  wK(),  wB(),  wN(),  wR(),
        wP(),  wP(),  wP(),  wP(),  wP(),  wP(),  wP(),  wP(),
        empty, empty, empty, empty, empty, empty, empty, empty,
        empty, empty, empty, empty, empty, empty, empty, empty,
        empty, empty, empty, empty, empty, empty, empty, empty,
        empty, empty, empty, empty, empty, empty, empty, empty,
        bP(),  bP(),  bP(),  bP(),  bP(),  bP(),  bP(),  bP(),
        bR(),  bN(),  bB(),  bQ(),  bK(),  bB(),  bN(),  bR()
    ].

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

%% @doc Piece constructor (without flags).
-spec piece(piece_class(), colour()) -> piece().
piece(Class, Colour) -> piece(Class, Colour, flags()).

%% @doc Piece constructor (with flags).
-spec piece(piece_class(), colour(), flags()) -> piece().
piece(Class, Colour, Flags) -> {piece, Class, Colour, Flags}.

%% @doc Flags constructor.
-spec flags() -> flags().
flags() -> [].

%% @doc Move constructor.
-spec move(_From, _To) -> move().
move(From, To) -> {move, From, To}.

%%
%% Game operations
%%

current_player({game, _, Flags, _}) ->
    proplists:get_value(current_player, Flags, white).

%%
%% Board operations
%%

ranks([A,B,C,D,E,F,G,H]) ->
    [[A,B,C,D,E,F,G,H]];
ranks([A,B,C,D,E,F,G,H|Tail]) ->
    [[A,B,C,D,E,F,G,H]|ranks(Tail)].

%% @doc Get the numerical index of a square.
-spec square_index(square()) -> number().
square_index(Square) ->
    SquareIndexMap = lists:zip(?SQUARES, lists:seq(1, 64)),
    proplists:get_value(Square, SquareIndexMap).

%% @doc Get the square name for a numerical square index.
-spec index_square(number()) -> square().
index_square(Index) ->
    lists:nth(Index, ?SQUARES).

%% @doc Get the piece at a square.
-spec piece_at(game(), square()) -> piece().
piece_at({game, Board, _, _}, Square) ->
    N = square_index(Square),
    lists:nth(N, Board).

piece_colour({piece, _, Colour, _}) ->
    Colour;
piece_colour(_) ->
    badarg.

piece_index({game, Board, _, _}, Piece) ->
    piece_index(Board, Piece, 1).

piece_index([], _, _) ->
    not_found;
piece_index([{piece, Class, Colour, _}|Tail], Piece, Index) ->
    case Piece of
        {piece, Class, Colour, _} -> Index;
        _ -> piece_index(Tail, Piece, Index+1)
    end.

piece_square(Game, Piece) ->
    index_square(piece_index(Game, Piece)).

%%
%% Moves
%%

-spec is_legal_move(game(), move()) -> boolean().
is_legal_move(Game, {move, From, To}) ->
    valid_square(From)
    and valid_square(To)
    and not square_empty(Game, From)
    and friendly_occupied(Game, From)
    and not friendly_occupied(Game, To)
    and is_valid_move(Game, From, To)
    and not current_player_in_check(Game).

-spec valid_square(square()) -> boolean().
valid_square(Square) ->
    lists:member(Square, ?SQUARES).

square_empty(Game, Square) ->
    piece_at(Game, Square) =:= empty.

friendly_occupied(Game, Square) ->
    piece_colour(piece_at(Game, Square)) =:= current_player(Game).

enemy_occupied(Game, Square) ->
    Piece = piece_at(Game, Square),
    Colour = piece_colour(Piece),
    (Piece =/= empty) and (Colour =/= current_player(Game)).

is_valid_move(Game, From, To) ->
    Piece = piece_at(Game, From),
    is_valid_move_for_piece(Game, Piece, From, To).

pawn_has_moved(Colour, Square) ->
    case Colour of
        white -> not lists:member(Square, [a2, b2, c2, d2, e2, f2, g2, h2]);
        black -> not lists:member(Square, [a7, b7, c7, d7, e7, f7, g7, h7])
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
is_valid_move_for_piece(Game, {piece, pawn, white, _}, From, To) ->
    Distance = distance(From, To),
    (Distance =:= 8)
    or (enemy_occupied(Game, To) and ((Distance =:= 7) or (Distance =:= 9)))
    or (not pawn_has_moved(white, From) and (Distance =:= 16));
is_valid_move_for_piece(Game, {piece, pawn, black, _}, From, To) ->
    Distance = distance(From, To),
    (Distance =:= -8)
    or (enemy_occupied(Game, To) and ((Distance =:= -7) or (Distance =:= -9)))
    or (not pawn_has_moved(black, From) and (Distance =:= -16));
is_valid_move_for_piece(_, _, _, _) ->
    false.

-spec distance(square(), square()) -> number().
distance(From, To) ->
    square_index(To) - square_index(From).

current_player_in_check({game, Board, _, _} = Game) ->
    Player = current_player(Game),
    KingSquare = piece_square(Game, piece(king, Player)),
    lists:any(fun(P) -> is_attacking(Game, KingSquare, P) end, Board).

is_attacking(_Game, Target, Attacker) ->
    (Target =/= Attacker)
    and (piece_colour(Target) =/= piece_colour(Attacker))
    %% other stuff...
    and false.

%%
%% Text output
%%

%% @doc Return string representation of a game.
-spec show_game(game()) -> string().
show_game({game, Board, _, _}) ->
    show_board(Board).

-spec show_board(board()) -> string().
show_board(Board) ->
    show_ranks(lists:reverse(ranks(Board))).

show_ranks(Ranks) ->
    string:join([show_rank(R) || R <- Ranks], "\n").

show_rank(Rank) ->
    [show_piece(P) || P <- Rank].

-spec show_piece(piece()) -> char().
show_piece({piece, king, black, _}) -> $♔;
show_piece({piece, queen, black, _}) -> $♕;
show_piece({piece, rook, black, _}) -> $♖;
show_piece({piece, bishop, black, _}) -> $♗;
show_piece({piece, knight, black, _}) -> $♘;
show_piece({piece, pawn, black, _}) -> $♙;
show_piece({piece, king, white, _}) -> $♚;
show_piece({piece, queen, white, _}) -> $♛;
show_piece({piece, rook, white, _}) -> $♜;
show_piece({piece, bishop, white, _}) -> $♝;
show_piece({piece, knight, white, _}) -> $♞;
show_piece({piece, pawn, white, _}) -> $♟;
show_piece(empty) -> $\s;
show_piece(_) -> $?.

%%
%% Forsyth–Edwards Notation
%%

fen(Fen) ->
    FenTokens = string:tokens(Fen, " "),
    [FenBoard, CurrentPlayerShort, _Castling, _EnPassant, _HalfMoveClock, _FullMoveClock] = FenTokens,
    Board = lists:flatten(lists:reverse(string:tokens(FenBoard, "/"))),
    CurrentPlayer = case CurrentPlayerShort of "w" -> white; "b" -> black end,
    Flags = [{current_player, CurrentPlayer}],
    game(fen_board(Board), Flags).

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

