require 'pry' 

module Sudoku
  VALID_NUMBERS = (1..9).to_a

  class Board
    attr_reader :squares
    def initialize
      @rows = []
      @columns = []
      @squares = []
      9.times do
        @rows << PositionSet.new
        @columns << PositionSet.new
        @squares << PositionSet.new
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
      pos =  @positions[[rownum, columnnum]] 
      if !pos
        pos = Position.new("#{rownum},#{columnnum}", self, row(rownum), column(columnnum), square(rownum,columnnum))
        @positions[[rownum, columnnum]] = pos
        row(rownum).add pos, columnnum
        column(columnnum).add pos, rownum
        square(rownum, columnnum).add pos
      end
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

    def pprint(value=nil, defchar='#')
      9.times do |row|
        print '   '
        9.times do |col|
          pos = position(row, col)
          char = case
            when value && pos.value && pos.value!=value
              defchar
            else
              pos.value || '_'
            end
          print char
          print ' ' if (col+1) % 3 == 0
        end
        puts
        puts if (row+1) % 3 == 0
      end
      puts '-'*30
    end

    def validate_values(values)
      errors = []
      errors << "duplicate values" if values.size != values.uniq.size 
      values.each do |val|
        errors << "invalid value #{val}" unless VALID_NUMBERS.include?(val) 
      end
      errors
    end

    def valid?
      9.times do |rownum|
        row_values = (0..8).collect { |colnum| position(rownum, colnum).value }.compact 
        errors = validate_values(row_values)
        raise "problem with row #{rownum} (#{row_values.inspect}): #{errors.join("\n")}" unless errors.empty?
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
        @value = newval
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

  class Board
    class PositionSet
      def initialize
        @positions = []
      end
      def items
        @positions.compact.collect { |pos| pos.value } .compact
      end
      def contains?(num)
        items.include? num
      end
      def add(pos, index=nil)
        if index
          @positions[index] = pos 
        else
          @positions << pos
        end
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
          puts "found single candidate for #{pos.name}: #{candidates.first}"
          binding.pry
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

      @board.valid?
      return positions.size
    end

    def reduce_groups(groups, name)
      groups.each do |group, elements|
        elements.each do |pos|
          elements.each { |elem| elem.update }
          others = (elements - [pos]).collect(&:candidates).flatten
          puts ">> #{pos.candidates.sort} vs #{others.uniq.sort}"
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
      niter = 0
      num = old_num = @board.empty_positions.size
      while num > 0
        num = advance
        niter += 1
        binding.pry if num == old_num # debug infinite loop
        raise "infinite loop in iteration #{niter}" if num == old_num
        old_num = num
      end
    end
  end

end
