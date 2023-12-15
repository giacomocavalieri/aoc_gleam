import gleam/int
import gleam/list
import gleam/string

// --- INPUT PARSING -----------------------------------------------------------

fn parse(input: String) -> #(List(#(Int, Int)), Int) {
  let rows = string.split(input, on: "\n")
  use galaxies, line, row <- list.index_fold(over: rows, from: #([], 0))
  let points = string.to_graphemes(line)
  use #(galaxies, _), point, col <- list.index_fold(points, galaxies)
  case point {
    "#" -> #([#(row, col), ..galaxies], row)
    _ -> #(galaxies, row)
  }
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(input: String) {
  let #(galaxies, size) = parse(input)
  expand(galaxies, size, by: 1)
  |> list.combination_pairs
  |> list.map(fn(pair) { min_distance(pair.0, pair.1) })
  |> int.sum
}

fn min_distance(of one: #(Int, Int), from other: #(Int, Int)) -> Int {
  let #(one_row, one_col) = one
  let #(other_row, other_col) = other
  let horizontal_distance = int.absolute_value(one_col - other_col)
  let vertical_distance = int.absolute_value(one_row - other_row)
  horizontal_distance + vertical_distance
}

fn expand(
  galaxies: List(#(Int, Int)),
  size: Int,
  by n: Int,
) -> List(#(Int, Int)) {
  let empty_columns = empty_columns(galaxies, size)
  let empty_rows = empty_rows(galaxies, size)

  galaxies
  |> expand_around_columns(empty_columns, by: n)
  |> expand_around_rows(empty_rows, by: n)
}

fn expand_around_columns(
  galaxies: List(#(Int, Int)),
  columns: List(Int),
  by n: Int,
) -> List(#(Int, Int)) {
  use galaxies, col <- list.fold(over: columns, from: galaxies)
  use #(galaxy_row, galaxy_col) <- list.map(galaxies)
  case galaxy_col >= col {
    True -> #(galaxy_row, galaxy_col + n)
    False -> #(galaxy_row, galaxy_col)
  }
}

fn empty_columns(galaxies: List(#(Int, Int)), size: Int) -> List(Int) {
  use col <- list.filter(list.range(size, 0))
  let galaxies_in_col = list.filter(galaxies, fn(pair) { pair.1 == col })
  list.is_empty(galaxies_in_col)
}

fn expand_around_rows(
  galaxies: List(#(Int, Int)),
  rows: List(Int),
  by n: Int,
) -> List(#(Int, Int)) {
  use galaxies, row <- list.fold(over: rows, from: galaxies)
  use #(galaxy_row, galaxy_col) <- list.map(galaxies)
  case galaxy_row >= row {
    True -> #(galaxy_row + n, galaxy_col)
    False -> #(galaxy_row, galaxy_col)
  }
}

fn empty_rows(galaxies: List(#(Int, Int)), size: Int) -> List(Int) {
  use row <- list.filter(list.range(size, 0))
  let galaxies_in_row = list.filter(galaxies, fn(pair) { pair.0 == row })
  list.is_empty(galaxies_in_row)
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(input: String) {
  let #(galaxies, size) = parse(input)
  expand(galaxies, size, by: 999_999)
  |> list.combination_pairs
  |> list.map(fn(pair) { min_distance(pair.0, pair.1) })
  |> int.sum
}
