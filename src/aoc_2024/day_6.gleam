import gleam/list
import gleam/set
import glearray
import utils/matrix

pub fn parse(input: String) {
  matrix.parse_matrix(input)
}

fn find_guard(map: matrix.Matrix) {
  map
  |> glearray.to_list
  |> list.index_map(fn(val, idx) { #(val, idx) })
  |> list.find_map(fn(indexed_line) {
    let #(line, y) = indexed_line
    line
    |> glearray.to_list
    |> list.index_map(fn(val, idx) { #(val, idx) })
    |> list.find_map(fn(elem) {
      case elem.0 {
        "." | "#" -> Error(Nil)
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

fn move_guard(
  map: matrix.Matrix,
  pos: matrix.Coord,
  direction: Direction,
  visited: set.Set(matrix.Coord),
) {
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

fn will_loop(
  map: matrix.Matrix,
  pos: matrix.Coord,
  block_pos: matrix.Coord,
  direction: Direction,
  visited: set.Set(#(matrix.Coord, Direction)),
) {
  let move = move_fn(direction)
  let new_pos = move(pos)
  //      io.println("(will_loop) Going to "<>string.inspect(new_pos)<>" facing "<>string.inspect(direction))
  case new_pos == block_pos {
    True -> {
      case set.contains(visited, #(pos, direction)) {
        True -> True
        False ->
          will_loop(
            map,
            pos,
            block_pos,
            turn_right(direction),
            set.insert(visited, #(pos, direction)),
          )
      }
    }
    _ -> {
      case matrix.get_at_coord(map, new_pos) {
        Ok("#") -> {
          case set.contains(visited, #(pos, direction)) {
            True -> True
            False ->
              will_loop(
                map,
                pos,
                block_pos,
                turn_right(direction),
                set.insert(visited, #(pos, direction)),
              )
          }
        }
        Ok(_) -> {
          will_loop(map, new_pos, block_pos, direction, visited)
        }
        Error(_) -> False
      }
    }
  }
}

fn find_loops(
  map: matrix.Matrix,
  pos: matrix.Coord,
  direction: Direction,
  visited: set.Set(matrix.Coord),
  bumped: set.Set(#(matrix.Coord, Direction)),
  possible_blocks: set.Set(matrix.Coord),
) {
  let move = move_fn(direction)
  let new_pos = move(pos)
  //  io.println("Going to "<>string.inspect(new_pos)<>" facing "<>string.inspect(direction))
  case matrix.get_at_coord(map, new_pos) {
    Ok("#") -> {
      find_loops(
        map,
        pos,
        turn_right(direction),
        visited,
        set.insert(bumped, #(pos, direction)),
        possible_blocks,
      )
    }
    Ok("^") -> {
      find_loops(
        map,
        new_pos,
        direction,
        set.insert(visited, pos),
        bumped,
        possible_blocks,
      )
    }
    Ok(_) -> {
      case set.contains(visited, new_pos) {
        True ->
          find_loops(
            map,
            new_pos,
            direction,
            set.insert(visited, pos),
            bumped,
            possible_blocks,
          )
        _ -> {
          case
            will_loop(
              map,
              pos,
              new_pos,
              turn_right(direction),
              set.insert(bumped, #(pos, direction)),
            )
          {
            True ->
              find_loops(
                map,
                new_pos,
                direction,
                set.insert(visited, pos),
                bumped,
                set.insert(possible_blocks, new_pos),
              )
            _ ->
              find_loops(
                map,
                new_pos,
                direction,
                set.insert(visited, pos),
                bumped,
                possible_blocks,
              )
          }
        }
      }
    }
    Error(_) -> set.size(possible_blocks)
  }
}

pub fn pt_2(input: matrix.Matrix) {
  let assert Ok(initial_pos) = find_guard(input)
  find_loops(input, initial_pos, North, set.new(), set.new(), set.new())
}
