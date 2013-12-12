module Rust
  class Param
    def initialize(node)
      @function_pointer = node[:function_pointer]

      if @function_pointer
        @type = node[:type]
        @t32 = FunctionPointer.new(@type, node, 32)
        @t64 = FunctionPointer.new(@type, node, 64)
      else
        @t32 = Type.decode(node[:type])
        @t64 = Type.decode(node[:type64])
      end
    end

    def encode_type(bitness)
      case bitness
      when 32
        @t32.encode_type
      when 64
        @t64.encode_type
      else
        raise 'unsupported bitness'
      end
    end
  end
  
  class Argument < Param
    def to_rust(name, bitness)
      case bitness
      when 32
        "#{name}:#{@t32.encode_type}"
      when 64
        "#{name}:#{(@t64 || @t32).encode_type}"
      else
        raise 'unsupported bitness'
      end
    end
  end

  class ReturnValue < Param
    def to_rust(bitness)
      case bitness
      when 32
        " -> #{@t32.encode_type}"
      when 64
        " -> #{@t64.encode_type}"
      else
        raise "Unsupported bitness"
      end
    end
  end

  class FunctionPointer
    attr_reader :type, :bitness, :arguments, :return_value

    def initialize(type, node, bitness)
      @type, @bitness = type, bitness

      r = node.at_xpath('./retval')

      @arguments = node.xpath('./arg').map { |arg| Argument.new(arg) }
      @return_value = r ? ReturnValue.new(r) : nil
    end

    def encode_type
      "extern fn (#{self.arguments.map { |arg| arg.encode_type(self.bitness) }.join(', ')})"
    end
  end

  class Function
    class << self
      def to_rust(fn, bitness)
        ret = fn.return_value ? fn.return_value.to_rust(bitness) : ''
        var = fn.variadic ? ['...'] : []
        "  fn #{fn.name}(#{(fn.arguments.map.with_index { |arg, i| arg.to_rust("a#{i}", bitness) } + var).join(', ')})#{ret};"
      end
    end

    attr_reader :name, :variadic, :inline
    attr_reader :arguments, :return_value

    def initialize(node)
      @name = node[:name]
      @variadic = node[:variadic] || false
      @inline = node[:inline] || false
      
      r = node.at_xpath('./retval')

      @arguments = node.xpath('./arg').map { |arg| Argument.new(arg) }
      @return_value = r ? ReturnValue.new(r) : nil
    end

    def to_rust
      if @inline
        raise "inline function"
      end

      string = ""
      if @t64
        string << "  " + Rust::TW32.encode_attribute + Function.to_rust(self, 32) if @t32
        string << "  " + Rust::TW64.encode_attribute + Function.to_rust(self, 64)
      else
        string << Function.to_rust(self, 32)
      end
      string
    end
  end
end