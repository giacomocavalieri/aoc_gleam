import utils/direction.{type Direction, Down, Left, Right, Up}

pub type Position {
  Position(row: Int, col: Int)
}

pub fn advance(position: Position, into direction: Direction) -> Position {
  let Position(row, col) = position
  case direction {
    Up -> Position(row - 1, col)
    Down -> Position(row + 1, col)
    Left -> Position(row, col - 1)
    Right -> Position(row, col + 1)
  }
}
