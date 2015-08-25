require_relative 'board'
require_relative 'custom_exceptions'

class Game
  attr_reader :board, :red_player, :black_player, :players

  def initialize(red_name, black_name, previous_state = nil)
    @board = Board.new(self)
    @red_player = Player.new(red_name, :red, @board)
    @black_player = Player.new(black_name, :black, @board)
    @players = [@red_player, @black_player]
  end

  def deep_dup
    previous_state []
    copy_of_pieces = board.map {|row| row.map {|sq| sq.dup()}}
  end

  def current_player
    @players.first
  end

  def play
    # while true
    until game_over?
      current_player.make_move
      @players.rotate!
    end

    board.render
    puts "Checkmate!!"
  end

  def game_over?
    players.any? { |p| board.checkmate?(p.color) }
  end

end

class Player
  attr_reader :name, :color, :board

  def initialize(name, color, board)
    @name = name
    @color = color
    @board = board
  end

  def make_move
    begin
      start_pos, end_pos = board.browse
      board.move(start_pos, end_pos)
    rescue IllegalMove
      retry
    end
  end

end

if __FILE__ == $0
  g = Game.new("Steve", "Darren")
  g.play
end
