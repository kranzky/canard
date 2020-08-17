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

    def <<(blob)
      mode = :description
      description = nil
      value = []
      blob.split("\n").each do |line|
        line.strip!
        case mode
        when :description
          if line =~ /## (.*)$/
            description = Regexp.last_match(1)
            mode = :value_start
          end
        when :value_start
          mode = :value_parse if line =~ /``/
        when :value_parse
          if line =~ /``/
            _register(description, value.join("\n"), caller)
            description = nil
            value.clear
            mode = :description
          else
            value << line
          end
        end
      end
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

Q << File.read("QUACKS.md")

game = Game.new
game.roll(5)
