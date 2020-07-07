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

    def <(description)
      require 'debug_inspector'
      binding =
        RubyVM::DebugInspector.open do |inspector|
          inspector.frame_binding(2)
        end
      binding.receiver.class == Class ? _define(binding, description) : _execute(binding, description)
      nil
    end

    def alias(name)
      Object.define_method(name) { |description| Q< description }
    end

    def before(description, code)
      _register(:before, description, code)
    end

    def during(description, code)
      _register(:during, description, code)
    end

    def after(description, code)
      _register(:after, description, code)
    end

    def quack(message="disappointed duck")
      exception = Quack.new("🐥🐥🐥 #{message} 🐥🐥🐥")
      exception.set_backtrace(caller)
      raise exception
    end

  private

    def _register(context, description, code)
      quack("duplicate: '#{description}'") if @_quacks.include?(description)
      @_quacks[description] = {
        context: context,
        code: code
      }
    end

    def _define(binding, description)
      puts "define '#{description}'"
    end

    def _execute(binding, description)
      puts "execute '#{description}'"
      quack("unregistered: '#{description}'") unless @_quacks.include?(description)
      binding.eval(@_quacks[description][:code])
    end
  end.new

Q.alias :🐤

class Foo
  Q< "num must be between 0 and 99"
  🐤 "returns half the value passed in"
  def bar(num)
    num << 1
    Q< "num should exist here"
    num
  end
end

Q.before "num must be between 0 and 99", <<~EGG
  puts "AAA"
EGG

Q.during "num should exist here", <<~EGG
  puts self.class
  puts num
EGG

Q.after "returns half the value passed in", <<~EGG
  puts "CCC"
EGG

Foo.new.bar(42)
