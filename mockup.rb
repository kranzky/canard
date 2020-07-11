#!/usr/bin/env ruby

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
    end

    def ^(message="disappointed duck")
      exception = Quack.new("🐥🐥🐥 #{message} 🐥🐥🐥")
      exception.set_backtrace(caller)
      raise exception
    end

    def <(description)
      require 'debug_inspector'
      binding =
        RubyVM::DebugInspector.open do |inspector|
          inspector.frame_binding(2)
        end
      binding.receiver.class == Class ? _define(binding, description) : _execute(binding, description)
      nil
    end

    def []=(description, value)
      _register(description, value)
    end

    def alias(name)
      Object.define_method(name) { |description| Q< description }
    end

    def quack(name)
      Object.define_method(name) { |description| Q^ description }
    end

  private

    def _register(description, code)
      puts "register '#{description}'"
      quack("duplicate: '#{description}'") if @_quacks.include?(description)
      @_quacks[description] = code
    end

    def _define(binding, description)
      puts "define '#{description}'"
      # TODO: wrap the next method to run pre and post conditions
      # TODO: all are pre unless description starts with "returns"
    end

    def _execute(binding, description)
      puts "execute '#{description}'"
      quack("unregistered: '#{description}'") unless @_quacks.include?(description)
      binding.eval(@_quacks[description])
    end
  end.new

Q.alias :🐤
Q.quack :💥

class Foo
  Q< "num must be between 0 and 99"
  🐤 "returns half the value passed in"
  def bar(num)
    num << 1
    Q< "num should exist here"
    num
  end
end

Q["num must be between 0 and 99"] = <<~EGG
  💥"too small" if num < 0
  💥 "too big" if num > 99
EGG

Q["num should exist here"] = <<~EGG
  💥 "non-existence!" unless defined? num
EGG

Q["returns half the value passed in"] = <<~EGG
  💥 "bad mojo" if retval != num / 2
EGG

Foo.new.bar(42)
