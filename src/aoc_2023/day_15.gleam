import gleam/int
import gleam/list
import gleam/map.{type Map as Dict} as dict
import gleam/option.{None, Some}
import gleam/string

// --- TYPES -------------------------------------------------------------------

type Instruction {
  Remove(label: String)
  Insert(label: String, focal_length: Int)
}

type Box =
  List(#(String, Int))

// --- INPUT PARSING -----------------------------------------------------------

fn parse(input: String) {
  use instruction <- list.map(string.split(input, on: ","))
  case string.ends_with(instruction, "-") {
    True -> Remove(string.drop_right(instruction, up_to: 1))
    False -> {
      let assert [label, raw_focal_length] = string.split(instruction, on: "=")
      let assert Ok(focal_length) = int.parse(raw_focal_length)
      Insert(label, focal_length)
    }
  }
}

// --- PART 1 ------------------------------------------------------------------

pub fn pt_1(input: String) {
  string.split(input, on: ",")
  |> list.map(hash)
  |> int.sum
}

fn hash(string: String) -> Int {
  let chars = string.to_utf_codepoints(string)
  use current_value, codepoint <- list.fold(over: chars, from: 0)
  let ascii_value = string.utf_codepoint_to_int(codepoint)
  { { current_value + ascii_value } * 17 } % 256
}

// --- PART 2 ------------------------------------------------------------------

pub fn pt_2(input: String) {
  parse(input)
  |> run
  |> focusing_power
}

fn focusing_power(boxes: Dict(Int, Box)) {
  use power, box_index, lenses <- dict.fold(boxes, 0)
  use power, #(_, lens_power), lens_index <- list.index_fold(lenses, power)
  power + { box_index + 1 } * { lens_index + 1 } * lens_power
}

fn run(instruction: List(Instruction)) -> Dict(Int, Box) {
  list.fold(instruction, dict.new(), run_single)
}

fn run_single(boxes: Dict(Int, Box), instruction: Instruction) {
  let box_index = hash(instruction.label)
  use box <- dict.update(boxes, update: box_index)
  case box, instruction {
    None, Remove(_) -> []
    None, Insert(label, focal_length) -> [#(label, focal_length)]
    Some(lenses), Insert(label, focal_length) ->
      list.key_set(lenses, label, focal_length)
    Some(lenses), Remove(label) ->
      case list.key_pop(lenses, label) {
        Ok(#(_, new_lenses)) -> new_lenses
        Error(_) -> lenses
      }
  }
}
