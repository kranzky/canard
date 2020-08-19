require_relative './spec_helper'

describe Bowling::Frame do
  let(:frame) { described_class.new }

  it 'needs a roll by default' do
    expect(frame.needs_roll?).to eq(true)
  end

  it 'does not need a roll after a strike' do
    frame.roll(10)
    expect(frame.needs_roll?).to eq(false)
  end

  it 'needs a bonus roll after a spare' do
    frame.roll(5)
    frame.roll(5)
    expect(frame.needs_bonus_roll?).to eq(true)
  end

  it 'returns the score after all rolls are complete' do
    frame.roll(3)
    frame.roll(5)
    expect(frame.score).to eq(8)
  end

  # it 'fails if the frame is not valid' do
  #   expect(game.score).to quack('only called at the very...')
  #   expect(game.roll(11)).to quack('takes the number of...')
  #   expect(game.roll(5.5)).to quack('takes the number of...')
  #   expect(game.roll(nil)).to quack
  #   expect(30.times { game.roll(0) }).to quack
  # end
end
