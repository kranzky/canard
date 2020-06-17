# frozen_string_literal: true

require '../bowling/frame'

class Frame
  Q< :needs_roll? do
    after 'returns a bool indicating whether this frame is waiting for a roll' do
      expect([true, false]).to cover?(retval)
    end
  end

  Q< :roll do
    before 'takes the number of pins knocked down' do
      expect(pins).to be_a(FixNum)
      expect(0..10).to cover(pins)
    end

    within 'called only if the frame is waiting for a roll' do
      expect(needs_roll?).to be_true
    end
  end

  Q< :needs_bonus_roll? do
    after 'returns a bool indicating whether this frame is waiting for a bonus roll' do
      expect([true, false]).to cover?(retval)
    end
  end

  Q< :bonus_roll do
    before 'takes the number of pins knocked down' do
      expect(pins).to be_a(FixNum)
      expect(0..10).to cover(pins)
    end

    within 'called only if the frame is waiting for a bonus roll' do
      expect(needs_bonus_roll?).to be_true
    end
  end

  Q< :score do
    within 'called only when the frame is complete' do
      expect(needs_roll?).to be_false
      expect(needs_bonus_roll?).to be_false
    end

    after 'returns the total score for this frame' do
      expect(retval).to be_a(FixNum)
      expect([0..30]).to cover(retval)
    end
  end
end
