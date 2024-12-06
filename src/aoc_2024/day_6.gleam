import gleam/set
import gleam/yielder
import utils/matrix

pub fn parse(input: String) { matrix.parse_matrix(input) }

fn find_guard(map: matrix.Matrix)  {
  map
  |> yielder.index()
  |> yielder.find_map(fn(indexed_line) {
    let #(line, y) = indexed_line
    line
    |> yielder.index()
    |> yielder.find_map(fn(elem) {
      case elem.0 {
        "."|"#" -> Error(Nil)
        _ -> Ok(#(elem.1, y))
      }
    })
  })
}

type Direction {
  North
  East
  South
  West
}

fn turn_right(direction: Direction) {
  case direction {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

fn move_fn(direction: Direction) {
  case direction {
    North -> matrix.go_n
    East -> matrix.go_e
    South -> matrix.go_s
    West -> matrix.go_w
  }
}

fn move_guard(map: matrix.Matrix, pos: matrix.Coord, direction: Direction, visited: set.Set(matrix.Coord)) {
  let move_fn = move_fn(direction)
  let new_pos = move_fn(pos)
  case matrix.get_at_coord(map, new_pos) {
    Ok("#") -> {
      move_guard(map, pos, turn_right(direction), visited)
    }
    Ok(_) -> {
      move_guard(map, new_pos, direction, set.insert(visited, pos))
    }
    Error(_) -> set.insert(visited, pos)
  }
}

pub fn pt_1(input: matrix.Matrix) {
  let assert Ok(initial_pos) = find_guard(input)
  move_guard(input, initial_pos, North, set.new())
  |> set.size
}

pub fn pt_2(input: matrix.Matrix) {
  todo as "part 2 not implemented"
}
