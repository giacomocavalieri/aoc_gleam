import gleam/option.{None, Some}
import gleam/map.{type Map as Dict} as dict

pub fn increment(in dict: Dict(a, Int), key key: a) -> Dict(a, Int) {
  add(add: 1, to: dict, for: key)
}

pub fn add(to dict: Dict(a, Int), for key: a, add value: Int) -> Dict(a, Int) {
  use previous_value <- dict.update(in: dict, update: key)
  case previous_value {
    Some(n) -> n + value
    None -> value
  }
}
