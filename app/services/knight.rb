class Knight < ChessPiece

  def is_obstructed?(pieces, destination)
    # Just check if destination is occupied
    pieces.each do |piece|
      if piece.position.equal?(destination)
        return true
      end
    end

    false
  end
end