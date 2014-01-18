class Board
  def initialize
    @rows = []
    @columns = []
    9.times do
      @rows << NumberSet.new
      @columns << NumberSet.new
    end
  end

  def rows
    return @rows
  end
  def columns
    return @columns
  end
  def squares
    return (0..8).to_a
  end

  def position(rownum, columnum)
    return Position.new(self, row(rownum), column(columnum))
  end

  def row(num)
    raise "Invalid row number #{num}" unless (0..8).include?(num)
    return @rows[num]
  end

  def column(num)
    raise "Invalid column number #{num}" unless (0..8).include?(num)
    return @columns[num]
  end

end


class Board
  class Position

    def initialize(board, row, column)
      @value = nil
      @board = board
      @row = row
      @column = column
    end

    def assign(newval)
      @value = newval
      # remove old val?
      @row.add(newval)
      @column.add(newval)
    end
  end
end

class Board
  class NumberSet
    def initialize
      @values = {}
    end
    def contains?(num)
      return @values[num] == true
    end
    def add(num)
      @values[num] = true
    end
  end
end
