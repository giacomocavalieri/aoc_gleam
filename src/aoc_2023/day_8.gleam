import gleam/bool
import gleam/iterator.{type Iterator}
import gleam/list.{Continue, Stop}
import gleam/map.{type Map as Dict} as dict
import gleam/string
import gleam_community/maths/arithmetics

// --- TYPES -------------------------------------------------------------------

type Instruction {
  Left
  Right
}

type Crossroad {
  Crossroad(left: String, right: String)
}

// --- INPUT PARSING -----------------------------------------------------------

fn parse(input: String) -> #(Iterator(Instruction), Dict(String, Crossroad)) {
  let assert [raw_instructions, raw_nodes] = string.split(input, on: "\n\n")
  let instructions = parse_instructions(raw_instructions)
  let crossroads = parse_nodes(raw_nodes)
  #(instructions, crossroads)
}

fn parse_instructions(raw_instructions: String) -> Iterator(Instruction) {
  string.to_graphemes(raw_instructions)
  |> list.map(parse_instruction)
  |> iterator.from_list
  |> iterator.cycle
}

fn parse_instruction(raw_instruction: String) -> Instruction {
  case raw_instruction {
    "L" -> Left
    "R" -> Right
    _ -> panic as "unknown instruction"
  }
}

fn parse_nodes(raw_nodes: String) -> Dict(String, Crossroad) {
  let lines = string.split(raw_nodes, on: "\n")
  use dict, line <- list.fold(over: lines, from: dict.new())
  let [name, raw_crossroad] = string.split(line, on: " = ")
  dict.insert(dict, name, parse_crossroad(raw_crossroad))
}

fn parse_crossroad(raw_crossroad: String) -> Crossroad {
  let raw_crossroad = string.drop_right(string.drop_left(raw_crossroad, 1), 1)
  let [left, right] = string.split(raw_crossroad, on: ", ")
  Crossroad(left, right)
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(input: String) {
  let #(instructions, crossroads) = parse(input)
  let start = #(0, "AAA")

  use #(steps, node), instruction <- iterator.fold_until(instructions, start)
  use <- bool.guard(when: node == "ZZZ", return: Stop(#(steps, node)))
  let new_node = update_node(node, instruction, crossroads)
  Continue(#(steps + 1, new_node))
}

fn update_node(
  node: String,
  instruction: Instruction,
  crossroads: Dict(String, Crossroad),
) -> String {
  let assert Ok(Crossroad(left, right)) = dict.get(crossroads, node)
  case instruction {
    Left -> left
    Right -> right
  }
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(input: String) {
  let #(instructions, crossroads) = parse(input)
  let starting_nodes =
    dict.keys(crossroads)
    |> list.filter(keeping: string.ends_with(_, "A"))

  use least_number_of_steps, node <- list.fold(over: starting_nodes, from: 1)
  let steps = steps_to_reach_node_ending_in_z(node, instructions, crossroads).0
  arithmetics.lcm(least_number_of_steps, steps)
}

fn steps_to_reach_node_ending_in_z(
  from: String,
  instructions: Iterator(Instruction),
  crossroads: Dict(String, Crossroad),
) -> #(Int, String) {
  let start = #(0, from)
  use #(steps, node), instruction <- iterator.fold_until(instructions, start)
  let ends_with_z = string.ends_with(node, "Z")
  use <- bool.guard(when: ends_with_z, return: Stop(#(steps, node)))
  let new_node = update_node(node, instruction, crossroads)
  Continue(#(steps + 1, new_node))
}
