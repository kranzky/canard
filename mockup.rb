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

    def before(description, &block)
      _register(:before, description, block)
    end

    def during(description, &block)
      _register(:during, description, block)
    end

    def after(description, &block)
      _register(:after, description, block)
    end

    def quack(message="disappointed duck")
      exception = Quack.new("🐥🐥🐥 #{message} 🐥🐥🐥")
      exception.set_backtrace(caller)
      raise exception
    end

  private

    def _register(context, description, block)
      require 'contextual_proc'
      quack("duplicate: '#{description}'") if @_quacks.include?(description)
      @_quacks[description] = {
        context: context,
        proc: ContextualProc.new(&block)
      }
    end

    def _define(binding, description)
      puts "define '#{description}'"
    end

    def _execute(binding, description)
      puts "execute '#{description}'"
      quack("unregistered: '#{description}'") unless @_quacks.include?(description)
      binding.receiver.class.define_method(:xxx,  @_quacks[description][:proc])
      puts binding.receiver.class.instance_method(:xxx).bind(binding).call
#     puts binding.eval("self.class")
#     @_quacks[description][:proc].apply(binding)
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

Q.before "num must be between 0 and 99" do
  puts "AAA"
end

Q.during "num should exist here" do
  puts self.class
  puts num
end

Q.after "returns half the value passed in" do
  puts "CCC"
end

Foo.new.bar(42)
