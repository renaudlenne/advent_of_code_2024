import gleam/list
import gleam/string
import gleam/yielder

pub fn parse(input: String) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    string.to_graphemes(line)
    |> yielder.from_list()
  })
  |> yielder.from_list()
}

type Matrix =
  yielder.Yielder(yielder.Yielder(String))

type Coord =
  #(Int, Int)

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

fn find(
  matrix: Matrix,
  pos: Coord,
  to_find: List(String),
  next_pos: fn(#(Int, Int)) -> #(Int, Int),
) {
  case get_at_coord(matrix, pos) {
    Ok(current) -> {
      case to_find {
        [a] if a == current -> 1
        [a, ..rest] if a == current ->
          find(matrix, next_pos(pos), rest, next_pos)
        _ -> 0
      }
    }
    _ -> 0
  }
}

fn count_from(matrix: Matrix, to_find: List(String), starting_pos: Coord) {
  find(matrix, starting_pos, to_find, fn(pos) { #(pos.0, pos.1 - 1) })
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 + 1, pos.1 - 1) })
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 + 1, pos.1) })
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 + 1, pos.1 + 1) })
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0, pos.1 + 1) })
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 - 1, pos.1 + 1) })
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 - 1, pos.1) })
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 - 1, pos.1 - 1) })
}

fn dimensions(matrix: Matrix) {
  let nb_lines = yielder.length(matrix)
  let assert Ok(first_line) = yielder.at(matrix, 0)
  let nb_cols = yielder.length(first_line)
  #(nb_cols, nb_lines)
}

fn fold_over_matrix(matrix: Matrix, count_fn: fn(Matrix, #(Int, Int)) -> Int) {
  let #(nb_cols, nb_lines) = dimensions(matrix)
  yielder.range(from: 0, to: nb_lines - 1)
  |> yielder.fold(0, fn(acc_line, y) {
    yielder.range(from: 0, to: nb_cols - 1)
    |> yielder.fold(acc_line, fn(acc, x) { acc + count_fn(matrix, #(x, y)) })
  })
}

pub fn pt_1(input: Matrix) {
  let xmas = string.to_graphemes("XMAS")
  fold_over_matrix(input, fn(matrix, pos) { count_from(matrix, xmas, pos) })
}

pub fn pt_2(input: Matrix) {
  let mas = string.to_graphemes("MAS")
  fold_over_matrix(input, fn(matrix, x_pos) {
    case
      find(matrix, #(x_pos.0 - 1, x_pos.1 - 1), mas, fn(pos) {
        #(pos.0 + 1, pos.1 + 1)
      })
      + find(matrix, #(x_pos.0 + 1, x_pos.1 + 1), mas, fn(pos) {
        #(pos.0 - 1, pos.1 - 1)
      })
    {
      1 -> {
        find(matrix, #(x_pos.0 + 1, x_pos.1 - 1), mas, fn(pos) {
          #(pos.0 - 1, pos.1 + 1)
        })
        + find(matrix, #(x_pos.0 - 1, x_pos.1 + 1), mas, fn(pos) {
          #(pos.0 + 1, pos.1 - 1)
        })
      }
      _ -> 0
    }
  })
}
