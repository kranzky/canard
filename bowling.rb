require './canard'

class Frame
  include Canard

  def initialize
    @rolls = [] ; @bonus = []
  end

  Q< "takes the number of pins knocked down"
  def roll(pins)
    Q< "called only if the frame is not done"
    @rolls << pins
  end

  Q< "returns a boolean indicating whether this frame is done"
  def done?
    _strike? || @rolls.size == 2
  end

  Q< "returns a boolean indicating whether we need a bonus roll"
  def needs_bonus?
    _strike? && @bonus.size < 2 || _spare? && @bonus.size < 1
  end

  Q< "takes the number of pins knocked down"
  def bonus(pins)
    Q< "called when the frame is done and bonuses are pending"
    @bonus << pins
  end

  Q< "returns the total score for this frame"
  def score
    Q< "called only if we're done and bonuses are available"
    @rolls.reduce(:+) + @bonus.reduce(0, :+)
  end

  private

  def _strike?
    @rolls.first == 10
  end

  def _spare?
    @rolls.reduce(:+) == 10
  end
end

class Game
  include Canard

  def initialize
    @frames = []
  end

  Q< "takes the number of pins knocked down"
  def roll(pins)
    Q< "called each time the player rolls a ball"
    
    @frames << Frame.new if _start_frame?
    Q< "a frame that needs a roll should exist here"

    @frames.each do |frame|
      frame.bonus(pins) if frame.needs_bonus?
    end
    
    Q< "if we're on the 10th frame, we may be done already"
    @frames.last.roll(pins) unless @frames.last.done?
  end

  Q< "returns the total score for that game"
  def score
    Q< "only called at the very end of the game"
    @frames.map(&:score).reduce(:+)
  end

  private

  def _start_frame?
    @frames.size == 0 || @frames.size < 10 && @frames.last.done?
  end
end
