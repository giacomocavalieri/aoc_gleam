import gleam/float
import gleam/int
import gleam/list
import gleam/string
import utils/numbers
import utils/range

// --- TYPES -------------------------------------------------------------------

type Race {
  Race(duration: Int, record_distance: Int)
}

// --- INPUT PARSING -----------------------------------------------------------

fn parse(input: String) -> List(Race) {
  let assert ["Time:" <> raw_times, "Distance:" <> raw_distances] =
    string.split(input, on: "\n")

  numbers.parse(raw_times, separator: " ")
  |> list.zip(numbers.parse(raw_distances, separator: " "))
  |> list.map(fn(pair) { Race(pair.0, pair.1) })
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(input: String) {
  solve(parse(input))
}

fn solve(races: List(Race)) -> Int {
  list.map(races, ways_to_beat_record_distance)
  |> int.product
}

fn ways_to_beat_record_distance(race: Race) -> Int {
  let Race(duration: t, record_distance: r) = race
  let assert Ok(delta) = int.square_root(t * t - 4 * r)
  let x_1 =
    { int.to_float(t) -. delta }
    /. 2.0
    |> float.floor
    |> float.truncate
    |> int.add(1)
    |> int.max(0)

  let x_2 =
    { int.to_float(t) +. delta }
    /. 2.0
    |> float.ceiling
    |> float.truncate
    |> int.add(-1)
    |> int.min(t)

  range.size(range.from(x_1, x_2))
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(input: String) {
  string.replace(in: input, each: " ", with: "")
  |> parse
  |> solve
}
