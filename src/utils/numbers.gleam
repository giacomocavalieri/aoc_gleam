import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String, separator separator: String) -> List(Int) {
  string.split(input, on: separator)
  |> list.filter_map(int.parse)
}
