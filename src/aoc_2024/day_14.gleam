import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import utils/matrix

pub type Robot {
  Robot(x: Int, y: Int, vx: Int, vy: Int)
}

pub fn parse(input: String) {
  let assert Ok(re) =
    regexp.from_string(
      "p=(-?\\d+),(-?\\d+) v=(-?\\d+),(-?\\d+)",
    )
  regexp.scan(re, input)
  |> list.map(fn(match: regexp.Match) {
    let assert [
      option.Some(sx),
      option.Some(sy),
      option.Some(svx),
      option.Some(svy),
    ] = match.submatches
    let assert Ok(x) = int.parse(sx)
    let assert Ok(y) = int.parse(sy)
    let assert Ok(vx) = int.parse(svx)
    let assert Ok(vy) = int.parse(svy)
    Robot(x, y, vx, vy)
  })
}

const nb_cols = 101
const nb_lines = 103

fn move_robots(map: List(Robot)) {
  map
  |> list.map(fn (robot) {
    let assert Ok(x) = int.modulo(robot.x + robot.vx, nb_cols)
    let assert Ok(y) = int.modulo(robot.y + robot.vy, nb_lines)
    Robot(x, y, robot.vx, robot.vy)
  })
}

fn move_n_times(input: List(Robot), nb_times: Int) {
  case nb_times {
    0 -> input
    _ -> move_n_times(move_robots(input), nb_times - 1)
  }
}

fn count_by_quadrants(robots: List(Robot)) {
  let middle_col = nb_cols / 2
  let middle_line = nb_lines / 2
  robots
  |> list.fold(#(0, 0, 0, 0), fn(acc, robot) {
    case robot {
      Robot(x, y, _, _) if x < middle_col && y < middle_line -> #(acc.0 + 1, acc.1, acc.2, acc.3)
      Robot(x, y, _, _) if x > middle_col && y < middle_line -> #(acc.0, acc.1 + 1, acc.2, acc.3)
      Robot(x, y, _, _) if x > middle_col && y > middle_line -> #(acc.0, acc.1, acc.2 + 1, acc.3)
      Robot(x, y, _, _) if x < middle_col && y > middle_line -> #(acc.0, acc.1, acc.2, acc.3 + 1)
      _ -> acc
    }
  })
  |> fn(q) {
    q.0 * q.1 * q.2 * q.3
  }
}

pub fn pt_1(input: List(Robot)) {
  input
  |> move_n_times(100)
  |> count_by_quadrants()
}

pub fn pt_2(input: List(Robot)) {
  todo as "part 2 not implemented"
}
