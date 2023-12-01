import gleam/int
import gleam/list
import gleam/result
import gleam/string

// --- INPUT PARSING -----------------------------------------------------------

fn calibration_value_from_string(line: String) -> List(Int) {
  string.to_graphemes(line)
  |> list.filter_map(int.parse)
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(input: String) {
  solve(parse_pt_1(input))
}

fn parse_pt_1(input: String) -> List(List(Int)) {
  string.split(input, on: "\n")
  |> list.map(calibration_value_from_string)
}

fn first_and_last_digit(digits: List(Int)) -> Result(Int, Nil) {
  [list.first(digits), list.last(digits)]
  |> result.values
  |> int.undigits(10)
  |> result.replace_error(Nil)
}

fn solve(numbers: List(List(Int))) -> Int {
  list.filter_map(numbers, first_and_last_digit)
  |> int.sum
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(input: String) {
  solve(parse_pt_2(input))
}

fn parse_pt_2(input: String) -> List(List(Int)) {
  use line <- list.map(string.split(input, on: "\n"))
  replace_written_digits(line)
  |> calibration_value_from_string
}

fn replace_written_digits(string: String) -> String {
  let rest = string.drop_left(string, 1)
  case string {
    "" -> ""
    "one" <> _ -> "1" <> replace_written_digits(rest)
    "two" <> _ -> "2" <> replace_written_digits(rest)
    "three" <> _ -> "3" <> replace_written_digits(rest)
    "four" <> _ -> "4" <> replace_written_digits(rest)
    "five" <> _ -> "5" <> replace_written_digits(rest)
    "six" <> _ -> "6" <> replace_written_digits(rest)
    "seven" <> _ -> "7" <> replace_written_digits(rest)
    "eight" <> _ -> "8" <> replace_written_digits(rest)
    "nine" <> _ -> "9" <> replace_written_digits(rest)
    _ -> result.unwrap(string.first(string), "") <> replace_written_digits(rest)
  }
}
