import glearray
import gleam/list
import gleam/string

pub fn parse_matrix(input: String) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    string.to_graphemes(line)
    |> glearray.from_list()
  })
  |> glearray.from_list()
}

pub type Matrix =
glearray.Array(glearray.Array(String))

pub type Coord =
#(Int, Int)

pub fn dimensions(matrix: Matrix) {
  let nb_lines = glearray.length(matrix)
  let assert Ok(first_line) = glearray.get(matrix, 0)
  let nb_cols = glearray.length(first_line)
  #(nb_cols, nb_lines)
}

pub fn get_at_coord(matrix: Matrix, pos: Coord) {
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

pub fn go_n(pos: Coord) {#(pos.0, pos.1 - 1)}
pub fn go_e(pos: Coord) {#(pos.0 + 1, pos.1)}
pub fn go_s(pos: Coord) {#(pos.0, pos.1 + 1)}
pub fn go_w(pos: Coord) {#(pos.0 - 1, pos.1)}
