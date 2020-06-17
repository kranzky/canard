# frozen_string_literal: true

require '../bowling/game'

class Game
  Q< :roll do
    before 'takes the number of pins knocked down' do
      expect(pins).to be_a(FixNum)
      expect(1..10).to cover(pins)
    end
 
    within 'called each time the player rolls a ball' do
      expect(@frames).to be_a(Array)
      expect(1..10).to cover(@frames.length)
    end

    within 'a frame that needs a roll should exist here' do
      needs_roll = @frames.last.needs_roll? || @frames.last.needs_bonus_roll?
      expect(needs_roll).to be_true
    end

    within 'if we are on the 10th frame, we may only be waiting for a bonus roll' do
      if @frames.length < 10
        expect(@frames.last.needs_roll?).to be_true
      end
    end
  end

  Q< :score do
    within 'only called at the very end of the game' do
      expect(@frames.length).to eq(10)
      needs_roll = @frames.last.needs_roll? || @frames.last.needs_bonus_roll?
      expect(needs_roll).to be_false
    end

    after 'returns the total score for the game' do
      expect(retval).to be_a(FixNum)
      expect(0..300).to cover(retval)
    end
  end
end
