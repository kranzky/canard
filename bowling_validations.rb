class Game
  Q< :roll do
    before "takes the number of pins knocked down" do
      expect(pins).to be_a(FixNum)
      expect(1..10).to cover(pins)
    end
 
    during "called each time the player rolls a ball" do
      expect(@frames).to be_a(Array)
      expect(1..10).to cover(@frames.length)
    end

    during "a frame that needs a roll should exist here" do
      needs_roll = @frames.last.needs_roll? || @frames.last.needs_bonus_roll?
      expect(needs_roll).to be_true
    end

    during "if we're on the 10th frame, we may only be waiting for a bonus roll" do
      if @frames.length < 10
        expect(@frames.last.needs_roll?).to be_true
      end
    end
  end

  Q< :score do
    during "only called at the very end of the game" do
      expect(@frames.length).to eq(10)
      needs_roll = @frames.last.needs_roll? || @frames.last.needs_bonus_roll?
      expect(needs_roll).to be_false
    end

    after "returns the total score for the game" do
      expect(retval).to be_a(FixNum)
      expect(0..300).to cover(retval)
    end
  end
end

#-------------------------------------------------------------------------------

class Frame
  Q< :needs_roll? do
    after "returns a bool indicating whether this frame is waiting for a roll" do
      expect([true, false]).to cover?(retval)
    end
  end

  Q< :roll do
    before "takes the number of pins knocked down" do
      expect(pins).to be_a(FixNum)
      expect(0..10).to cover(pins)
    end

    during "called only if the frame is waiting for a roll" do
      expect(needs_roll?).to be_true
    end
  end

  Q< :needs_bonus_roll? do
    after "returns a bool indicating whether this frame is waiting for a bonus roll" do
      expect([true, false]).to cover?(retval)
    end
  end

  Q< :bonus_roll do
    before "takes the number of pins knocked down" do
      expect(pins).to be_a(FixNum)
      expect(0..10).to cover(pins)
    end

    during "called only if the frame is waiting for a bonus roll" do
      expect(needs_bonus_roll?).to be_true
    end
  end

  Q< :score do
    during "called only when the frame is complete" do
      expect(needs_roll?).to be_false
      expect(needs_bonus_roll?).to be_false
    end

    after "returns the total score for this frame" do
      expect(retval).to be_a(FixNum)
      expect([0..30]).to cover(retval)
    end
  end
end
