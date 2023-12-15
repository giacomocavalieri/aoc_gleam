import gleam/list
import gleam/map.{type Map as Dict} as dict
import gleam/string
import utils/range
import utils/list_extra

// --- TYPES -------------------------------------------------------------------

type Cell {
  Round
  Cube
  Empty
}

type Grid =
  List(List(Cell))

// --- INPUT PARSING -----------------------------------------------------------

fn parse(input: String) -> Grid {
  use line <- list.map(string.split(input, on: "\n"))
  use raw_cell <- list.map(string.to_graphemes(line))
  case raw_cell {
    "O" -> Round
    "#" -> Cube
    "." -> Empty
  }
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(input: String) {
  parse(input)
  |> rotate_counter_clockwise
  |> tilt_left
  |> rotate_clockwise
  |> total_load
}

fn total_load(grid: Grid) -> Int {
  use load, row, index <- list.index_fold(over: list.reverse(grid), from: 0)
  load + list_extra.count_copies(row, Round) * { index + 1 }
}

fn rotate_clockwise(grid: Grid) -> Grid {
  list.reverse(grid)
  |> list.transpose
}

fn rotate_counter_clockwise(grid: Grid) -> Grid {
  grid
  |> rotate_clockwise
  |> rotate_clockwise
  |> rotate_clockwise
}

fn tilt_left(grid: Grid) -> Grid {
  list.map(grid, tilt_row_left(_, []))
}

fn tilt_row_left(row: List(Cell), current_group: List(Cell)) -> List(Cell) {
  case row {
    [] -> current_group
    [Round, ..rest] -> tilt_row_left(rest, [Round, ..current_group])
    [Empty, ..rest] -> tilt_row_left(rest, list.append(current_group, [Empty]))
    [Cube, ..rest] ->
      list.append(current_group, [Cube, ..tilt_row_left(rest, [])])
  }
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(input: String) {
  let #(initial_loops, loops_to_cycle, grid) =
    parse(input)
    |> rotate_counter_clockwise
    |> find_loop(0, dict.new())

  let remaining_loops = { 1_000_000_000 - initial_loops } % loops_to_cycle
  cycles(grid, for: remaining_loops)
  |> rotate_clockwise
  |> total_load
}

fn find_loop(
  grid: Grid,
  cycles: Int,
  cache: Dict(Grid, Int),
) -> #(Int, Int, Grid) {
  let new_grid = cycle(grid)
  let cycles = cycles + 1
  case dict.get(cache, new_grid) {
    Ok(start) -> #(start, cycles - start, new_grid)
    Error(_) -> {
      let new_cache = dict.insert(cache, new_grid, cycles)
      find_loop(new_grid, cycles, new_cache)
    }
  }
}

fn cycles(grid: Grid, for n: Int) -> Grid {
  use grid, _ <- range.fold(over: range.sized(n, from: 0), from: grid)
  cycle(grid)
}

fn cycle(grid: Grid) -> Grid {
  grid
  |> tilt_left
  |> rotate_clockwise
  |> tilt_left
  |> rotate_clockwise
  |> tilt_left
  |> rotate_clockwise
  |> tilt_left
  |> rotate_clockwise
}
