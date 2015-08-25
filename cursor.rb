require 'io/console'
require_relative 'custom_exceptions'

class Cursor
  MOVES = {
     "w"  => [-1, 0],
    "a"  => [0, -1],
    "s"  => [1, 0],
    "d"  => [0, 1],
    "\r" => [0, 0],
    "q" => :q
  }.freeze

  attr_reader :row, :col, :pending_row, :pending_col

  def initialize(board, row=0, col=0)
    @board, @row, @col = board, row, col
    @pending_row, @pending_col = row, col
    @pending_flag = false
    @second_flag = false
  end

  def browse
    begin
      until pending_flag
        render
        move
        start_row, start_col = row, col
      end

      while pending_flag
        render
        move
        end_row, end_col = row, col
      end

      return [[start_row, start_col], [end_row, end_col]]

    rescue IllegalMove
      retry

    rescue Interrupt
      render

    end

  end

  def move
    move = STDIN.getch
    if !MOVES.include?(move)
      return
    elsif MOVES[move] == :q
      raise Interrupt
    end

    dRow, dCol = MOVES[move]

    if [dRow, dCol] == [0, 0]
      if !pending_flag && board[row, col].empty?
        return # Cannot move an empty square anywhere else
      end

      @pending_flag = !@pending_flag
      @pending_row, @pending_col = row, col
    end

    if in_range?(row+dRow, col+dCol)
      @row, @col = (row+dRow), (col+dCol)
    end

  end

  def pending_pos?(row, col)
    pending_flag && (row == pending_row) && (col == pending_col)
  end

  def current_pos?(row, col)
    row == self.row && col == self.col
  end

  private
  attr_writer :row, :col
  attr_reader :board, :pending_flag

  def render
    board.render
  end

  def in_range?(row, col)
    board.in_range?(row, col)
  end

end
