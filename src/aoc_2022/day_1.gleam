import gleam/int
import gleam/list
import gleam/result
import gleam/string

// --- INPUT PARSING -----------------------------------------------------------

fn parse_inventories(input: String) -> List(List(Int)) {
  string.split(input, on: "\n\n")
  |> list.map(parse_inventory)
}

fn parse_inventory(raw_inventory: String) -> List(Int) {
  string.split(raw_inventory, on: "\n")
  |> list.map(int.parse)
  |> result.values
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(raw_inventories: String) {
  parse_inventories(raw_inventories)
  |> list.map(int.sum)
  |> list.reduce(int.max)
  |> result.unwrap(-1)
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(raw_inventories: String) {
  parse_inventories(raw_inventories)
  |> list.map(int.sum)
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> list.reduce(int.add)
  |> result.unwrap(-1)
}
