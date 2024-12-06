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

