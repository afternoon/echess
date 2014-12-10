-module(erlang_chess_game).

-compile(export_all).

%% @doc Flags are stored as proplists.
-type flags() :: [{atom(), any()}].

%% @doc Square names (from coordinate/algebraic notations).
-type square() :: h1 | h2 | h3 | h4 | h5 | h6 | h7 | h8 |
                  g1 | g2 | g3 | g4 | g5 | g6 | g7 | g8 |
                  f1 | f2 | f3 | f4 | f5 | f6 | f7 | f8 |
                  e1 | e2 | e3 | e4 | e5 | e6 | e7 | e8 |
                  d1 | d2 | d3 | d4 | d5 | d6 | d7 | d8 |
                  c1 | c2 | c3 | c4 | c5 | c6 | c7 | c8 |
                  b1 | b2 | b3 | b4 | b5 | b6 | b7 | b8 |
                  a1 | a2 | a3 | a4 | a5 | a6 | a7 | a8.

%% @doc Classes of piece. In chess, "piece" seems to refer to both the piece
%% type and an individual piece on the board.
-type piece_class() :: king | queen | rook | bishop | knight | pawn.

%% @doc Piece/player colours.
-type colour() :: white | black.

%% @doc A piece is a tuple of the piece type, colour and some flags, e.g.
%% whether a king has moved yet (so the availability of castling can be
%% determined), or if a pawn has yet pushed 2 squares.
-type piece() :: {piece_class(), colour(), flags()}.

%% @doc Moves are implemented using the coordinate system split into a tuple of
%% from and to squares.
-type move() :: {From::square(), To::square()}.
-type moves() :: [move()].

%% @doc A board is a list of 64 elements, either a piece %% or the atom `empty`.
%% The first square (a1, head of the list) is the bottom left of the board.
-type board() :: [piece() | empty, ...].

%% @doc A game consists of a board, a list of moves and some flags.
-type game() :: {board(), moves(), flags()}.

%% Shortcut piece constructors
wP() -> {pawn, white, []}.
wN() -> {knight, white, []}.
wB() -> {bishop, white, []}.
wR() -> {rook, white, []}.
wQ() -> {queen, white, []}.
wK() -> {king, white, []}.
bP() -> {pawn, black, []}.
bN() -> {knight, black, []}.
bB() -> {bishop, black, []}.
bR() -> {rook, black, []}.
bQ() -> {queen, black, []}.
bK() -> {king, black, []}.

%% @doc Create a brand new game in the starting position.
-spec new() -> game().
new() -> {starting_board(), [], []}.

%% @doc Create a board in the standard starting position.
%% N.B. board coordinates start at the bottom left.
-spec starting_board() -> board().
starting_board() ->
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

%% @doc Board operations.

piece_at(Square, Board) -> empty.

find(Name, Colour, Board) ->
    undef.
    % get index of piece in Board
    % translate index to square name, e.g. e4

square_name(1) -> a1;
square_name(2) -> a2;
square_name(64) -> h8.

square_index(a1) -> 1;
square_index(a2) -> 2;
square_index(h8) -> 64.

ranks([A,B,C,D,E,F,G,H]) ->
    [[A,B,C,D,E,F,G,H]];
ranks([A,B,C,D,E,F,G,H|Tail]) ->
    [[A,B,C,D,E,F,G,H]|ranks(Tail)].

show_game({Board, _, _}) ->
    show_ranks(lists:reverse(ranks(Board))).

show_ranks(Ranks) ->
    string:join([show_rank(R) || R <- Ranks], "\n").

show_rank(Rank) ->
    [show_piece(P) || P <- Rank].

show_piece({king, black, _}) -> $♔;
show_piece({queen, black, _}) -> $♕;
show_piece({rook, black, _}) -> $♖;
show_piece({bishop, black, _}) -> $♗;
show_piece({knight, black, _}) -> $♘;
show_piece({pawn, black, _}) -> $♙;
show_piece({king, white, _}) -> $♚;
show_piece({queen, white, _}) -> $♛;
show_piece({rook, white, _}) -> $♜;
show_piece({bishop, white, _}) -> $♝;
show_piece({knight, white, _}) -> $♞;
show_piece({pawn, white, _}) -> $♟;
show_piece(empty) -> $\s;
show_piece(_) -> $?.
