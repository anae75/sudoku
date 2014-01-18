require 'spec_helper'
require_relative '../position'

describe Position do
  let(:board) { Board.new }
  it 'can be added to a board' do
    board.add
  end
end
