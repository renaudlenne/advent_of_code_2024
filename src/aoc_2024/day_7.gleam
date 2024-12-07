import gleam/result
import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [target_str, vals_str] = line |> string.split(":")
    let assert Ok(target) = int.parse(target_str)
    let vals =
      vals_str
      |> string.split(" ")
      |> list.filter_map(fn(val_str) { int.parse(val_str) })
    #(target, vals)
  })
}

fn can_match(obj: Int, values: List(Int)) {
  case values {
    [v, .._] if v > obj -> Error(Nil)
    [v] if v == obj -> Ok(obj)
    [v1, v2, ..rest] -> {
      case can_match(obj, [v1*v2, ..rest]) {
        Error(_) -> can_match(obj, [v1+v2, ..rest])
        res -> res
      }
    }
    _ -> Error(Nil)
  }
}

pub fn pt_1(input: List(#(Int, List(Int)))) {
  input
  |> list.filter_map(fn(line) {
    let #(obj, values) = line
    can_match(obj, values)
  })
  |> int.sum
}

fn concat_ints(v1: Int, v2: Int) {
  int.to_string(v1)
  |> string.append(int.to_string(v2))
  |> int.parse()
  |> result.unwrap(0)
}

fn can_match_with_concat(obj: Int, values: List(Int)) {
  case values {
    [v, .._] if v > obj -> Error(Nil)
    [v] if v == obj -> Ok(obj)
    [v1, v2, ..rest] -> {
      case can_match_with_concat(obj, [concat_ints(v1, v2), ..rest]) {
        Error(_) -> {
          case can_match_with_concat(obj, [v1*v2, ..rest]) {
            Error(_) -> can_match_with_concat(obj, [v1+v2, ..rest])
            res -> res
          }
        }
        res -> res
      }
    }
    _ -> Error(Nil)
  }
}

pub fn pt_2(input: List(#(Int, List(Int)))) {
  input
  |> list.filter_map(fn(line) {
    let #(obj, values) = line
    can_match_with_concat(obj, values)
  })
  |> int.sum
}
