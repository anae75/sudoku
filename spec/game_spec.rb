require 'spec_helper'
require_relative '../board'

include Sudoku

describe Game do

  it 'can be initialized with state' do
    game = Game.new game_01_easy
    expect(game.board.position(0,0).value).to be(7)
    expect(game.board.position(8,8).value).to be(1)
    expect(game.board.position(7,2).value).to be(7)
    expect(game.board.position(7,1).value).to be_nil
  end

  #it 'can advance 1 turn' do
  #  game = Game.new game_01_easy
  #  game.advance
  #end

  it 'can solve an easy game' do
    game = Game.new game_01_easy
    num = old_num = game.board.empty_positions.size
    while num > 0
      num = game.advance
      raise 'infinite loop' if num == old_num
      old_num = num
    end
  end

  it 'can solve a hard game', :hard => true do
    game = Game.new game_02_hard
    game.solve
    game.board.pprint
  end

  def game_01_easy
  <<-END
721 543 6_9
__4 _9_ 1_3
983 2_1 457

1_6 3_8 9_2
25_ ___ _68
3_8 9_6 7_5

692 7_5 834
8_7 _3_ 5__
4_5 689 271
  END
  end

  def game_02_hard
  <<-END
___ __2 _8_
__8 _9_ 2_7
_4_ 8_7 _1_

__1 4__ 9_8
_5_ ___ _3_
8_9 __3 5__

_8_ 2_6 _9_
3_2 _1_ 8__
_1_ 5__ ___
  END
  end
end
