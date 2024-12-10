import gleam/int
import gleam/list
import gleam/set
import glearray
import utils/matrix

pub fn parse(input: String) {
  matrix.parse_matrix_and_map(input, fn(str) {
    let assert Ok(i) = int.parse(str)
    i
  })
}

fn count_paths(
  map: matrix.IntMatrix,
  prev_elem: Int,
  pos: matrix.Coord,
  visited: set.Set(matrix.Coord),
) {
  case matrix.get_at_coord(map, pos) {
    Ok(9) if prev_elem == 8 -> #(1, set.insert(visited, pos))
    Ok(i) if i == prev_elem + 1 -> {
      matrix.neighbors(pos)
      |> list.fold(#(0, set.insert(visited, pos)), fn(acc, neighbor) {
        let #(score, acc_visited) = acc
        case set.contains(acc_visited, neighbor) {
          True -> acc
          _ -> {
            let #(path_score, new_visited) =
              count_paths(map, i, neighbor, acc_visited)
            #(score + path_score, new_visited)
          }
        }
      })
    }
    _ -> #(0, visited)
  }
}

pub fn pt_1(input: matrix.IntMatrix) {
  input
  |> glearray.to_list
  |> list.index_fold(0, fn(acc_l, line, y) {
    line
    |> glearray.to_list
    |> list.index_fold(acc_l, fn(acc, elem, x) {
      case elem {
        0 -> {
          let #(score, _) = count_paths(input, -1, #(x, y), set.new())
          acc + score
        }
        _ -> acc
      }
    })
  })
}

fn count_all_paths(map: matrix.IntMatrix, prev_elem: Int, pos: matrix.Coord) {
  case matrix.get_at_coord(map, pos) {
    Ok(9) if prev_elem == 8 -> 1
    Ok(i) if i == prev_elem + 1 -> {
      matrix.neighbors(pos)
      |> list.fold(0, fn(score, neighbor) {
        score + count_all_paths(map, i, neighbor)
      })
    }
    _ -> 0
  }
}

pub fn pt_2(input: matrix.IntMatrix) {
  input
  |> glearray.to_list
  |> list.index_fold(0, fn(acc_l, line, y) {
    line
    |> glearray.to_list
    |> list.index_fold(acc_l, fn(acc, elem, x) {
      case elem {
        0 -> {
          acc + count_all_paths(input, -1, #(x, y))
        }
        _ -> acc
      }
    })
  })
}
