module Sudoku
  VALID_NUMBERS = (1..9).to_a

  class Board
    attr_reader :squares
    def initialize
      @rows = []
      @columns = []
      @squares = []
      9.times do
        @rows << NumberSet.new
        @columns << NumberSet.new
        @squares << NumberSet.new
      end
      @positions = {}
    end

    def rows
      return @rows
    end
    def columns
      return @columns
    end

    def position(rownum, columnnum)
      pos = ( @positions[[rownum, columnnum]] ||= 
            Position.new(self, row(rownum), column(columnnum), square(rownum,columnnum)) )
      pos
    end

    def row(num)
      raise "Invalid row number #{num}" unless (0..8).include?(num)
      return @rows[num]
    end

    def column(num)
      raise "Invalid column number #{num}" unless (0..8).include?(num)
      return @columns[num]
    end

    def square(rownum, columnnum)
      index = 3*(rownum/3) + columnnum/3
      @squares[index]
    end

  end


  class Board
    class Position

      def initialize(board, row, column, square)
        @value = nil
        @board = board
        @row = row
        @column = column
        @square = square
      end

      def assign(newval)
        @row.remove(@value) if @value
        @column.remove(@value) if @value
        @square.remove(@value) if @value

        @value = newval
        @row.add(newval)
        @column.add(newval)
        @square.add(newval)
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
      def remove(num)
        @values[num] = false
      end
    end
  end


end
