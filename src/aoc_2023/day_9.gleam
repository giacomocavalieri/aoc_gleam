import gleam/bool
import gleam/int
import gleam/list
import gleam/string
import utils/numbers

// --- INPUT PARSING -----------------------------------------------------------

fn parse(input: String) -> List(List(Int)) {
  string.split(input, on: "\n")
  |> list.map(numbers.parse(_, separator: " "))
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(input: String) {
  parse(input)
  |> list.map(extrapolate_forwards)
  |> int.sum
}

pub fn extrapolate_forwards(list: List(Int)) -> Int {
  let all_zeros = list.all(list, fn(x) { x == 0 })
  use <- bool.guard(when: all_zeros, return: 0)
  let assert Ok(last) = list.last(list)
  extrapolate_forwards(differences(list)) + last
}

pub fn differences(list: List(Int)) -> List(Int) {
  list.window_by_2(list)
  |> list.map(fn(pair) { pair.1 - pair.0 })
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(input: String) {
  parse(input)
  |> list.map(extrapolate_backwards)
  |> int.sum
}

pub fn extrapolate_backwards(list: List(Int)) -> Int {
  let all_zeros = list.all(list, fn(x) { x == 0 })
  use <- bool.guard(when: all_zeros, return: 0)
  let assert [first, ..] = list
  first - extrapolate_backwards(differences(list))
}
