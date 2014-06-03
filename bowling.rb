require './canard'

class Frame
  include Canard

  def initialize
    @rolls = [] ; @bonus_rolls = []
  end

  Q< "returns a bool indicating whether this frame is waiting for a roll"
  def needs_roll?
    !_strike? && @rolls.size < 2
  end

  Q< "takes the number of pins knocked down"
  def roll(pins)
    Q< "called only if the frame is waiting for a roll"
    @rolls << pins
  end

  Q< "returns a bool indicating whether this frame is waiting for a bonus roll"
  def needs_bonus_roll?
    _strike? && @bonus_rolls.size < 2 || _spare? && @bonus_rolls.size < 1
  end

  Q< "takes the number of pins knocked down"
  def bonus_roll(pins)
    Q< "called only if the frame is waiting for a bonus roll"
    @bonus_rolls << pins
  end

  Q< "returns the total score for this frame"
  def score
    Q< "called only when the frame is complete"
    @rolls.reduce(:+) + @bonus_rolls.reduce(0, :+)
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
    
    @frames << Frame.new if _start_new_frame?

    Q< "a frame that needs a roll should exist here"
    Q< "if we're on the 10th frame, we may only be waiting for a bonus roll"

    @frames.each do |frame|
      frame.bonus_roll(pins) if frame.needs_bonus_roll?
    end

    @frames.last.roll(pins) if @frames.last.needs_roll?
  end

  Q< "returns the total score for the game"
  def score
    Q< "only called at the very end of the game"
    @frames.map(&:score).reduce(:+)
  end

  private

  def _start_new_frame?
    @frames.size == 0 || @frames.size < 10 && !@frames.last.needs_roll?
  end
end
