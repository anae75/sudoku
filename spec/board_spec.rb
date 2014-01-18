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

  it 'can assign a number to a position' do
    board.position(4,1).assign(5)
  end

  context 'a number is assigned to a position' do
    before do
      @board = Board.new
      @board.position(4,1).assign(5)
    end
    let(:board) { @board} 
    it 'knows that the number is in that row' do
      expect(board.row(4).contains?(5)).to be true
      expect(board.row(4).contains?(7)).to be false
    end
    it 'knows that the number is in that column' do
      expect(board.column(1).contains?(5)).to be true
      expect(board.column(1).contains?(7)).to be false
    end
  end
end
