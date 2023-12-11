import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/map.{type Map as Dict} as dict
import gleam/set.{type Set}
import gleam/string

// --- TYPES -------------------------------------------------------------------

type Maze =
  Dict(#(Int, Int), String)

type Direction {
  Left
  Right
  Up
  Down
}

// --- CONSTANTS ---------------------------------------------------------------

// These are just eyeballed by looking at my input!

const initial_position = #(69, 88)

const initial_direction = Right

const s_replacement = "F"

// --- INPUT PARSING -----------------------------------------------------------

fn parse(input: String) -> Maze {
  let lines = string.split(input, on: "\n")
  use maze, line, row <- list.index_fold(over: lines, from: dict.new())
  let columns = string.to_graphemes(line)
  use maze, pipe, col <- list.index_fold(over: columns, from: maze)
  let pipe = string.replace(in: pipe, each: "S", with: s_replacement)
  dict.insert(maze, #(row, col), pipe)
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(input: String) {
  let maze = parse(input)
  let loop = find_loop(maze)
  let steps = set.size(loop)

  int.to_float(steps)
  /. 2.0
  |> float.ceiling
  |> float.truncate
}

fn find_loop(maze: Maze) -> Set(#(Int, Int)) {
  do_find_loop(maze, initial_position, initial_direction, set.new())
}

fn do_find_loop(
  maze: Maze,
  position: #(Int, Int),
  direction: Direction,
  loop: Set(#(Int, Int)),
) -> Set(#(Int, Int)) {
  let #(new_position, new_direction) = step(maze, position, direction)
  use <- bool.guard(when: set.contains(loop, new_position), return: loop)
  let new_loop = set.insert(loop, new_position)
  do_find_loop(maze, new_position, new_direction, new_loop)
}

fn step(
  maze: Maze,
  position: #(Int, Int),
  coming_from: Direction,
) -> #(#(Int, Int), Direction) {
  let #(row, col) = position
  let assert Ok(pipe) = dict.get(maze, position)
  case pipe, coming_from {
    "|", Down | "L", Right | "J", Left -> #(#(row - 1, col), Down)
    "|", Up | "7", Left | "F", Right -> #(#(row + 1, col), Up)
    "-", Left | "L", Up | "F", Down -> #(#(row, col + 1), Left)
    "-", Right | "J", Up | "7", Down -> #(#(row, col - 1), Right)
  }
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(input: String) {
  let maze = parse(input)
  let loop = find_loop(maze)

  use cells_inside_loop, cell <- list.fold(over: dict.keys(maze), from: 0)
  case is_inside_loop(cell, loop, maze) {
    True -> cells_inside_loop + 1
    False -> cells_inside_loop
  }
}

fn is_inside_loop(cell: #(Int, Int), loop: Set(#(Int, Int)), maze: Maze) -> Bool {
  let is_not_wall = !set.contains(loop, cell)
  is_not_wall && int.is_odd(cast_ray(cell, loop, maze))
}

fn cast_ray(cell: #(Int, Int), loop: Set(#(Int, Int)), maze: Maze) -> Int {
  // https://en.wikipedia.org/wiki/Point_in_polygon#Ray_casting_algorithm
  let ray = cell_to_diagonal_ray(cell)
  use intersections, #(row, col) <- list.fold(over: ray, from: 0)
  let is_diagonal_edge = case dict.get(maze, #(row, col)) {
    Ok("L") | Ok("7") -> True
    _ -> False
  }
  case !is_diagonal_edge && set.contains(loop, #(row, col)) {
    True -> intersections + 1
    False -> intersections
  }
}

fn cell_to_diagonal_ray(cell: #(Int, Int)) -> List(#(Int, Int)) {
  case cell {
    #(0, _) | #(_, 0) -> []
    #(row, col) -> {
      let previous = #(row - 1, col - 1)
      [previous, ..cell_to_diagonal_ray(previous)]
    }
  }
}
