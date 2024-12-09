import gleam/float
import gleam/int
import gleam/list
import gleam/pair
import gleam/string

pub type Block {
  DataBlock(position: Int, size: Int, id: Int)
  FreeBlock(position: Int, size: Int)
}

pub fn parse(input: String) {
  input
  |> string.to_graphemes()
  |> list.index_fold(#(0, #([], [])), fn(acc, val, idx) {
    let #(position, #(data_blocks, free_blocks)) = acc
    case idx % 2 {
      0 -> {
        let assert Ok(block_size) = int.parse(val)
        #(position + block_size, #(
          [
            DataBlock(position: position, size: block_size, id: idx / 2),
            ..data_blocks
          ],
          free_blocks,
        ))
      }
      _ -> {
        let assert Ok(block_size) = int.parse(val)
        case block_size {
          0 -> #(position + block_size, #(data_blocks, free_blocks))
          _ -> #(
            position + block_size,
            #(data_blocks, [
              FreeBlock(position: position, size: block_size),
              ..free_blocks
            ]),
          )
        }
      }
    }
  })
  |> pair.second
  |> pair.map_second(list.reverse)
}

fn squeeze_blocks(acc: #(List(Block), List(Block)), block: Block) {
  let assert DataBlock(position, size, id) = block
  let #(processed_blocks, free_blocks) = acc
  case free_blocks {
    [] -> #([block, ..processed_blocks], free_blocks)
    [free_block, ..rest] if free_block.position > position -> #(
      [block, ..processed_blocks],
      rest,
    )
    [free_block, ..rest] if free_block.size < size ->
      squeeze_blocks(
        #(
          [
            DataBlock(
              size: free_block.size,
              id: id,
              position: free_block.position,
            ),
            ..processed_blocks
          ],
          rest,
        ),
        DataBlock(position: position, size: size - free_block.size, id: id),
      )
    [free_block, ..rest] if free_block.size == size -> #(
      [
        DataBlock(size: free_block.size, id: id, position: free_block.position),
        ..processed_blocks
      ],
      rest,
    )
    [free_block, ..rest] -> #(
      [
        DataBlock(size: size, id: id, position: free_block.position),
        ..processed_blocks
      ],
      [
        FreeBlock(
          size: free_block.size - size,
          position: free_block.position + size,
        ),
        ..rest
      ],
    )
  }
}

fn checksum(block: Block) {
  let assert DataBlock(position, size, id) = block
  let n = size
  let a = position
  let l = position + size - 1
  let s = float.truncate(int.to_float(n) /. 2.0 *. int.to_float(a + l))
  s * id
}

pub fn pt_1(input: #(List(Block), List(Block))) {
  let #(data_blocks, initial_free_blocks) = input
  data_blocks
  |> list.fold(#([], initial_free_blocks), squeeze_blocks)
  |> pair.first
  |> list.map(checksum)
  |> int.sum
}

fn move_to_free_block(
  block: Block,
  free_blocks: List(Block),
  skipped_blocks: List(Block),
) {
  case free_blocks {
    [] -> #(block, skipped_blocks |> list.reverse)
    [free_block, ..rest]
      if free_block.size > block.size && free_block.position < block.position
    -> {
      let assert DataBlock(_, size, id) = block
      #(
        DataBlock(position: free_block.position, size: size, id: id),
        skipped_blocks
          |> list.reverse
          |> list.append([
            FreeBlock(
              position: free_block.position + size,
              size: free_block.size - size,
            ),
            ..rest
          ]),
      )
    }
    [free_block, ..rest]
      if free_block.size == block.size && free_block.position < block.position
    -> {
      let assert DataBlock(_, size, id) = block
      #(
        DataBlock(position: free_block.position, size: size, id: id),
        skipped_blocks |> list.reverse |> list.append(rest),
      )
    }
    [free_block, ..rest] -> {
      move_to_free_block(block, rest, [free_block, ..skipped_blocks])
    }
  }
}

pub fn pt_2(input: #(List(Block), List(Block))) {
  let #(data_blocks, initial_free_blocks) = input
  data_blocks
  |> list.fold(#([], initial_free_blocks), fn(acc, block) {
    let #(data_blocks, free_blocks) = acc
    let #(new_block, new_free_blocks) =
      move_to_free_block(block, free_blocks, [])
    #([new_block, ..data_blocks], new_free_blocks)
  })
  |> pair.first
  |> list.map(checksum)
  |> int.sum
}
