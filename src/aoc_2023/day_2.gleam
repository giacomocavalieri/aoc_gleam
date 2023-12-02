import gleam/int
import gleam/list
import gleam/string

// --- TYPES -------------------------------------------------------------------

type Game {
  Game(id: Int, pulls: List(Pull))
}

type Pull {
  Pull(red: Int, green: Int, blue: Int)
}

// --- INPUT PARSING -----------------------------------------------------------

fn parse(input: String) -> List(Game) {
  string.split(input, on: "\n")
  |> list.map(parse_game)
}

fn parse_game(raw_game: String) -> Game {
  let assert "Game " <> raw_game = raw_game
  let assert [raw_id, raw_pulls] = string.split(raw_game, on: ": ")
  let assert Ok(id) = int.parse(raw_id)
  Game(id, parse_pulls(raw_pulls))
}

fn parse_pulls(raw_pulls: String) -> List(Pull) {
  string.split(raw_pulls, on: "; ")
  |> list.map(parse_pull)
}

fn parse_pull(raw_pull: String) -> Pull {
  let raw_cubes =
    string.split(raw_pull, on: ", ")
    |> list.map(string.split(_, on: " "))
  use pull, [raw_number, raw_color] <- list.fold(raw_cubes, Pull(0, 0, 0))
  let assert Ok(number) = int.parse(raw_number)
  case raw_color {
    "red" -> Pull(..pull, red: number)
    "green" -> Pull(..pull, green: number)
    "blue" -> Pull(..pull, blue: number)
    _else -> panic as "unreachable"
  }
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(input: String) {
  let initial_configuration = Pull(red: 12, green: 13, blue: 14)
  let games = parse(input)

  use id_sum, game <- list.fold(over: games, from: 0)
  case is_valid_game(game, initial_configuration) {
    True -> id_sum + game.id
    False -> id_sum
  }
}

fn is_valid_game(game: Game, cubes: Pull) -> Bool {
  use Pull(red, green, blue) <- list.all(in: game.pulls)
  red <= cubes.red && green <= cubes.green && blue <= cubes.blue
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(input: String) {
  use power_sum, game <- list.fold(over: parse(input), from: 0)
  power_sum + power(minimum_required_cubes(game))
}

fn power(pull: Pull) -> Int {
  pull.red * pull.green * pull.blue
}

fn minimum_required_cubes(game: Game) -> Pull {
  use acc, pull <- list.fold(game.pulls, Pull(0, 0, 0))
  Pull(
    red: int.max(acc.red, pull.red),
    green: int.max(acc.green, pull.green),
    blue: int.max(acc.blue, pull.blue),
  )
}
