module Rust
  class Enum
    class << self
      def to_rust(enum, value)
        enum.ignore ? '' : "static #{enum.name}:int = #{value};"
      end
    end

    attr_reader :name, :ignore

    def initialize(node)
      @name = node[:name]
      @ignore = node[:ignore] || false

      @v32 = node[:value]
      @v64 = node[:value64]
    end

    def to_rust
      string = ""
      if @t64
        string << Rust::TW32.encode_attribute + Enum.to_rust(self, @v32) if @v32
        string << Rust::TW64.encode_attribute + Enum.to_rust(self, @v64)
      else
        string << Enum.to_rust(self, @v32)
      end
      string
    end
  end
end