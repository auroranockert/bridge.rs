module Type
  class << self
    def decode(type)
      TypeParser.new.parse(type) if type
    end
  end

  module I8
    def encode_type
      "i8"
    end
  end

  module I16
    def encode_type
      "i16"
    end
  end

  module I32
    def encode_type
      "i32"
    end
  end

  module I64
    def encode_type
      "i64"
    end
  end

  module U8
    def encode_type
      "u8"
    end
  end

  module U16
    def encode_type
      "u16"
    end
  end

  module U32
    def encode_type
      "u32"
    end
  end

  module U64
    def encode_type
      "u64"
    end
  end

  module F32
    def encode_type
      "f32"
    end
  end

  module F64
    def encode_type
      "f64"
    end
  end

  module Bool
    def encode_type
      "bool"
    end
  end

  module Array
    def encode_type
      "*#{type.encode_type}" # TODO: Can this be a slice or type checked?
    end
  end

  module Void
    def encode_type
      "libc::c_void"
    end
  end

  module CString
    def encode_type
      "*libc::c_char"
    end
  end

  module ClassObject
    def encode_type
      "*libc::c_void"
    end
  end

  module Selector
    def encode_type
      "*libc::c_void"
    end
  end

  module Object
    def encode_type
      "*libc::c_void"
    end
  end

  module Bitfield
    def encode_type
      raise "Bitfields are currently unsupported"
    end
  end

  module Pointer
    def encode_type
      "*#{type.encode_type}"
    end
  end

  module Unknown
    def encode_type
      "libc::c_void"
    end
  end

  module Struct
    def name
      string.to_s
    end

    def encode_type
      self.name
    end

    def encode_struct
      "struct #{self.name} {\n" + t.members.elements.map.with_index do |member, i|
        "  #{member.name || "m#{i}"}: #{member.type.encode_type}"
      end.join(",\n")+ "\n}\n"
    end
  end
  
  module StructMember
    def name
      n.to_s unless n.empty?
    end

    def type
      type
    end
  end
end