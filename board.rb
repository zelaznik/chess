require 'colorize'
require_relative 'cursor'
require_relative 'pieces'
require_relative 'custom_exceptions'
require 'byebug'

class Board
  ROW_CT = 8
  COL_CT = 8

  OPPONENT = {:red => :black, :black => :red}.freeze

  include Enumerable

  def add_commoners(color, flip)
    #Adds all of the pieces except the queen and king

    if flip
      pos = Proc.new {|r,c| [(ROW_CT - 1 - r), c]}
    else
      pos = Proc.new {|r,c| [r,c]}
    end

    # add_pawns
    (0...COL_CT).each do |c|
      row, col = pos.call(1,c)
      self[row, col] = Pawn.new(self, row, col, color)
    end

    #add bishops
    [[0,2], [0,5]].each do |r, c|
      row, col = pos.call(r, c)
      self[row, col] = Bishop.new(self, row, col, color)
    end

    #add knights
    [[0,1],[0,6]].each do |r, c|
      row, col = pos.call(r,c)
      self[row, col] = Knight.new(self, row, col, color)
    end

    #add rooks
    [[0,0], [0,7]].each do |r, c|
      row, col = pos.call(r, c)
      self[row, col] = Rook.new(self, row, col, color)
    end

  end

  def add_royalty
    self[0, 3] = Queen.new(self, 0, 3, :black)
    self[0, 4] = King.new(self,  0, 4, :black)
    self[7, 3] = Queen.new(self, 7, 3, :red)
    self[7, 4] = King.new(self,  7, 4, :red)
  end

  def create_blank_grid
    @grid = (0...ROW_CT).map {|r| (0...COL_CT).map {|c| EmptySquare.new(self, r, c)}}
  end

  def initialize(game, previous_state = nil)
    @game = game
    @cursor = Cursor.new(self, ROW_CT-1, 0)
    @transaction_in_progress = false

    if previous_state
      # Used when making a deep duplicate of the board
      @grid = previous_state.map do |row|
        row.map do |state|
          state.type.new(self, *state.args)
        end
      end

    else
      create_blank_grid
      add_commoners(:black, false)
      add_commoners(:red, true)
      add_royalty

    end
  end

  def current_player
    game.current_player
  end

  def render
    system('clear')
    grid.each_with_index do |row, r|
      string = ""
      row.each_with_index do |square, c|
        string << square.to_s.colorize(:background=> color(r,c))
      end
      puts string
    end

    if in_check?(current_player.color)
      if checkmate?(current_player.color)
        puts "Checkmate: #{current_player.name}"
      else
        puts "You're in check: #{current_player.name}"
      end

    else
      puts "Your move, #{current_player.name} "

    end

  end

  def in_range?(row, col)
    (row.between?(0, ROW_CT - 1) && col.between?(0, COL_CT - 1))
  end

  def each
    grid.each do |row|
      row.each do |square|
        yield square
      end
    end
  end

  def transaction_in_progress?
    @transaction_in_progress
  end

  def move(start_pos, end_pos, check_if_in_check = true, commit_flag = true)
    if transaction_in_progress?
      raise "Cannot start a move before completing transaction."
    end

    if self[*start_pos].color != current_player.color
      raise IllegalMove
    end

    if check_if_in_check
      valid_moves = self[*start_pos].available_moves
    else
      valid_moves = self[*start_pos].available_moves_could_be_in_check
    end

    unless valid_moves.include?(end_pos)
      raise IllegalMove
    end

    # Make a pending move.  Then ensure the current
    # the player would not be in check.
    # If it is, go back in time, then raise an error
    move_pending(start_pos, end_pos)
    if in_check?(current_player.color)
      rollback
      raise IllegalMove
    elsif commit_flag
      commit
    else
      rollback
    end

    true
  end

  def move_pending(start_pos, end_pos)
    @transaction_in_progress = true
    @start_piece = self[*start_pos].dup
    @end_piece = self[*end_pos].dup

    #Attempt to move the piece
    self[*end_pos] = self[*start_pos]
    self[*end_pos].flag_as_moved
    self[*start_pos].pos = end_pos
    self[*start_pos] = EmptySquare.new(self, *start_pos)
  end

  def rollback
    unless @transaction_in_progress
      raise "No current transaction to roll back."
    end

    self[*start_piece.pos] = start_piece
    self[*end_piece.pos] = end_piece
    @transaction_in_progress = false
  end

  def commit
    @start_piece = nil
    @end_piece = nil
    @transaction_in_progress = false
  end

  attr_reader :grid, :cursor, :game, :start_piece, :end_piece

  def [](row, col)
    @grid[row][col]
  end

  def []=(row, col, value)
    @grid[row][col] = value
  end

  def color(row, col)
    if cursor.pending_pos?(row, col)
      :yellow
    elsif cursor.current_pos?(row, col)
      :yellow
    elsif self[cursor.row, cursor.col].available_moves.include?([row, col])
      :blue
    elsif (row+col).even?
      :red
    else
      :black
    end
  end

  def browse
    @cursor.browse
  end

  def teammates(color)
    self.select {|sq| sq.color == color}
  end

  def opponents(color)
    self.select {|sq| sq.color == OPPONENT[color]}
  end

  def king(color)
    kings = (teammates(color).select {|sq| sq.is_a?(King)})
    kings.first.pos
  end

  def rooks(color)
    teammates(color).select {|sq| sq.is_a?(Rook)}
  end

  def in_check?(color)
    opponents(color).any? {|sq| sq.available_moves_could_be_in_check.include?(king(color))}
  end

  def checkmate?(color)
    if !in_check?(color)
      return false
    end

    teammates(color).each do |piece|
      piece.available_moves.each do |ending_pos|
        begin
          if move(piece.pos, ending_pos, check_if_in_check = false, commit_flag = false)
            return false
          end

        rescue IllegalMove
          next
        end

      end # Next move
    end # Next piece

    true
  end

end

if __FILE__ == $0
  b = Board.new
  b.browse
end
