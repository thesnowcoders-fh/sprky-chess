class GamesController < ApplicationController
  before_action :authenticate_player!, only: [:new, :create, :update]

  helper_method :get_piece_at

  def new
    @game = Game.new
  end

  def create
    @game = Game.create(game_params)
    if @game.valid?
      @game.created!
      redirect_to game_board_path(@game)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @games = Game.all
  end

  def board
    @game = current_game

    @current_player_color = current_player_color(@game)

    pieces = StartingPositions::STARTING_POSITIONS
    @after_move_pieces = PieceMover.apply_moves(pieces, @game.moves)

    player_color = @current_player_color == "Black" ? :black : :white
    @is_in_check = PieceMover.is_in_check(player_color, @after_move_pieces)

    black_capture_area_pos = Position.new_from_int(Position::BLACK_CAPTURE_INT)
    white_capture_area_pos = Position.new_from_int(Position::WHITE_CAPTURE_INT)

    @black_captured_pieces = @after_move_pieces.select { |piece| piece.position.equals?(black_capture_area_pos) }
    @white_captured_pieces = @after_move_pieces.select { |piece| piece.position.equals?(white_capture_area_pos) }

    @black_player = black_player
    @white_player = white_player

    @player_turn = player_turn(current_game)

    @opposite_player = opposite_player(current_game)
    @opposite_player_color = opposite_color(@current_player_color)

    @winner_id = nil
    if @game.player_1_won?
      @winner_id = @game.player_1_id
    elsif @game.player_2_won?
      @winner_id = @game.player_2_id
    end

  end

  def black_player
    player_1_black? ? find_player_1 : find_player_2
  end

  def white_player #### FIX
    player_1_white? ? find_player_1 : find_player_2
  end

  def available
    @games = Game.available
  end

  def update
    color = opposite_color(current_game.player_1_color)
    current_game.update_attributes(player_2_id: current_player.id)
    current_game.update_attributes(player_2_color: color)
    if current_game.save
      current_game.started!
      redirect_to game_board_path(current_game), notice: "Welcome! Let the game begin!"
      ActionCable.server.broadcast  "game-#{current_game.id}",
                                    event: 'JOINED_GAME',
                                    player: current_player,
                                    game: current_game,
                                    color: color,
                                    message: "#{@current_player.email} has joined the game"
      # head :ok
    else
      render :available, status: :unauthorized
    end
  end

  # x in [0, 7]
  # y in [0, 7]
  def get_piece_at(x, y)
    # returns nil if no piece @ position
    # starting_positions = StartingPositions::STARTING_POSITIONS
    positions = @after_move_pieces
    positions.each do |piece|
      return piece if piece.position.x == x && piece.position.y == y
    end
    nil
  end

  def player_turn(current_game)
    current_game.moves.count.even? ? "White" : "Black"
  end

  private

  def game_params
    params.require(:game).permit(:name, :player_1_color, :player_2_id, :player_2_color).merge(player_1_id: current_player.id)
  end

  def current_game
    @current_game ||= Game.find(params[:id])
  end

  def opposite_color(color)
    if color == "Black"
      "White"
    elsif color == "White"
      "Black"
    end
  end

  def player_info(color)
    color
  end

  def current_player_color(current_game)
    if current_player && current_player.id == current_game.player_1_id
      current_game.player_1_color
    elsif current_player && current_player.id == current_game.player_2_id
      current_game.player_2_color
    end
  end

  def opposite_player(current_game)
    return unless (current_game.started? || current_game.player_1_won? || current_game.player_2_won?) && current_player
    opp_player = current_player.id == current_game.player_1_id ? current_game.player_2_id : current_game.player_1_id
    Player.find(opp_player)
  end

  def player_1_email
    Player.find(current_game.player_1_id).email
  end

  def player_2_email
    current_game.player_2_id.nil? ? "(no opponent has joined yet)" : Player.find(current_game.player_2_id).email
  end

  def player_1_black?
    @current_game.player_1_color == "Black"
  end

  def player_1_white?
    @current_game.player_1_color == "White"
  end

  def current_player_player_1?
    current_player.id == @current_game.player_1_id
  end

  def current_player_player_2?
    current_player.id == @current_game.player_2_id
  end

  def find_player_1
    Player.find_by(id: @current_game.player_1_id)
  end

  def find_player_2
    Player.find_by(id: @current_game.player_2_id)
  end
end
