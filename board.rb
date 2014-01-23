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

    def empty_positions
      arr = []
      9.times do |row|
        9.times do |col|
          pos = position(row, col)
          arr << pos unless pos.value
        end
      end
      arr
    end

  end


  class Board
    class Position

      attr_reader :row, :column, :square
      attr_reader :value

      def initialize(board, row, column, square)
        @value = nil
        @board = board
        @row = row
        @column = column
        @square = square
        @candidates = nil
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

      def clear_candidates
        @candidates = nil
      end

      def candidates
        return @candidates if @candidates
        @candidates = VALID_NUMBERS.dup

        # reject candidates that appear in the row, column, square
        @candidates -= @row.items
        @candidates -= @column.items
        @candidates -= @square.items
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
      def items
        @values.keys
      end
    end
  end

  class Game
    attr_reader :board
    def initialize(str)
      @board = Board.new

      lines = str.split(/$/).collect(&:strip).reject { |x| !x || x.empty? }
      positions = lines.collect do |line|
          line.gsub(/\s/,'').split //
        end

      # sanity check
      raise "Wrong number of lines #{positions.size}" unless positions.size == 9
      positions.each_with_index do |line, index|
        raise "Wrong number of chars in line #{index} (#{line})" unless line.size == 9
      end

      # set up the board
      positions.each_with_index do |line, row_index|
        line.each_with_index do |value, col_index|
          next if value == '_'
          @board.position(row_index, col_index).assign(value.to_i)
        end
      end
    end

    def advance
      positions = @board.empty_positions
    end
  end

end
