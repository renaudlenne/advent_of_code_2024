import gleam/int
import gleam/list
import gleam/string

pub type Stone {
  Stone(number: Int, digits: List(String))
}

pub fn parse_stone(input: String) {
  let assert Ok(number) = int.parse(input)
  let digits = string.to_graphemes(input)
  Stone(number, digits)
}

pub fn parse(input: String) {
  input
  |> string.split(" ")
  |> list.map(parse_stone)
}

fn remove_leading_zeroes(digits: List(String)) {
  case digits {
    ["0"] -> digits
    ["0", ..rest] -> remove_leading_zeroes(rest)
    _ -> digits
  }
}

fn blink_stone(stone: Stone) {
  let nb_digits = list.length(stone.digits)
  case stone {
    Stone(0, _) -> [Stone(1, ["1"])]
    Stone(_, digits) if nb_digits % 2 == 0 -> {
      let half_digits = nb_digits / 2
      let #(first_half, second_half) = list.split(digits, half_digits)
      [second_half, first_half]
      |> list.map(fn (new_digits) {
        let assert Ok(new_nb) = string.join(new_digits, "") |> int.parse()
        Stone(new_nb, remove_leading_zeroes(new_digits))
      })
    }
    Stone(nb, _) -> {
      let new_nb = nb*2024
      let new_digits = int.to_string(new_nb) |> string.to_graphemes()
      [Stone(new_nb, new_digits)]
    }
  }
}

fn blink(stones: List(Stone), acc: List(Stone)) {
  case stones {
    [] -> acc |> list.reverse()
    [stone, ..rest] -> blink(rest, blink_stone(stone) |> list.append(acc))
  }
}

fn multi_blink(stones: List(Stone), times: Int) {
  case times {
    0 -> stones
    _ -> multi_blink(blink(stones, []), times - 1)
  }
}

fn display_stones(stones: List(Stone)) {
  stones
  |> list.map(fn(stone) { string.join(stone.digits, "") })
  |> string.join(" ")
}

pub fn pt_1(input: List(Stone)) {
  input
  |> multi_blink(25)
  |> list.length()
//  |> display_stones()
}

pub fn pt_2(input: List(Stone)) {
  todo as "part 2 not implemented"
}
