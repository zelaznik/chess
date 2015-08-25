def diagonal_directions
  [[-1,1],[-1,-1],[1,-1],[1,1]]
end

def row_col_directions
  [[0,1],[0,-1],[1,0],[-1,0]]
end

module MAGNITUDE_UNLIMITED
  def magnitudes
    (1...8).to_a
  end
end

module MAGNITUDE_ONE
  def magnitudes
    [1]
  end
end

module DIAGONAL_MOVES
  def directions
    diagonal_directions
  end
end

module ROW_COL_MOVES
  def directions
    row_col_directions
  end
end

module UNLIMITED_MOVES
  def directions
    row_col_directions + diagonal_directions
  end
end
