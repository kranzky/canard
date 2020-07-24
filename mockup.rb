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

class Foo
  Q< "num must be between 0 and 99"
  Q< "returns half the value passed in"
  def bar(num, foo)
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
  puts foo
Q

Q["returns half the value passed in"] = <<~Q
  Q^ "wrong answer" if retval != num / 2
Q

puts Foo.new.bar(ARGV.first.to_i, 137)
