class ChessPiece
  attr_accessor :position
  attr_reader :color

  BOARD_START = 0
  BOARD_END = 7
  BOARD_LENGTH = 8

  def initialize(color, position)
    @color = color
    @position = position
  end

  # can_capture?(pieces : ChessPiece[], destination: Position)
  # -------------------
  # Checks if a square contains a piece of opposite color
  def can_capture?(_pieces, _destination)
    destination_piece = _pieces.find { |p| p.position.equals?(_destination) }

    destination_piece != nil && destination_piece.color != self.color
  end

  # Abstract Method(pieces : ChessPiece[], destination: Position)
  # -------------------
  # Determines if another piece is between "self" and destination Position.
  # The pieces array will hold all 32 pieces, including self.
  # A piece of opposite color is not an obstruction if it is at the destination.
  def is_obstructed?(_pieces, _destination)
    raise NotImplementedError, "Must be able to detect obstruction!"
  end

  private

  def inside_board_boundaries?(x, y)
    x <= BOARD_END && x >= BOARD_START && y <= BOARD_END && y >= BOARD_START
  end

  def at_destination?(x, y, destination)
    x == destination.x && y == destination.y
  end

end
