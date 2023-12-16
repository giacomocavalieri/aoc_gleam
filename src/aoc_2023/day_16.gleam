import gleam/bool
import gleam/int
import gleam/list
import gleam/map.{type Map as Dict} as dict
import gleam/option.{None, Some}
import gleam/result
import gleam/set.{type Set}
import utils/direction.{type Direction, Down, Left, Right, Up}
import utils/grid.{type Grid, Grid}
import utils/position.{type Position, Position}

// --- TYPES -------------------------------------------------------------------

type Mirror {
  HorizontalSplitter
  VerticalSplitter
  DownwardMirror
  UpwardMirror
}

// --- INPUT PARSING -----------------------------------------------------------

fn parse(input: String) -> Grid(Mirror) {
  use cell <- grid.from(input)
  case cell {
    "/" -> Ok(UpwardMirror)
    "\\" -> Ok(DownwardMirror)
    "|" -> Ok(VerticalSplitter)
    "-" -> Ok(HorizontalSplitter)
    _ -> Error(Nil)
  }
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(input: String) {
  parse(input)
  |> walk(from: Position(1, 1), towards: Right)
  |> dict.size
}

fn walk(
  grid: Grid(Mirror),
  from initial_position: Position,
  towards direction: Direction,
) -> Dict(Position, Set(Direction)) {
  do_walk(grid, dict.new(), initial_position, direction)
}

fn do_walk(
  grid: Grid(Mirror),
  energised: Dict(Position, Set(Direction)),
  from position: Position,
  towards direction: Direction,
) -> Dict(Position, Set(Direction)) {
  let already_energised = already_energised(energised, position, direction)
  use <- bool.guard(when: already_energised, return: energised)
  let energised = energise(energised, position, direction)
  let new_positions = advance_beam(grid, position, direction)
  use energised, #(position, direction) <- list.fold(new_positions, energised)
  do_walk(grid, energised, from: position, towards: direction)
}

fn advance_beam(
  grid: Grid(Mirror),
  from position: Position,
  towards direction: Direction,
) -> List(#(Position, Direction)) {
  let new_directions =
    dict.get(grid.grid, position)
    |> result.map(split_beam(into: _, towards: direction))
    |> result.unwrap([direction])

  use new_direction <- list.filter_map(new_directions)
  let new_position = position.advance(position, into: new_direction)
  case grid.in_bounds(grid, new_position) {
    True -> Ok(#(new_position, new_direction))
    False -> Error(Nil)
  }
}

fn split_beam(
  towards direction: Direction,
  into mirror: Mirror,
) -> List(Direction) {
  case direction, mirror {
    Up, VerticalSplitter
    | Down, VerticalSplitter
    | Left, HorizontalSplitter
    | Right, HorizontalSplitter -> [direction]
    Up, HorizontalSplitter | Down, HorizontalSplitter -> [Left, Right]
    Left, VerticalSplitter | Right, VerticalSplitter -> [Up, Down]
    Up, DownwardMirror | Down, UpwardMirror -> [Left]
    Up, UpwardMirror | Down, DownwardMirror -> [Right]
    Left, DownwardMirror | Right, UpwardMirror -> [Up]
    Right, DownwardMirror | Left, UpwardMirror -> [Down]
  }
}

fn already_energised(
  energised: Dict(Position, Set(Direction)),
  position: Position,
  direction: Direction,
) -> Bool {
  case dict.get(energised, position) {
    Ok(directions) -> set.contains(directions, direction)
    Error(_) -> False
  }
}

fn energise(
  energised: Dict(Position, Set(Direction)),
  position: Position,
  direction: Direction,
) -> Dict(Position, Set(Direction)) {
  use set <- dict.update(energised, position)
  case set {
    Some(set) -> set.insert(set, direction)
    None -> set.from_list([direction])
  }
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(input: String) {
  let grid = parse(input)
  let points = starting_points(grid)
  use max, #(position, direction) <- list.fold(over: points, from: 0)
  let energised = walk(grid, from: position, towards: direction)
  int.max(dict.size(energised), max)
}

fn starting_points(grid: Grid(a)) -> List(#(Position, Direction)) {
  let Grid(rows, cols, _) = grid
  let edges = [
    #(Position(1, 1), Right),
    #(Position(1, 1), Down),
    #(Position(rows, 1), Right),
    #(Position(rows, 1), Up),
    #(Position(1, cols), Left),
    #(Position(1, cols), Down),
    #(Position(rows, cols), Left),
    #(Position(rows, cols), Up),
  ]
  let upper_row =
    list.range(2, to: cols - 1)
    |> list.map(fn(col) { #(Position(1, col), Down) })
  let lower_row =
    list.range(2, to: cols - 1)
    |> list.map(fn(col) { #(Position(rows, col), Up) })
  let left_column =
    list.range(2, to: rows - 1)
    |> list.map(fn(row) { #(Position(row, 1), Right) })
  let right_column =
    list.range(2, to: rows - 1)
    |> list.map(fn(row) { #(Position(row, cols), Left) })
  [edges, upper_row, lower_row, left_column, right_column]
  |> list.concat
}
