import gleam/list
import gleam/string
import gleam/yielder

pub fn parse_matrix(input: String) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    string.to_graphemes(line)
    |> yielder.from_list()
  })
  |> yielder.from_list()
}

pub type Matrix =
yielder.Yielder(yielder.Yielder(String))

pub type Coord =
#(Int, Int)

pub fn dimensions(matrix: Matrix) {
  let nb_lines = yielder.length(matrix)
  let assert Ok(first_line) = yielder.at(matrix, 0)
  let nb_cols = yielder.length(first_line)
  #(nb_cols, nb_lines)
}

pub fn get_at_coord(matrix: Matrix, pos: Coord) {
  case pos {
    #(a, b) if a < 0 || b < 0 -> Error(Nil)
    _ -> {
      case yielder.at(matrix, pos.1) {
        Ok(line) -> yielder.at(line, pos.0)
        _ -> Error(Nil)
      }
    }
  }
}

pub fn go_n(pos: Coord) {#(pos.0, pos.1 - 1)}
pub fn go_e(pos: Coord) {#(pos.0 + 1, pos.1)}
pub fn go_s(pos: Coord) {#(pos.0, pos.1 + 1)}
pub fn go_w(pos: Coord) {#(pos.0 - 1, pos.1)}
