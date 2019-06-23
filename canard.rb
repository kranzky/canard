module Canard
  class BadQuack < StandardError; end

  def configure
    # TODO
  end

  def self.included(klass)
    klass.send :extend, QuackSoftlyDriveAShermanTank
  end

  module QuackSoftlyDriveAShermanTank
    def method_added(method_name)
      Q.add_method(self, method_name)
    end
  end

  class RubberDuck
    def initialize
      @_quacks = Set.new
      @_references =
        Hash.new do |classes, klass|
          classes[klass] = Hash.new do |methods, method_name|
            methods[method_name] = Set.new
          end
        end
      @_definitions = nil
    end

    def <(name)
      require 'debug_inspector'
      parent =
        RubyVM::DebugInspector.open do |inspector|
          inspector.frame_binding(2).eval("self")
        end
      parent.class == Class ? _add_quack(name) : _run_quack(name)
      nil
    end

    def add_method(klass, method_name)
      return if @_quacks.empty? || method_name =~ /^_quackless_/
      quackless = "_quackless_#{method_name}"
      klass.send(:alias_method, quackless, method_name)
      klass.eval do
        define_method, method_name do |*args|
          puts "xxx"
        end
      end
      @_quacks.each do |quack|
        @_references[klass][method_name] << quack
      end
    ensure
      @_quacks.clear
    end
    
    private

    def _run_quack(name)
      case name
      when String
        # TODO
      else
        raise BadQuack, "expected string: #{name}"
      end
    end

    def _add_quack(name)
      case name
      when String
        @_quacks << name
      when Symbol
        _def_quack(name)
      else
        raise BadQuack, "expected string or symbol: #{name}"
      end
    end

    def _def_quack(name)
      # TODO
    end
  end

  Q = RubberDuck.new
end
