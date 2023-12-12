import gleam/bool
import gleam/list
import gleam/map.{type Map as Dict} as dict
import gleam/result
import gleam/string
import utils/numbers

type ConditionRecord {
  ConditionRecord(springs: String, groups: List(Int))
}

// --- INPUT PARSING -----------------------------------------------------------

fn parse(input: String) {
  use line <- list.map(string.split(input, on: "\n"))
  let assert [chart, raw_groups] = string.split(line, on: " ")
  let groups = numbers.parse(raw_groups, separator: ",")
  ConditionRecord(chart, groups)
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(input: String) {
  parse(input)
  |> solve
}

fn solve(records: List(ConditionRecord)) -> Int {
  use sum, record <- list.fold(over: records, from: 0)
  let #(n, _cache) = arrangements(record.springs, record.groups, dict.new())
  sum + n
}

fn arrangements(
  springs: String,
  groups: List(Int),
  cache: Dict(#(String, List(Int)), Int),
) -> #(Int, Dict(#(String, List(Int)), Int)) {
  let cached = dict.get(cache, #(springs, groups))
  use <- bool.guard(result.is_ok(cached), #(result.unwrap(cached, 0), cache))

  case springs, groups {
    "", [] -> #(1, cache)
    "", _ | "#" <> _, [] -> #(0, cache)

    "#" <> _, [n, ..groups] ->
      case drop_broken_group(springs, n) {
        Ok(springs) -> arrangements(springs, groups, cache)
        Error(_) -> #(0, cache)
      }

    "." <> springs, groups -> arrangements(springs, groups, cache)
    "?" <> springs, groups -> {
      let #(one, cache) = arrangements("." <> springs, groups, cache)
      let cache = dict.insert(cache, #("." <> springs, groups), one)
      let #(other, cache) = arrangements("#" <> springs, groups, cache)
      let cache = dict.insert(cache, #("#" <> springs, groups), other)
      #(one + other, cache)
    }
  }
}

fn drop_broken_group(springs: String, n: Int) -> Result(String, Nil) {
  case n, springs {
    0, "#" <> _ -> Error(Nil)
    0, springs -> Ok(string.drop_left(springs, 1))
    _, "" | _, "." <> _ -> Error(Nil)
    _, "#" <> springs | _, "?" <> springs -> drop_broken_group(springs, n - 1)
  }
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(input: String) {
  parse(input)
  |> list.map(unfold_record)
  |> solve
}

fn unfold_record(record: ConditionRecord) -> ConditionRecord {
  let ConditionRecord(springs, groups) = record
  let unfolded_springs = string.join(list.repeat(springs, 5), with: "?")
  let unfolded_groups = list.concat(list.repeat(groups, 5))
  ConditionRecord(unfolded_springs, unfolded_groups)
}
