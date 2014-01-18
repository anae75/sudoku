require 'spec_helper'
require_relative '../board'

describe Board do
  it 'can be created' do
    Board.new
  end

  let(:board) { Board.new }
  it 'can return all rows' do
    rows = board.rows

    expect(rows.size).to be 9
  end
  it 'can return all columns' do
    cols = board.columns

    expect(cols.size).to be 9
  end
  it 'can return all squares' do
    squares = board.squares

    expect(squares.size).to be 9
  end
end
