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
      @_memory = []
    end

    def ^(message="disappointed duck")
      exception = Quack.new("🐥🐥🐥 #{message} 🐥🐥🐥")
      exception.set_backtrace(caller)
      raise exception
    end

    def <(description)
      require 'debug_inspector'
      context =
        RubyVM::DebugInspector.open do |inspector|
          inspector.frame_binding(2)
        end
      context.receiver.class == Class ? _define(context, description) : _execute(context, description)
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

    def _define(context, description)
      puts "define '#{description}'"
      @_memory << description
      klass = context.receiver
      return if klass.methods.include?(:method_added)
      def klass.method_added(name)
        super
        original = instance_method(name)
        Q.send(:_wrap, self, name, original)
      end
    end

    def _execute(context, description)
      puts "execute '#{description}'"
      Q^ "unregistered: '#{description}'" unless @_quacks.include?(description)
      context.eval(@_quacks[description])
    end

    def _wrap(klass, name, original)
      return if @_memory.empty? || name =~ /^_q_/
      puts "wrap #{klass}##{name}"
      puts original.parameters
      before = @_memory.clone.select { |description| description !~ /^returns / }
      after = @_memory.clone - before
      quackless = "_q_#{name}"
      klass.send(:alias_method, quackless, name)
      klass.define_method(name) do |num|
        before.each { |description| Q.send(:_execute, binding, description) }
        retval = send(quackless, num)
        after.each { |description| Q.send(:_execute, binding, description) }
      end
    ensure
      @_memory.clear
    end
  end.new

Q.alias :🐤
Q.quack :💥

class Foo
  Q< "num must be between 0 and 99"
  Q< "returns half the value passed in"
  def bar(num)
    num >>= 1
    Q< "num should exist here"
    num
  end
end

Q["num must be between 0 and 99"] = <<~Q
  Q^ "too small" if num < 0
  Q^ "too big" if num > 99
Q

Q["num should exist here"] = <<~Q
  Q^ "non-existence!" unless defined? num
Q

Q["returns half the value passed in"] = <<~Q
  Q^ "wrong answer" if retval != num / 2
Q

Foo.new.bar(42)
