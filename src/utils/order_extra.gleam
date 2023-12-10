import gleam/order.{type Order, Eq, Gt, Lt}

pub fn break_tie(comparison: Order, with fun: fn() -> Order) -> Order {
  case comparison {
    Lt | Gt -> comparison
    Eq -> fun()
  }
}
