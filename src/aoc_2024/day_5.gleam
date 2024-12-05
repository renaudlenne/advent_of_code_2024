import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import gleam/yielder

pub type Input {
  Input(rules: List(#(Int, Int)), updates: List(List(Int)))
}

fn parse_rule(line: String) {
  let assert [part1, part2] = string.split(line, "|")
  let assert Ok(val1) = int.parse(part1)
  let assert Ok(val2) = int.parse(part2)
  #(val1, val2)
}

fn parse_update(line: String) {
  line
  |> string.split(",")
  |> list.map(fn(str_val) {
    let assert Ok(val) = int.parse(str_val)
    val
  })
}

pub fn parse(input: String) {
  input
  |> string.split("\n")
  |> list.fold(#(True, [], []), fn(acc, line) {
    let #(before_split, rules, updates) = acc
    case before_split {
      True if line == "" -> #(False, rules, updates)
      True -> {
        let rule = parse_rule(line)
        #(before_split, [rule, ..rules], updates)
      }
      _ -> {
        let update = parse_update(line)
        #(before_split, rules, [update, ..updates])
      }
    }
  })
  |> fn(val) {
    let #(_, rules, updates) = val
    Input(rules: rules, updates: updates)
  }
}

fn middle_element(l: List(Int)) {
  l
  |> yielder.from_list
  |> yielder.at(list.length(l) / 2)
  |> result.unwrap(0)
}

fn checksum(
  input: Input,
  comparator: fn(List(Int), List(Int)) -> Result(List(Int), Nil),
) {
  input.updates
  |> list.filter_map(fn(update) {
    let sorted =
      update
      |> list.sort(fn(val1, val2) {
        case list.contains(input.rules, #(val1, val2)) {
          True -> order.Lt
          _ -> {
            case list.contains(input.rules, #(val2, val1)) {
              True -> order.Gt
              _ -> order.Eq
            }
          }
        }
      })
    comparator(sorted, update)
  })
  |> list.map(middle_element)
  |> list.reduce(fn(acc, elem) { acc + elem })
  |> result.unwrap(0)
}

pub fn pt_1(input: Input) {
  checksum(input, fn(sorted, update) {
    case sorted == update {
      True -> Ok(update)
      _ -> Error(Nil)
    }
  })
}

pub fn pt_2(input: Input) {
  checksum(input, fn(sorted, update) {
    case sorted != update {
      True -> Ok(sorted)
      _ -> Error(Nil)
    }
  })
}
