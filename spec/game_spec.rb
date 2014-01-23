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

  it 'can solve 1 turn' do
    game = Game.new game_01_easy
    game.advance
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
end
