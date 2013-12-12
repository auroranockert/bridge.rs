module Rust
  class Attribute
    def initialize(value)
      @value = value
    end

    def encode_attribute
      "\#[#{@value}]\n"
    end
  end

  TW32 = Attribute.new('cfg(target_word_size = "32")')
  TW64 = Attribute.new('cfg(target_word_size = "64")')
end