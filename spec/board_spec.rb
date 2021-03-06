require 'spec_helper'
require_relative '../board'

include Sudoku

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

  it 'knows which square a position belongs to' do
    expect(board.square(0,0)).to be(board.squares[0])
    expect(board.square(4,1)).to be(board.squares[3])
    expect(board.square(6,6)).to be(board.squares[8])
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

  context 'a number is assigned to a position and then changed' do
    before do
      @board = Board.new
      @board.position(4,1).assign(5)
      @board.position(4,1).assign(8)
    end
    let(:board) { @board}
    it 'knows that the number is in that row' do
      expect(board.row(4).contains?(5)).to be false
      expect(board.row(4).contains?(8)).to be true
    end
    it 'knows that the number is in that column' do
      expect(board.column(1).contains?(5)).to be false
      expect(board.column(1).contains?(8)).to be true
    end
  end

end
