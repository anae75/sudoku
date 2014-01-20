require 'spec_helper'
require_relative '../board'

include Sudoku

describe Board::Position do
  it 'can calculate candidates' do
    board = Board.new
    board.position(0,0).assign(3)       # same row
    board.position(4,1).assign(8)       # same column
    board.position(1,1).assign(2)       # same square
    pos = board.position(0,1)
    pos.clear_candidates
    expect(pos.candidates.sort).to eq([1,4,5,6,7,9].sort)
  end
end
