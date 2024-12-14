import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp

pub type Arcade {
  Arcade(a: #(Int, Int), b: #(Int, Int), prize: #(Int, Int))
}

pub fn parse(input: String) {
  let assert Ok(re) =
    regexp.from_string(
      "Button A: X\\+(\\d+), Y\\+(\\d+)\nButton B: X\\+(\\d+), Y\\+(\\d+)\nPrize: X=(\\d+), Y=(\\d+)",
    )
  regexp.scan(re, input)
  |> list.map(fn(match: regexp.Match) {
    let assert [
      option.Some(sxa),
      option.Some(sya),
      option.Some(sxb),
      option.Some(syb),
      option.Some(sxp),
      option.Some(syp),
    ] = match.submatches
    let assert Ok(xa) = int.parse(sxa)
    let assert Ok(ya) = int.parse(sya)
    let assert Ok(xb) = int.parse(sxb)
    let assert Ok(yb) = int.parse(syb)
    let assert Ok(xp) = int.parse(sxp)
    let assert Ok(yp) = int.parse(syp)
    Arcade(#(xa, ya), #(xb, yb), #(xp, yp))
  })
}

fn find_min_buttons(arcade: Arcade, offset: Int) {
  let dn = int.to_float(arcade.a.0 * arcade.b.1 - arcade.a.1 * arcade.b.0)
  let a =
    int.to_float(
      { arcade.prize.0 + offset }
      * arcade.b.1
      - { arcade.prize.1 + offset }
      * arcade.b.0,
    )
    /. dn
  let b =
    int.to_float(
      arcade.a.0
      * { arcade.prize.1 + offset }
      - arcade.a.1
      * { arcade.prize.0 + offset },
    )
    /. dn
  case
    int.to_float(float.truncate(a)) == a,
    int.to_float(float.truncate(b)) == b
  {
    True, True -> Ok(#(float.truncate(a), float.truncate(b)))
    _, _ -> Error(Nil)
  }
}

pub fn pt_1(input: List(Arcade)) {
  input
  |> list.filter_map(fn(a) { find_min_buttons(a, 0) })
  |> list.fold(0, fn(acc, res) {
    case res {
      #(a, b) if a >= 0 && a <= 100 && b >= 0 && b <= 100 -> {
        acc + a * 3 + b
      }
      _ -> acc
    }
  })
}

pub fn pt_2(input: List(Arcade)) {
  input
  |> list.filter_map(fn(a) { find_min_buttons(a, 10_000_000_000_000) })
  |> list.fold(0, fn(acc, res) {
    case res {
      #(a, b) if a >= 0 && b >= 0 -> {
        acc + a * 3 + b
      }
      _ -> acc
    }
  })
}
