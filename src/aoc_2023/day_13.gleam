import gleam/list.{Continue, Stop}
import gleam/string
import utils/list_extra
import utils/range

// --- TYPES -------------------------------------------------------------------

type Symmetry {
  Vertical(row: Int)
  Horizontal(col: Int)
}

type Pattern {
  Pattern(map: List(List(String)), rows: Int, cols: Int)
}

// --- INPUT PARSING -----------------------------------------------------------

fn parse(input: String) -> List(Pattern) {
  use block <- list.map(string.split(input, on: "\n\n"))
  let map = list.map(string.split(block, on: "\n"), string.to_graphemes)
  let assert [first_line, ..] = map
  Pattern(map, rows: list.length(map), cols: list.length(first_line))
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(input: String) {
  let patterns = parse(input)
  use sum, pattern <- list.fold(over: patterns, from: 0)
  case find_symmetry(pattern) {
    [Vertical(col)] -> sum + range.size(range.from(1, to: col))
    [Horizontal(row)] -> sum + 100 * range.size(range.from(1, to: row))
    _ -> panic as "no symmetry!"
  }
}

fn find_symmetry(pattern: Pattern) -> List(Symmetry) {
  [
    list.map(vertical_reflection_line(pattern), Vertical),
    list.map(horizontal_reflection_line(pattern), Horizontal),
  ]
  |> list.concat
}

fn horizontal_reflection_line(pattern: Pattern) -> List(Int) {
  let Pattern(map, rows, cols) = pattern
  vertical_reflection_line(Pattern(list.transpose(map), cols, rows))
}

fn vertical_reflection_line(pattern: Pattern) -> List(Int) {
  let Pattern(map, _, cols) = pattern
  let cols_range = range.from(1, to: cols - 1)
  use cols, col <- range.fold(over: cols_range, from: [])
  case has_vertical_symmetry(map, around: col) {
    True -> [col, ..cols]
    False -> cols
  }
}

fn has_vertical_symmetry(map: List(List(String)), around col: Int) -> Bool {
  let columns = list.transpose(map)
  let #(to_the_left, to_the_right) = list.split(columns, at: col)
  list.zip(to_the_right, list.reverse(to_the_left))
  |> list.all(fn(pair) { pair.0 == pair.1 })
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(input: String) {
  let patterns = parse(input)
  use sum, pattern <- list.fold(over: patterns, from: 0)
  case find_smudge(pattern) {
    Ok(Vertical(col)) -> sum + range.size(range.from(1, to: col))
    Ok(Horizontal(row)) -> sum + 100 * range.size(range.from(1, to: row))
    Error(_) -> panic as "no smudge!"
  }
}

fn find_smudge(pattern: Pattern) -> Result(Symmetry, Nil) {
  let assert [original] = find_symmetry(pattern)
  use _, smudged <- list.fold_until(over: smudge(pattern), from: Error(Nil))
  case list.filter(find_symmetry(smudged), fn(new) { new != original }) {
    [] -> Continue(Error(Nil))
    [new] -> Stop(Ok(new))
  }
}

fn smudge(pattern: Pattern) -> List(Pattern) {
  do_smudge(pattern.map, pattern.rows, pattern.cols)
}

fn do_smudge(map: List(List(String)), rows: Int, cols: Int) -> List(Pattern) {
  let switch = fn(cell) {
    case cell {
      "." -> "#"
      "#" -> "."
    }
  }
  use grids, row <- range.fold(over: range.from(0, to: rows - 1), from: [])
  use grids, col <- range.fold(over: range.from(0, to: cols - 1), from: grids)
  // This is horrible, you should never do that! I couldn't be bothered to find
  // a better way to do it 😁
  let new_map =
    list_extra.update(map, at: row, with: fn(row) {
      list_extra.update(row, at: col, with: switch)
    })
  [Pattern(new_map, rows, cols), ..grids]
}
