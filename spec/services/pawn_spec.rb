require 'rspec'
require 'rails_helper'

RSpec.describe "Pawn" do
  describe 'pawn#is_obstructed' do   # Assuming move is valid

    it 'should determine that a piece is between a pawn and a square' do

      # 0,0,0,0,0,0,0,0
      # 0,0,0,0,0,0,0,0
      # 0,0,0,0,0,0,0,0
      # 0,0,0,D,0,0,0,0 --> Destination is occupied
      # 0,0,0,P,0,0,0,0
      # 0,0,0,0,0,0,0,0
      # 0,0,0,0,0,0,0,0
      # 0,0,0,0,0,0,0,0

      pawn = Pawn.new(3, 3)
      obstructor_piece = ChessPiece.new(3, 4)
      pieces = [pawn, obstructor_piece]
      destination = Position.new(3, 4)
      expect(pawn.is_obstructed?(pieces, destination)).to eq true

    end

    it 'should determine that there is nothing between a pawn and a square' do

      # 0,0,0,0,0,0,0,0
      # 0,0,0,0,0,0,0,0
      # 0,0,0,0,0,0,0,0
      # 0,x,0,0,0,0,0,0
      # 0,x,x,0,0,0,0,0
      # 0,0,x,D,x,0,0,0 --> Destination is unoccupied
      # 0,0,0,P,0,x,0,0
      # 0,0,0,0,0,0,0,0

      # No obstruction
      pawn = Pawn.new(3, 1)
      destination = Position.new(2, 3)
      pieces = [pawn, ChessPiece.new(1, 3), ChessPiece.new(1, 4), ChessPiece.new(2, 2), ChessPiece.new(2, 3),
                ChessPiece.new(3, 3), ChessPiece.new(4, 2), ChessPiece.new(5, 1)]

      expect(pawn.is_obstructed?(pieces, destination)).to eq false
    end
  end
end