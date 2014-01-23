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
            Position.new("#{rownum},#{columnnum}", self, row(rownum), column(columnnum), square(rownum,columnnum)) )
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

    def pprint
      9.times do |row|
        9.times do |col|
          pos = position(row, col)
          print pos.value || '_'
          print ' ' if (col+1) % 3 == 0
        end
        puts
        puts if (row+1) % 3 == 0
      end

    end

  end


  class Board
    class Position

      attr_reader :name, :row, :column, :square
      attr_reader :value

      def initialize(name, board, row, column, square)
        @name = name
        @value = nil
        @board = board
        @row = row
        @column = column
        @square = square
        @candidates = nil
      end

      def assign(newval)
        clear_candidates
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
        @candidates
      end

      def update
        clear_candidates
        return candidates
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
      
      # update all empty positions and assign those that have only one candidate
      old_num_empty = positions.size
      positions.each do |pos|
        candidates = pos.update
        if candidates.size == 1
          pos.assign(candidates.first)
        end
      end
      positions.reject! { |pos| pos.value }
      new_num_empty = positions.size
      puts "#{old_num_empty} => #{new_num_empty}"
      @board.pprint

      # go through the rows and update all those that are not ambiguous
      groups = positions.group_by { |pos| pos.row }
      reduce_groups(groups, 'row')
      positions.reject! { |pos| pos.value }
      positions.each { |pos| pos.update }

      reduce_groups( positions.group_by { |pos| pos.column }, 'column' )
      positions.reject! { |pos| pos.value }
      positions.each { |pos| pos.update }

      reduce_groups( positions.group_by { |pos| pos.square }, 'square' )
      positions.reject! { |pos| pos.value }

      return positions.size
    end

    def reduce_groups(groups, name)
      groups.each do |group, elements|
        elements.each do |pos|
          others = (elements - [pos]).collect(&:candidates).flatten
          pos.candidates.each do |candidate_val|
            next if others.include?(candidate_val)
            puts "Found unique candidate for position #{pos.name} in #{name}: #{candidate_val}"
            puts "others:", others.inspect
            pos.assign(candidate_val)
            @board.pprint
            break
          end
        end
      end
    end

    def solve
      num = old_num = @board.empty_positions.size
      while num > 0
        num = advance
        raise 'infinite loop' if num == old_num
        old_num = num
      end
    end
  end

end
