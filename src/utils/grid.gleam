import gleam/list
import gleam/map.{type Map as Dict} as dict
import gleam/string
import utils/position.{type Position, Position}

pub type Grid(a) {
  Grid(rows: Int, cols: Int, grid: Dict(Position, a))
}

pub fn from(input: String, with fun: fn(String) -> Result(a, Nil)) -> Grid(a) {
  let rows = string.split(input, on: "\n")
  let initial = Grid(0, 0, dict.new())
  use grid, row, row_index <- list.index_fold(over: rows, from: initial)
  let cells = string.to_graphemes(row)
  use grid, cell, col_index <- list.index_fold(over: cells, from: grid)
  case fun(cell) {
    Ok(a) ->
      dict.insert(grid.grid, Position(row_index + 1, col_index + 1), a)
      |> Grid(row_index + 1, col_index + 1, _)
    Error(_) -> Grid(row_index + 1, col_index + 1, grid.grid)
  }
}

pub fn in_bounds(grid: Grid(a), position: Position) -> Bool {
  let Position(row, col) = position
  row >= 1 && row <= grid.rows && col >= 1 && col <= grid.cols
}
