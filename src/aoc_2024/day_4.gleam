import gleam/list
import gleam/string
import gleam/yielder

pub fn parse(input: String) {
  string.split(input, "\n")
  |> list.map(fn (line) {
    string.to_graphemes(line)
    |> yielder.from_list()
  })
  |> yielder.from_list()
}

type Matrix = yielder.Yielder(yielder.Yielder(String))
type Coord = #(Int, Int)

fn get_at_coord(matrix: Matrix, pos: Coord) {
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

fn find(matrix: Matrix, pos: Coord, to_find: List(String), next_pos: fn(#(Int, Int)) -> #(Int, Int)) {
  case get_at_coord(matrix, pos) {
    Ok(current) -> {
      case to_find {
        [a] if a == current -> 1
        [a, ..rest] if a == current -> find(matrix, next_pos(pos), rest, next_pos)
        _ -> 0
      }
    }
    _ -> 0
  }
}

fn count_from(matrix: Matrix, to_find: List(String), starting_pos: Coord) {
  find(matrix, starting_pos, to_find, fn(pos) { #(pos.0, pos.1 - 1)})
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 + 1, pos.1 - 1)})
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 + 1, pos.1)})
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 + 1, pos.1 + 1)})
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0, pos.1 + 1)})
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 - 1, pos.1 + 1)})
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 - 1, pos.1)})
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 - 1, pos.1 - 1)})
}

fn find_xmas(matrix: Matrix) {
  let to_find = string.to_graphemes("XMAS")

  let nb_lines = yielder.length(matrix)
  let assert Ok(first_line) = yielder.at(matrix, 0)
  let nb_cols = yielder.length(first_line)

  yielder.range(from: 0, to: nb_lines-1)
  |> yielder.fold(0, fn(acc_line, y) {
    yielder.range(from: 0, to: nb_cols-1)
    |> yielder.fold(acc_line, fn(acc, x) {
      acc + count_from(matrix, to_find, #(x, y))
    })
  })
}

pub fn pt_1(input: Matrix) {
  find_xmas(input)
}

pub fn pt_2(input: Matrix) {
  todo as "part 2 not implemented"
}
