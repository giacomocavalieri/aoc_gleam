import gleam/iterator.{type Iterator}
import gleam/list

// --- RANGE TYPE --------------------------------------------------------------

pub opaque type Range {
  Range(start: Int, end: Int)
  Empty
}

// --- BUILDERS ----------------------------------------------------------------

pub fn sized(size: Int, from start: Int) -> Range {
  case size <= 0 {
    True -> Empty
    False -> Range(start, end: start + size - 1)
  }
}

pub fn from(start: Int, to end: Int) -> Range {
  case start > end {
    True -> Empty
    False -> Range(start, end)
  }
}

// --- QUERYING A RANGE --------------------------------------------------------

pub fn is_empty(range: Range) {
  case range {
    Empty -> True
    Range(..) -> False
  }
}

pub fn is_not_empty(range: Range) {
  !is_empty(range)
}

pub fn contains(range: Range, value: Int) -> Bool {
  case range {
    Empty -> False
    Range(start, end) -> start <= value && value <= end
  }
}

pub fn overlaps(range: Range, with other: Range) -> Bool {
  case range, other {
    Empty, _ | _, Empty -> False
    Range(one_start, one_end), Range(other_start, other_end) ->
      contains(range, other_start)
      || contains(range, other_end)
      || contains(other, one_start)
      || contains(other, one_end)
  }
}

// --- ITERATING OVER A RANGE --------------------------------------------------

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

// --- TRANSFORMING RANGES -----------------------------------------------------

pub fn move(range: Range, by offset: Int) -> Range {
  case range {
    Range(start, end) -> Range(start + offset, end + offset)
    Empty -> Empty
  }
}

pub fn split(range: Range, at position: Int) -> List(Range) {
  case range {
    Empty -> [Empty]
    Range(start, end) ->
      case contains(range, position) {
        False -> [range]
        True ->
          [from(start, position), from(position + 1, end)]
          |> list.filter(keeping: is_not_empty)
      }
  }
}

pub fn split_all(range: Range, points: List(Int)) -> List(Range) {
  use ranges, point <- list.fold(over: points, from: [range])
  list.flat_map(ranges, split(_, at: point))
}

// --- CONVERSIONS -------------------------------------------------------------

pub fn to_bounds(range: Range) -> Result(#(Int, Int), Nil) {
  case range {
    Empty -> Error(Nil)
    Range(start, end) -> Ok(#(start, end))
  }
}

pub fn start(range: Range) -> Result(Int, Nil) {
  case range {
    Empty -> Error(Nil)
    Range(start, ..) -> Ok(start)
  }
}

pub fn to_list(range: Range) -> List(Int) {
  fold(over: range, from: [], with: fn(acc, n) { [n, ..acc] })
  |> list.reverse
}

pub fn to_iterator(range: Range) -> Iterator(Int) {
  case range {
    Empty -> iterator.empty()
    Range(start, end) -> iterator.range(from: start, to: end)
  }
}
