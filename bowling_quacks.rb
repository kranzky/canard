require './bowling'

class Game
  Q< :roll do
    before “takes the number of pins knocked down” do
      expect(pins).to be_a(FixNum)
      expect(1..10).to cover(pins)
    end
 
    within “called each time the player rolls a ball” do
      expect(@frames).to be_a(Array)
      expect(1..10).to cover(@frames.length)
    end
  end

  Q< :score do
    within “only called at the very end of the game” do
      expect(@frames.length).to eq(10)
    end

    after “returns the total score for that game” do
      expect(retval).to be_a(FixNum)
      expect(0..300).to cover(retval)
    end
  end
end
