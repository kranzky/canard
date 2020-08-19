# frozen_string_literal: true

Q =
  Class.new do
    # The exception type that Canard throws when it encounters any error, either
    # during startup or during execution of user code.
    class Quack < StandardError
      def initialize(message)
        super
      end
    end

    class << self
      def to_s
        '🥚'
      end
      alias_method :inspect, :to_s
    end
    def to_s
      '🐣'
    end
    alias_method :inspect, :to_s

    def initialize
      @_quacks = {}
      @_memory = []
      @_caller = nil
    end

    def ^(message = 'ima disappointed duck')
      exception = Quack.new("🐥 - \"#{message}\"")
      exception.set_backtrace(@_caller || caller)
      raise exception
    end

    def <(other)
      require 'debug_inspector'
      context =
        RubyVM::DebugInspector.open do |inspector|
          inspector.frame_binding(2)
        end
      context.receiver.class == Class ? _define(context, other, caller) : _execute(context, other, caller)
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

      before = @_memory.clone.reject { |item| item[:description] =~ /^returns / }
      after = @_memory.clone - before # rubocop:disable Lint/UselessAssignment
      quackless = "_q_#{name}"
      klass.send(:alias_method, quackless, name)
      eval <<~Q # rubocop:disable Security/Eval,Style/EvalWithLocation
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
