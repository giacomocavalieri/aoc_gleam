import gleam/list

pub opaque type Range {
  Range(start: Int, end: Int)
  Empty
}

pub fn sized(size: Int, from start: Int) -> Range {
  case size <= 0 {
    True -> Empty
    False -> Range(start, end: start + size - 1)
  }
}

pub fn fold(over range: Range, from acc: a, with fun: fn(a, Int) -> a) -> a {
  case range {
    Empty -> acc
    Range(start, end) -> do_fold(start, end, acc, fun)
  }
}

fn do_fold(start: Int, end: Int, acc: a, fun: fn(a, Int) -> a) -> a {
  case start > end {
    True -> acc
    False -> do_fold(start + 1, end, fun(acc, start), fun)
  }
}

pub fn contains(range: Range, value: Int) -> Bool {
  case range {
    Empty -> False
    Range(start, end) -> start <= value && value <= end
  }
}

pub fn to_list(range: Range) -> List(Int) {
  fold(over: range, from: [], with: fn(acc, n) { [n, ..acc] })
  |> list.reverse
}
