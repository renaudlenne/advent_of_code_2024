import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/string

pub fn parse(input: String) {
  let assert Ok(re) = regexp.from_string("^(\\d+) +(\\d+)$")

  string.split(input, "\n")
  |> list.fold(#([], []), fn(acc, line) {
    let #(l_list, r_list) = acc
    let assert [match] = regexp.scan(re, line)
    let assert [option.Some(left_str), option.Some(right_str)] =
      match.submatches
    let assert Ok(left) = int.parse(left_str)
    let assert Ok(right) = int.parse(right_str)
    #([left, ..l_list], [right, ..r_list])
  })
}

pub fn pt_1(input: #(List(Int), List(Int))) {
  let #(l_list, r_list) = input
  let l_sorted = list.sort(l_list, by: int.compare)
  let r_sorted = list.sort(r_list, by: int.compare)
  let #(result, _) =
    list.fold(l_sorted, #(0, r_sorted), fn(acc, left) {
      let #(result, current_r_list) = acc
      case current_r_list {
        [] -> acc
        [right] -> #(result + int.absolute_value(left - right), [])
        [right, ..next_r_list] -> #(
          result + int.absolute_value(left - right),
          next_r_list,
        )
      }
    })
  result
}

pub fn pt_2(input: #(List(Int), List(Int))) {
  let #(l_list, r_list) = input
  let frequencies =
    list.group(r_list, fn(val) { val })
    |> dict.map_values(fn(_, val) { list.length(val) })
  list.fold(l_list, 0, fn(acc, l_val) {
    let val_freq = case dict.get(frequencies, l_val) {
      Ok(v) -> v
      Error(Nil) -> 0
    }
    acc + l_val * val_freq
  })
}
