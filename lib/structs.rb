module Rust
  class Struct
    attr_reader :name, :opaque

    def initialize(node)
      @name = node[:name]
      @opaque = node[:opaque] || false
      
      @t32 = Type.decode(node[:type])
      @t64 = Type.decode(node[:type64])
    end

    def to_rust
      string = ""
      if @t64
        string << Rust::TW32.encode_attribute + @t32.encode_struct + "\n" if @t32
        string << Rust::TW64.encode_attribute + @t64.encode_struct
      else
        string << @t32.encode_struct
      end
      string
    end
  end
end