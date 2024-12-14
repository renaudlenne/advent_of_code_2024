import gleam/function
import gleam/list
import gleam/string
import glearray

pub fn parse_matrix(input: String) {
  parse_matrix_and_map(input, function.identity)
}

pub fn parse_matrix_and_map(input: String, transform: fn(String) -> a) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    string.to_graphemes(line)
    |> list.map(transform)
    |> glearray.from_list()
  })
  |> glearray.from_list()
}

pub type Matrix =
  GenericMatrix(String)

pub type IntMatrix =
  GenericMatrix(Int)

pub type GenericMatrix(a) =
  glearray.Array(glearray.Array(a))

pub type Coord =
  #(Int, Int)

pub fn dimensions(matrix: GenericMatrix(a)) {
  let nb_lines = glearray.length(matrix)
  let assert Ok(first_line) = glearray.get(matrix, 0)
  let nb_cols = glearray.length(first_line)
  #(nb_cols, nb_lines)
}

pub fn get_at_coord(matrix: GenericMatrix(a), pos: Coord) {
  case pos {
    #(a, b) if a < 0 || b < 0 -> Error(Nil)
    _ -> {
      case glearray.get(matrix, pos.1) {
        Ok(line) -> glearray.get(line, pos.0)
        _ -> Error(Nil)
      }
    }
  }
}

pub type Direction {
  North
  East
  South
  West
}

pub fn go_n(pos: Coord) {
  #(pos.0, pos.1 - 1)
}

pub fn go_e(pos: Coord) {
  #(pos.0 + 1, pos.1)
}

pub fn go_s(pos: Coord) {
  #(pos.0, pos.1 + 1)
}

pub fn go_w(pos: Coord) {
  #(pos.0 - 1, pos.1)
}

pub fn neighbors(pos: Coord) {
  [go_n(pos), go_e(pos), go_s(pos), go_w(pos)]
}

pub fn neighbors_with_dir(pos: Coord) {
  [
    #(go_n(pos), North),
    #(go_e(pos), East),
    #(go_s(pos), South),
    #(go_w(pos), West),
  ]
}

pub fn turn_right(direction: Direction) {
  case direction {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

pub fn direction(move: #(Coord, Coord)) {
  let #(from, to) = move
  case to {
    #(x, y) if x == from.0 && y == from.1 - 1 -> Ok(North)
    #(x, y) if x == from.0 + 1 && y == from.1 -> Ok(East)
    #(x, y) if x == from.0 && y == from.1 + 1 -> Ok(South)
    #(x, y) if x == from.0 - 1 && y == from.1 -> Ok(West)
    _ -> Error(Nil)
  }
}

pub fn apply(pos: Coord, direction: Direction) {
  case direction {
    North -> go_n(pos)
    East -> go_e(pos)
    South -> go_s(pos)
    West -> go_w(pos)
  }
}
