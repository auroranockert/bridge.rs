module Rust
  class Opaque
    class << self
      def to_rust(name, type)
        "type #{name} = #{type.encode_type};"
      end
    end

    attr_reader :name

    def initialize(node)
      @name = node[:name]
      
      @t32 = Type.decode(node[:type])
      @t64 = Type.decode(node[:type64])
    end

    def to_rust
      string = ""
      if @t64
        string << Rust::TW32.encode_attribute + Opaque.to_rust(@name, @t32) if @t32
        string << Rust::TW64.encode_attribute + Opaque.to_rust(@name, @t64)
      else
        string << Opaque.to_rust(@name, @t32)
      end
      string
    end
  end
end