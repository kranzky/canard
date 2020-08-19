require 'rspec/expectations'

module Bowling
  class Frame
    include RSpec::Matchers

    def initialize
      @rolls = []
      @bonus_rolls = []
    end

    Q< 'returns whether this frame is waiting for a roll'
    def needs_roll?
      !_strike? && @rolls.size < 2
    end

    Q< 'takes the number of pins knocked down'
    Q< 'returns nil'
    def roll(pins)
      Q< 'called only if the frame is waiting for a roll'
      @rolls << pins
      nil
    end

    Q< 'returns whether this frame is waiting for a bonus roll'
    def needs_bonus_roll?
      _strike? && @bonus_rolls.size < 2 || _spare? && @bonus_rolls.empty?
    end

    Q< 'takes the number of pins knocked down'
    Q< 'returns nil'
    def bonus_roll(pins)
      Q< 'called only if the frame is waiting for a bonus roll'
      @bonus_rolls << pins
      nil
    end

    Q< 'returns the total score for this frame'
    def score
      Q< 'called only when no more rolls are required'
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
end
