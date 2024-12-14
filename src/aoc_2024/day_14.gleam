import gleam/erlang/process
import gleam/function
import gleam/int
import gleam/list
import gleam/option
import gleam/otp/actor
import gleam/pair
import gleam/regexp
import glerm.{Character, Control, Key}
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
const offset = 7600

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

fn draw_robots(input: #(List(Robot), Int)) {
  let #(robots, frame) = input
  glerm.draw([#(0,0,int.to_string(frame) <> "s")])
  robots
  |> list.map(fn (robot) {
    #(robot.x, robot.y+1, "#")
  })
  |> glerm.draw()
  #(robots, frame+1)
}

pub fn pt_2(input: List(Robot)) {
  let subject = process.new_subject()

  let selector =
    process.new_selector()
    |> process.selecting(subject, function.identity)

  // Create a new screen for our application
  let assert Ok(_) = glerm.enter_alternate_screen()
  // Enable raw mode to allow capturing all input, and free-form
  // output
  let assert Ok(_) = glerm.enable_raw_mode()
  // Also grab mouse events
  let assert Ok(_) = glerm.enable_mouse_capture()

  // Clear the terminal screen
  glerm.clear()
  // Place the cursor at the top-left
  glerm.move_to(0, 0)

  // Start the terminal NIF to begin receiving events
  let assert Ok(_subj) =
    glerm.start_listener(#(move_n_times(input, offset), offset), fn(msg, state) {
      case msg {
        // We need to provide some way for a user to quit the application.
        Key(Character("c"), option.Some(Control)) -> {
          // Turn off some of the things we set above
          let assert Ok(_) = glerm.disable_raw_mode()
          let assert Ok(_) = glerm.disable_mouse_capture()
          // Tell our subject that we are done, which will unblock the
          // `select_forever` below
          process.send(subject, Nil)
          actor.Stop(process.Normal)
        }
        _ -> {
          glerm.clear()
          actor.continue(
            state
            |> draw_robots()
            |> pair.map_first(move_robots)
          )
        }
      }
    })

  // Block until we receive the exit signal from the listener
  process.select_forever(selector)
}
