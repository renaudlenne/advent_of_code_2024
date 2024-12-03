import gleam/int
import gleam/option
import gleam/list
import gleam/regexp

fn do_mul(match: regexp.Match) {
  let assert [option.Some(a_str), option.Some(b_str)] = match.submatches
  let assert Ok(a) = int.parse(a_str)
  let assert Ok(b) = int.parse(b_str)
  a*b
}

pub fn pt_1(input: String) {
  let assert Ok(re) = regexp.from_string("mul\\((\\d+),(\\d+)\\)")
  let assert Ok(res) = regexp.scan(re, input)
  |> list.map(do_mul)
  |> list.reduce(fn (acc, val) { acc + val })
  res
}

pub fn pt_2(input: String) {
  let assert Ok(re) = regexp.from_string("don't\\(\\)|do\\(\\)|mul\\((\\d+),(\\d+)\\)")
  let #(_, processed_list) = regexp.scan(re, input)
  |> list.map_fold(True, fn(enabled, match) {
    case match.content {
      "don't()" -> #(False, 0)
      "do()" -> #(True, 0)
      _ if enabled -> #(enabled, do_mul(match))
      _ -> #(enabled, 0)
    }
  })
  let assert Ok(res) = processed_list
  |> list.reduce(fn (acc, val) { acc + val })
  res
}
