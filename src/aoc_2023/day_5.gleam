import gleam/int
import gleam/list.{Continue, Stop}
import gleam/string
import utils/numbers
import utils/range.{type Range}

// --- TYPES -------------------------------------------------------------------

type Almanac {
  Almanac(seeds: List(Int), maps: List(List(Conversion)))
}

type Conversion {
  Conversion(source_range: Range, delta: Int)
}

// --- INPUT PARSING -----------------------------------------------------------

fn parse(input: String) -> Almanac {
  let assert "seeds: " <> input = input
  let assert [raw_seeds, ..blocks] = string.split(input, on: "\n\n")
  let seeds = numbers.parse(raw_seeds, separator: " ")
  let maps = list.map(blocks, parse_map)
  Almanac(seeds, maps)
}

fn parse_map(block: String) -> List(Conversion) {
  let assert [_heading, ..lines] = string.split(block, on: "\n")
  use line <- list.map(lines)
  let assert [destination, source, size] = numbers.parse(line, separator: " ")
  Conversion(range.sized(size, from: source), delta: destination - source)
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(input: String) {
  let Almanac(seeds, maps) = parse(input)
  use minimum_location, seed <- list.reduce(seeds)
  let new_location = seed_to_location(seed, maps)
  int.min(new_location, minimum_location)
}

fn seed_to_location(seed: Int, maps: List(List(Conversion))) -> Int {
  list.fold(over: maps, from: seed, with: apply_map_to_source)
}

fn apply_map_to_source(source: Int, conversions: List(Conversion)) -> Int {
  use source, conversion <- list.fold_until(over: conversions, from: source)
  case range.contains(conversion.source_range, source) {
    True -> Stop(source + conversion.delta)
    False -> Continue(source)
  }
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(input: String) {
  let Almanac(seeds, maps) = parse(input)
  let seeds = turn_into_ranges(seeds)

  list.flat_map(seeds, seed_range_to_location_ranges(_, maps))
  |> list.filter_map(range.start)
  |> list.reduce(int.min)
}

fn turn_into_ranges(seeds: List(Int)) -> List(Range) {
  use [start, size] <- list.map(list.sized_chunk(seeds, into: 2))
  range.sized(size, from: start)
}

fn seed_range_to_location_ranges(
  range: Range,
  maps: List(List(Conversion)),
) -> List(Range) {
  use ranges, map <- list.fold(over: maps, from: [range])
  list.flat_map(ranges, apply_map_to_range(_, map))
}

fn apply_map_to_range(
  range: Range,
  conversions: List(Conversion),
) -> List(Range) {
  // This is a bit involved, so a comment is due (and now for the tricky bit):
  // Given a range we need to apply a transformation step:
  //   - the range is first split into smaller bits with the following property:
  //     given a subrange, there's _only one conversion_ that can be applied to
  //     to it
  //   - for each subrange we find the only conversion that can be applied to it
  //   - some subranges could also stay the same and have no relevant
  //     conversions
  //   - once the conversion is found it's just a matter of moving the range
  //     according to its offset
  let splitting_points = splitting_points(conversions)
  let splitted = range.split_all(range, splitting_points)
  use range <- list.map(splitted)
  case find_appropriate_conversion(for: range, among: conversions) {
    Ok(Conversion(_, offset)) -> range.move(range, by: offset)
    Error(_) -> range
  }
}

fn splitting_points(conversions: List(Conversion)) -> List(Int) {
  use Conversion(range, ..) <- list.flat_map(conversions)
  let assert Ok(#(start, end)) = range.to_bounds(range)
  [start, end]
}

fn find_appropriate_conversion(
  for range: Range,
  among conversions: List(Conversion),
) -> Result(Conversion, Nil) {
  use Conversion(source_range, ..) <- list.find(conversions)
  range.overlaps(range, source_range)
}
