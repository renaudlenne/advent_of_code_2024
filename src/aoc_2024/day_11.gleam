import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/string

fn add_to_stones(stones: dict.Dict(Int, Int), stone: Int, nb_stones: Int) {
  dict.upsert(stones, stone, fn(val) {
    case val {
      option.Some(i) -> i + nb_stones
      option.None -> nb_stones
    }
  })
}

pub fn parse(input: String) {
  input
  |> string.split(" ")
  |> list.filter_map(int.parse)
  |> list.fold(dict.new(), fn(stones, stone) { add_to_stones(stones, stone, 1) })
}

fn blink_stone(
  stone: #(Int, Int),
  stone_map: dict.Dict(Int, List(Int)),
  acc: dict.Dict(Int, Int),
) {
  let #(stone_value, nb_stones) = stone
  case dict.get(stone_map, stone_value) {
    Ok(new_stones) -> {
      #(
        list.fold(new_stones, acc, fn(stones, stone) {
          add_to_stones(stones, stone, nb_stones)
        }),
        stone_map,
      )
    }
    Error(_) -> {
      let str_val = int.to_string(stone_value)
      let value_length = string.length(str_val)
      case value_length % 2 {
        0 -> {
          let half_length = value_length / 2
          let assert Ok(val1) =
            string.drop_end(str_val, half_length) |> int.parse
          let assert Ok(val2) =
            string.drop_start(str_val, half_length) |> int.parse
          let new_acc =
            acc
            |> add_to_stones(val1, nb_stones)
            |> add_to_stones(val2, nb_stones)
          #(new_acc, dict.insert(stone_map, stone_value, [val1, val2]))
        }
        _ -> {
          let new_val = stone_value * 2024
          #(
            add_to_stones(acc, new_val, nb_stones),
            dict.insert(stone_map, stone_value, [new_val]),
          )
        }
      }
    }
  }
}

fn blink(
  stones: List(#(Int, Int)),
  stone_map: dict.Dict(Int, List(Int)),
  acc: dict.Dict(Int, Int),
) {
  case stones {
    [] -> #(acc, stone_map)
    [stone, ..rest] -> {
      let #(new_acc, new_stone_map) = blink_stone(stone, stone_map, acc)
      blink(rest, new_stone_map, new_acc)
    }
  }
}

fn multi_blink(
  stones: dict.Dict(Int, Int),
  times: Int,
  stone_map: dict.Dict(Int, List(Int)),
) {
  case times {
    0 -> stones |> dict.values |> int.sum
    _ -> {
      let #(new_stones, new_stone_map) =
        blink(dict.to_list(stones), stone_map, dict.new())
      multi_blink(new_stones, times - 1, new_stone_map)
    }
  }
}

pub fn pt_1(input: dict.Dict(Int, Int)) {
  input
  |> multi_blink(25, dict.from_list([#(0, [1])]))
}

pub fn pt_2(input: dict.Dict(Int, Int)) {
  input
  |> multi_blink(75, dict.from_list([#(0, [1])]))
}
