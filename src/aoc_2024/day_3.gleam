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
  regexp.scan(re, input)
  |> list.fold(0, fn (acc, match) {
    acc + do_mul(match)
  })
}

pub fn pt_2(input: String) {
  let assert Ok(re) = regexp.from_string("do(?:n't)?\\(\\)|mul\\((\\d+),(\\d+)\\)")
  let #(_, res) = regexp.scan(re, input)
  |> list.fold(#(True, 0), fn(acc_tuple, match) {
    let #(enabled, acc) = acc_tuple
    case match.content {
      "don't()" -> #(False, acc)
      "do()" -> #(True, acc)
      _ if enabled -> #(enabled, acc + do_mul(match))
      _ -> #(enabled, acc)
    }
  })
  res
}
