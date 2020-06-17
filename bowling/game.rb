# frozen_string_literal: true

require_relative '../canard'
require_relative '../duck/game_duck'
require_relative 'frame'

# This is top level comment
class Game
  include Canard

  def initialize
    @frames = []
  end

  Q< 'takes the number of pins knocked down'
  Q< 'returns nil'
  def roll(pins)
    Q< 'called each time the player rolls a ball'

    @frames << Frame.new if _start_new_frame?

    Q< 'a frame that needs a roll should exist here'
    Q< 'if we are on the 10th frame, the frame may be complete'

    @frames.each do |frame|
      frame.bonus_roll(pins) if frame.needs_bonus_roll?
    end

    @frames.last.roll(pins) if @frames.last.needs_roll?
  end

  Q< 'returns the total score for the game'
  def score
    Q< 'only called at the very end of the game'
    @frames.map(&:score).reduce(:+)
  end

  private

  def _start_new_frame?
    @frames.size.zero? || @frames.size < 10 && !@frames.last.needs_roll?
  end
end
