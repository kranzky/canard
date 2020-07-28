#!/usr/bin/env ruby

require 'rspec/expectations'

Q =
  Class.new do
    class Quack < StandardError
      def initialize(message)
        super
      end
    end

    class << self
      def to_s
        '🥚'
      end
      alias :inspect :to_s
    end
    def to_s
      '🐣'
    end
    alias :inspect :to_s

    def initialize
      @_quacks = {}
      @_memory = []
      @_caller = nil
    end

    def ^(message="ima disappointed duck")
      exception = Quack.new("🐥 - \"#{message}\"")
      exception.set_backtrace(@_caller || caller)
      raise exception
    end

    def <(description)
      require 'debug_inspector'
      context =
        RubyVM::DebugInspector.open do |inspector|
          inspector.frame_binding(2)
        end
      context.receiver.class == Class ? _define(context, description, caller) : _execute(context, description, caller)
      nil
    end

    def []=(description, value)
      _register(description, value, caller)
    end

  private

    def _register(description, code, original_caller)
      @_caller = original_caller
      Q^ "duplicate: '#{description}'" if @_quacks.include?(description)
      @_quacks[description] = code
    ensure
      @_caller = nil
    end

    def _define(context, description, original_caller)
      @_memory << {
        caller: original_caller,
        description: description
      }
      klass = context.receiver
      return if klass.methods.include?(:method_added)
      def klass.method_added(name)
        super
        original = instance_method(name)
        Q.send(:_wrap, self, name, original)
      end
    end

    def _execute(context, description, original_caller)
      @_caller = original_caller
      Q^ "unregistered: '#{description}'" unless @_quacks.include?(description)
      context.eval(@_quacks[description])
    rescue RSpec::Expectations::ExpectationNotMetError
      @_caller = original_caller
      Q^ description
    ensure
      @_caller = nil
    end

    def _wrap(klass, name, original)
      return if @_memory.empty? || name =~ /^_q_/
      before = @_memory.clone.select { |item| item[:description] !~ /^returns / }
      after = @_memory.clone - before
      quackless = "_q_#{name}"
      klass.send(:alias_method, quackless, name)
      eval <<~Q
        klass.define_method(name) do |#{_args(original.parameters)}|
          before.each { |item| Q.send(:_execute, binding, item[:description], item[:caller]) }
          retval = send(quackless, #{original.parameters.map(&:last).join(', ')})
          after.each { |item| Q.send(:_execute, binding, item[:description], item[:caller]) }
          retval
        end
      Q
    ensure
      @_memory.clear
    end

    def _args(data)
      data.map do |kind, name|
        case kind
        when :req
          name
        when :opt
          "#{name}=nil"
        when :rest
          "*#{name}"
        when :block
          "&#{name}"
        when :key
          "#{name}:"
        when :keyopt
          "#{name}:nil"
        when :keyrest
          "**#{name}"
        end
      end.join(', ')
    end
  end.new

# ==============================================================================

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

# ------------------------------------------------------------------------------

class Game
  include RSpec::Matchers

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

# ==============================================================================

Q['returns nil'] = <<~Q
  expect(retval).to be_nil
Q

Q['returns whether this frame is waiting for a roll'] = <<~Q
  expect([true, false]).to include(retval)
Q

Q['takes the number of pins knocked down'] = <<~Q
  expect(pins).to be_a(Integer)
  expect(0..10).to cover(pins)
Q

Q['called only if the frame is waiting for a roll'] = <<~Q
  expect(needs_roll?).to eq(true)
Q

Q['returns whether this frame is waiting for a bonus roll'] = <<~Q
  expect([true, false]).to include(retval)
Q

Q['called only if the frame is waiting for a bonus roll'] = <<~Q
  expect(needs_bonus_roll?).to eq(true)
Q

Q['called only when the frame is complete'] = <<~Q
  expect(needs_roll?).to be_false
  expect(needs_bonus_roll?).to be_false
Q

Q['returns the total score for this frame'] = <<~Q
  expect(retval).to be_a(FixNum)
  expect([0..30]).to cover(retval)
Q

Q['called each time the player rolls a ball'] = <<~Q
  expect(@frames).to be_a(Array)
  expect(0..10).to cover(@frames.length)
Q

Q['a frame that needs a roll should exist here'] = <<~Q
  needs_roll = @frames.last.needs_roll? || @frames.last.needs_bonus_roll?
  expect(needs_roll).to eq(true)
Q

Q['if we are on the 10th frame, the frame may be complete'] = <<~Q
  if @frames.length < 10
    expect(@frames.last.needs_roll?).to eq(true)
  end
Q

Q['only called at the very end of the game'] = <<~Q
  expect(@frames.length).to eq(10)
  needs_roll = @frames.last.needs_roll? || @frames.last.needs_bonus_roll?
  expect(needs_roll).to be_false
Q

Q['returns the total score for the game'] = <<~Q
  expect(retval).to be_a(FixNum)
  expect(0..300).to cover(retval)
Q

# ==============================================================================

game = Game.new
game.roll(5)
