import gleam/dict
import gleam/list
import gleam/option
import gleam/set
import gleam/string
import utils/matrix

pub fn dimensions(input: String) {
  let lines = string.split(input, "\n")
  let assert [first_line, ..] = lines
  #(string.length(first_line), list.length(lines))
}

pub fn parse(input: String) {
  let nodes =
    string.split(input, "\n")
    |> list.index_fold(dict.new(), fn(acc_l, line, y) {
      string.to_graphemes(line)
      |> list.index_fold(acc_l, fn(acc, elem, x) {
        case elem {
          "." -> acc
          node ->
            dict.upsert(acc, node, fn(node_list_opt) {
              case node_list_opt {
                option.None -> [#(x, y)]
                option.Some(coord_list) -> [#(x, y), ..coord_list]
              }
            })
        }
      })
    })
  #(dimensions(input), nodes)
}

fn find_antinodes(
  nodes: List(matrix.Coord),
  map_size: matrix.Coord,
  current_antinodes: set.Set(matrix.Coord),
) {
  nodes
  |> list.combination_pairs()
  |> list.fold(current_antinodes, fn(acc_n, pair) {
    let #(#(x1, y1), #(x2, y2)) = pair
    let diff_x = x2 - x1
    let diff_y = y2 - y1
    let coord1 = #(x1 - diff_x, y1 - diff_y)
    let coord2 = #(x2 + diff_x, y2 + diff_y)
    [coord1, coord2]
    |> list.fold(acc_n, fn(acc, coord) {
      case coord {
        #(x, _) if x < 0 || x >= map_size.0 -> acc
        #(_, y) if y < 0 || y >= map_size.1 -> acc
        _ -> set.insert(acc, coord)
      }
    })
  })
}

pub fn pt_1(input: #(matrix.Coord, dict.Dict(String, List(matrix.Coord)))) {
  let #(map_size, nodes) = input
  nodes
  |> dict.values()
  |> list.fold(set.new(), fn(acc, node_coords) {
    find_antinodes(node_coords, map_size, acc)
  })
  |> set.size
}

fn resonate_nodes(
  resonants: set.Set(matrix.Coord),
  coord: matrix.Coord,
  map_size: matrix.Coord,
  update_fn: fn(matrix.Coord) -> matrix.Coord,
) {
  case update_fn(coord) {
    #(x, _) if x < 0 || x >= map_size.0 -> resonants
    #(_, y) if y < 0 || y >= map_size.1 -> resonants
    new_coord ->
      resonate_nodes(
        set.insert(resonants, new_coord),
        new_coord,
        map_size,
        update_fn,
      )
  }
}

fn find_resonant_antinodes(
  nodes: List(matrix.Coord),
  map_size: matrix.Coord,
  current_antinodes: set.Set(matrix.Coord),
) {
  nodes
  |> list.combination_pairs()
  |> list.fold(current_antinodes, fn(acc, pair) {
    let #(#(x1, y1), #(x2, y2)) = pair
    let diff_x = x2 - x1
    let diff_y = y2 - y1
    resonate_nodes(
      set.insert(acc, pair.0) |> set.insert(pair.1),
      pair.0,
      map_size,
      fn(coord) { #(coord.0 - diff_x, coord.1 - diff_y) },
    )
    |> resonate_nodes(pair.1, map_size, fn(coord) {
      #(coord.0 + diff_x, coord.1 + diff_y)
    })
  })
}

pub fn pt_2(input: #(matrix.Coord, dict.Dict(String, List(matrix.Coord)))) {
  let #(map_size, nodes) = input
  nodes
  |> dict.values()
  |> list.fold(set.new(), fn(acc, node_coords) {
    find_resonant_antinodes(node_coords, map_size, acc)
  })
  |> set.size
}
