require 'byebug'
require_relative 'pieces_mixins'

class AbstractPiece
  attr_reader :board, :row, :col, :moved, :color

  def initialize(board, row, col, color)
    @board, @row, @col, @color = board, row, col, color
    @moved = false
  end

  def pos
    [row, col]
  end

  def pos=(new_pos)
    @row, @col = new_pos
  end

  def flag_as_moved
    @moved = true
  end

  def to_s
    symbol
  end

  def inspect
    self.class.name + "(row=#{row}, col=#{col})"
  end

  def available_moves
    return available_moves_could_be_in_check

    valid_moves = []
    possible_moves = available_moves_could_be_in_check
    possible_moves.each do |ending_pos|
      temp_board = board.deep_dup
      temp_board.move(pos, ending_pos, false)
      unless temp_board.in_check?(color)
        valid_moves << ending_pos
      end
    end

    valid_moves
  end

end

class EmptySquare < AbstractPiece

  def initialize(board, row, col)
    super(board, row, col, nil)
  end

  def empty?
    true
  end

  def available_moves_could_be_in_check
    []
  end

  def symbol
    "   "
  end

  def teammate?(color)
    false
  end

  def opponent?(color)
    false
  end

end

class Piece < AbstractPiece
  attr_reader :color

  DISPLAY = {:red => :white, :black => :green}.freeze
  OPPONENT = {:red => :black, :black => :red}.freeze

  def empty?
    false
  end

  def display_color
    DISPLAY[color]
  end

  def teammate?(color)
    color == self.color
  end

  def opponent?(color)
    !teammate?(color)
  end

  def inspect
    self.class.name + "(row=#{row}, col=#{col}, color=#{color})"
  end

  def available_moves_could_be_in_check
    possible_moves = []
    directions.each do |unit_row, unit_col|
      magnitudes.each do |scalar|
        new_row = row + unit_row * scalar
        new_col = col + unit_col * scalar

        break if obstacle?(new_row, new_col)
        possible_moves << [new_row, new_col]
        break if opponent?(new_row, new_col)
      end #Next magnitude
    end #Next direction

    possible_moves
  end

  private

  def opponent?(row, col)
    board.in_range?(row, col) && (board[row,col].color == OPPONENT[color])
  end

  def obstacle?(row, col)
    (!board.in_range?(row, col)) || board[row, col].teammate?(color)
  end

end

class Bishop < Piece
  include DIAGONAL_MOVES
  include MAGNITUDE_UNLIMITED

  def symbol
    " B ".colorize(display_color)
  end

end

class Pawn < Piece
  DIRECTION = {:red => -1, :black =>1}.freeze

  def initialize(board, row, col, color)
    super(board, row, col, color)
    @moved = false
  end

  def available_moves_could_be_in_check
    valid_normal_moves + valid_attacks
  end

  def symbol
    " P ".colorize(display_color)
  end

  private

  def all_normal_deltas
    v = DIRECTION[color]
    moved ? [[v,0]] : [[v,0],[2*v,0]]
  end

  def all_attack_deltas
    v = DIRECTION[color]
    [[v,-1], [v,1]]
  end

  def valid_normal_moves
    possible_moves = []
    all_normal_deltas.each do |dRow, dCol|
      new_row = row + dRow
      new_col = col + dCol
      break if obstacle?(new_row, new_col)
      break if opponent?(new_row, new_col)
      possible_moves << [new_row, new_col]
    end

    possible_moves
  end

  def valid_attacks
    possible_attacks = []
    all_attack_deltas.each do |dRow, dCol|
      new_row = row + dRow
      new_col = col + dCol
      if opponent?(new_row, new_col)
        possible_attacks << [new_row, new_col]
      end
    end

    possible_attacks
  end

end

class Rook < Piece
  include ROW_COL_MOVES
  include MAGNITUDE_UNLIMITED

  def symbol
    " R ".colorize(display_color)
  end

end

class Knight < Piece
  include MAGNITUDE_ONE

  def symbol
    " N ".colorize(display_color)
  end

  def directions
    [[-1,-2],[-2,-1],[1,-2],[-2,1],[-1,2],[2,-1],[1,2],[2,1]]
  end

end

class Queen < Piece
  include UNLIMITED_MOVES
  include MAGNITUDE_UNLIMITED

  def symbol
    " Q ".colorize(display_color)
  end

end

class King < Piece
  include UNLIMITED_MOVES
  include MAGNITUDE_ONE

  def symbol
    " K ".colorize(display_color)
  end

  def castle
    moves = []

    #If the king has moved, you can't castle.
    if moved
      return moves
    end

    #Try the rook on the left
    piece = board[row, 0]
    if piece.is_a?(Rook) && !piece.moved
      pathway = (1..col-1).map {|c| board[row,c]}
      if pathway.all?(&:empty?)
        moves << [row,col-2]
      end
    end

    #Try the rook on the right
    piece = board[row, 7]
    if piece.is_a?(Rook) && !piece.moved
      pathway = (col+1..6).map {|c| board[row,c]}
      #puts "pathway7: #{pathway}"
      #puts "empty? #{pathway.all?(&:empty?)}"
      if pathway.all?(&:empty?)
        moves << [row,col+2]
      end
    end

    moves
  end

  def available_moves_could_be_in_check
    super
    #super + castle
  end

end
