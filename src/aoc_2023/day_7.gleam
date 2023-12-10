import gleam/int
import gleam/list
import gleam/map as dict
import gleam/order.{type Order}
import gleam/result
import gleam/string
import utils/list_extra
import utils/order_extra

// --- TYPES -------------------------------------------------------------------

type Card {
  A
  K
  Q
  J
  Number(Int)
}

type Hand =
  List(Card)

type PlayedHand {
  PlayedHand(hand: Hand, bet: Int)
}

type HandType {
  FiveOfAKind
  FourOfAKind
  FullHouse
  ThreeOfAKind
  TwoPair
  OnePair
  HighCard
}

// --- GENERIC HELPERS ---------------------------------------------------------

fn hand_compare(
  one: Hand,
  other: Hand,
  score_hand: fn(Hand) -> HandType,
  score_card: fn(Card) -> Int,
) -> Order {
  let type_comparison = hand_type_compare(score_hand(one), score_hand(other))
  use <- order_extra.break_tie(type_comparison)
  use one_card, other_card <- list_extra.compare(one, other)
  int.compare(score_card(one_card), score_card(other_card))
}

fn hand_type_compare(one: HandType, other: HandType) -> Order {
  let to_int = fn(hand_type) {
    case hand_type {
      FiveOfAKind -> 7
      FourOfAKind -> 6
      FullHouse -> 5
      ThreeOfAKind -> 4
      TwoPair -> 3
      OnePair -> 2
      HighCard -> 1
    }
  }
  int.compare(to_int(one), to_int(other))
}

// --- INPUT PARSING -----------------------------------------------------------

fn parse(input: String) -> List(PlayedHand) {
  use line <- list.map(string.split(input, on: "\n"))
  let [raw_hand, raw_bid] = string.split(line, on: " ")
  let assert Ok(bid) = int.parse(raw_bid)
  PlayedHand(parse_hand(raw_hand), bid)
}

fn parse_hand(input) -> Hand {
  use letter <- list.map(string.to_graphemes(input))
  case letter {
    "A" -> A
    "K" -> K
    "Q" -> Q
    "J" -> J
    "T" -> Number(10)
    _ -> Number(result.unwrap(int.parse(letter), 100))
  }
}

// --- GENERIC SOLUTION --------------------------------------------------------

fn solve(
  input: String,
  score_hand: fn(Hand) -> HandType,
  score_card: fn(Card) -> Int,
) -> Int {
  let sorted_hands = {
    use one, other <- list.sort(parse(input))
    hand_compare(one.hand, other.hand, score_hand, score_card)
  }

  use winnings, hand, index <- list.index_fold(over: sorted_hands, from: 0)
  winnings + hand.bet * { index + 1 }
}

fn card_groups(hand: Hand) -> List(Int) {
  list_extra.counts(hand)
  |> dict.values
  |> list.sort(by: int.compare)
  |> list.reverse
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(input: String) {
  solve(input, score_hand_1, score_card_1)
}

fn score_hand_1(hand: Hand) -> HandType {
  case card_groups(hand) {
    [5] -> FiveOfAKind
    [4, 1] -> FourOfAKind
    [3, 2] -> FullHouse
    [3, 1, 1] -> ThreeOfAKind
    [2, 2, 1] -> TwoPair
    [2, 1, 1, 1] -> OnePair
    [1, 1, 1, 1, 1] -> HighCard
    _ -> panic as "unknown hand"
  }
}

fn score_card_1(card: Card) -> Int {
  case card {
    A -> 14
    K -> 13
    Q -> 12
    J -> 11
    Number(n) -> n
  }
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(input: String) {
  solve(input, score_hand_2, score_card_2)
}

fn score_hand_2(hand: Hand) -> HandType {
  let jollies = list_extra.count_copies(in: hand, of: J)
  case card_groups(hand) {
    [5] -> FiveOfAKind

    [4, 1] ->
      case jollies {
        1 | 4 -> FiveOfAKind
        _ -> FourOfAKind
      }

    [3, 2] ->
      case jollies {
        3 | 2 -> FiveOfAKind
        _ -> FullHouse
      }

    [3, 1, 1] ->
      case jollies {
        3 | 1 -> FourOfAKind
        _ -> ThreeOfAKind
      }

    [2, 2, 1] ->
      case jollies {
        2 -> FourOfAKind
        1 -> FullHouse
        _ -> TwoPair
      }

    [2, 1, 1, 1] ->
      case jollies {
        2 | 1 -> ThreeOfAKind
        _ -> OnePair
      }

    [1, 1, 1, 1, 1] ->
      case jollies {
        1 -> OnePair
        _ -> HighCard
      }

    _ -> panic as "unknown hand"
  }
}

fn score_card_2(card: Card) -> Int {
  case card {
    A -> 14
    K -> 13
    Q -> 12
    J -> 0
    Number(n) -> n
  }
}
