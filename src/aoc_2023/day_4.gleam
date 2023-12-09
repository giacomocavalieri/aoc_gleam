import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/map.{type Map as Dict} as dict
import gleam/set.{type Set}
import gleam/string
import utils/int_dict
import utils/numbers
import utils/range

// --- TYPES -------------------------------------------------------------------

type Card {
  Card(id: Int, winning_numbers: Set(Int), actual_numbers: Set(Int))
}

// --- INPUT PARSING -----------------------------------------------------------

fn parse(input: String) -> List(Card) {
  string.split(input, on: "\n")
  |> list.map(parse_card)
}

fn parse_card(line: String) -> Card {
  let assert "Card " <> line = line
  let assert [raw_id, line] = string.split(string.trim(line), on: ":")
  let assert [raw_winning_numbers, raw_actual_numbers] =
    string.split(line, on: "|")

  let assert Ok(id) = int.parse(raw_id)
  let winning_numbers = numbers.parse(raw_winning_numbers, separator: " ")
  let actual_numbers = numbers.parse(raw_actual_numbers, separator: " ")
  Card(id, set.from_list(winning_numbers), set.from_list(actual_numbers))
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(input: String) {
  use values_sum, card <- list.fold(over: parse(input), from: 0)
  values_sum + card_value(card)
}

fn card_value(card: Card) -> Int {
  let matches = count_matches(card)
  use <- bool.guard(when: matches <= 0, return: 0)
  let assert Ok(value) = int.power(2, of: int.to_float(matches - 1))
  float.truncate(value)
}

fn count_matches(card: Card) -> Int {
  card.winning_numbers
  |> set.intersection(card.actual_numbers)
  |> set.size
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(input: String) {
  let cards = parse(input)
  let copies = list.fold(over: cards, from: dict.new(), with: add_copies)
  use total_copies, _, copies <- dict.fold(over: copies, from: 0)
  total_copies + copies
}

fn add_copies(copies: Dict(Int, Int), card: Card) -> Dict(Int, Int) {
  let copies = int_dict.increment(copies, card.id)
  let assert Ok(copies_of_card) = dict.get(copies, card.id)

  let won_cards = range.sized(count_matches(card), from: card.id + 1)
  use copies, won_card <- range.fold(over: won_cards, from: copies)
  int_dict.add(add: copies_of_card, to: copies, for: won_card)
}
