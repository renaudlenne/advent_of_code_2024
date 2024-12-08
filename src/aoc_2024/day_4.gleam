import gleam/string
import gleam/yielder
import utils/matrix

fn find(
  matrix: matrix.Matrix,
  pos: matrix.Coord,
  to_find: List(String),
  next_pos: fn(#(Int, Int)) -> #(Int, Int),
) {
  case matrix.get_at_coord(matrix, pos) {
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

fn count_from(
  matrix: matrix.Matrix,
  to_find: List(String),
  starting_pos: matrix.Coord,
) {
  find(matrix, starting_pos, to_find, fn(pos) { #(pos.0, pos.1 - 1) })
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 + 1, pos.1 - 1) })
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 + 1, pos.1) })
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 + 1, pos.1 + 1) })
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0, pos.1 + 1) })
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 - 1, pos.1 + 1) })
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 - 1, pos.1) })
  + find(matrix, starting_pos, to_find, fn(pos) { #(pos.0 - 1, pos.1 - 1) })
}

fn fold_over_matrix(
  matrix: matrix.Matrix,
  count_fn: fn(matrix.Matrix, #(Int, Int)) -> Int,
) {
  let #(nb_cols, nb_lines) = matrix.dimensions(matrix)
  yielder.range(from: 0, to: nb_lines - 1)
  |> yielder.fold(0, fn(acc_line, y) {
    yielder.range(from: 0, to: nb_cols - 1)
    |> yielder.fold(acc_line, fn(acc, x) { acc + count_fn(matrix, #(x, y)) })
  })
}

pub fn parse(input: String) {
  matrix.parse_matrix(input)
}

pub fn pt_1(input: matrix.Matrix) {
  let xmas = string.to_graphemes("XMAS")
  fold_over_matrix(input, fn(matrix, pos) { count_from(matrix, xmas, pos) })
}

pub fn pt_2(input: matrix.Matrix) {
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
