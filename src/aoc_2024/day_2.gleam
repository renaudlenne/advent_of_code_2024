import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    string.split(line, " ")
    |> list.filter_map(fn(val_str) { int.parse(val_str) })
  })
}

fn is_safe(list: List(Int), can_skip: Bool) {
  is_safely_asc(list, can_skip)
  || is_safely_desc(list, can_skip)
  || {
    can_skip
    && {
      let assert [_, ..rest] = list
      is_safely_asc(rest, False) || is_safely_desc(rest, False)
    }
  }
}

fn is_safely_desc(list: List(Int), can_skip: Bool) {
  case list {
    [_, _] if can_skip -> True
    [a, b] -> a > b && a - b < 4
    [a, b, c, ..rest] -> {
      { a > b && a - b < 4 && is_safely_desc([b, c, ..rest], can_skip) }
      || {
        can_skip
        && {
          is_safely_desc([a, c, ..rest], False)
          || is_safely_desc([a, b, ..rest], False)
        }
      }
    }
    _ -> False
  }
}

fn is_safely_asc(list: List(Int), can_skip: Bool) {
  case list {
    [_, _] if can_skip -> True
    [a, b] -> a < b && b - a < 4
    [a, b, c, ..rest] -> {
      { a < b && b - a < 4 && is_safely_asc([b, c, ..rest], can_skip) }
      || {
        can_skip
        && {
          is_safely_asc([a, c, ..rest], False)
          || is_safely_asc([a, b, ..rest], False)
        }
      }
    }
    _ -> False
  }
}

pub fn pt_1(input: List(List(Int))) {
  input
  |> list.map(fn(line) { is_safe(line, False) })
  |> list.count(fn(safe_val) { safe_val })
}

pub fn pt_2(input: List(List(Int))) {
  input
  |> list.map(fn(line) { is_safe(line, True) })
  |> list.count(fn(safe_val) { safe_val })
}
