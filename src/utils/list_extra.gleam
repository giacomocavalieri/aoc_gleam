import gleam/list
import gleam/map.{type Map as Dict} as dict
import gleam/order.{type Order, Eq, Gt, Lt}

pub fn counts(list: List(a)) -> Dict(a, Int) {
  list.group(list, fn(x) { x })
  |> dict.map_values(fn(_, list) { list.length(list) })
}

pub fn count_copies(in list: List(a), of item: a) -> Int {
  use copies, a <- list.fold(over: list, from: 0)
  case item == a {
    True -> copies + 1
    False -> copies
  }
}

pub fn compare(
  one: List(a),
  other: List(a),
  with compare_item: fn(a, a) -> Order,
) -> Order {
  case one, other {
    [], [] -> Eq
    [], _ -> Lt
    _, [] -> Gt
    [a, ..rest_a], [b, ..rest_b] ->
      case compare_item(a, b) {
        Eq -> compare(rest_a, rest_b, compare_item)
        Lt -> Lt
        Gt -> Gt
      }
  }
}

pub fn update(list: List(a), at index: Int, with fun: fn(a) -> a) -> List(a) {
  case list.split(list, at: index) {
    #(left, [elem, ..rest]) -> list.append(left, [fun(elem), ..rest])
    #(_, []) -> list
  }
}
