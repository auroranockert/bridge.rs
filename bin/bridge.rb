require 'pp'

require 'treetop'
require 'nokogiri'

$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'types'

require 'enums'
require 'structs'
require 'opaques'
require 'functions'
require 'attributes'

Treetop.load "#{File.dirname(__FILE__)}/../lib/types"

BridgeSupport = Nokogiri::XML(File.read(ARGV[0]))

def encode_attributes(attributes)
  attributes.map do |attribute|
    "\#[#{attribute}]\n"
  end.join('')
end

def encode_function(fn, bitness, attributes)
  arguments = fn[:arguments].map.with_index do |argument, i|
    "a#{i}:#{argument[:type][bitness].encode_type}"
  end

  return_value = fn[:return_value] ? " -> #{fn[:return_value][:type][bitness].encode_type}" : ''

  encode_attributes(attributes) + "fn #{fn[:name]}(#{arguments})#{return_value};"
end

structs = BridgeSupport.xpath('/signatures/struct').map do |struct|
  Rust::Struct.new(struct).to_rust
end.join("\n")

opaques = BridgeSupport.xpath('/signatures/opaque').map do |opaque|
  Rust::Opaque.new(opaque).to_rust
end.join("\n")

enums = BridgeSupport.xpath('/signatures/enum').map do |enum|
  Rust::Enum.new(enum).to_rust
end.join("\n")

functions = BridgeSupport.xpath('/signatures/function').map do |function|
  begin
    f = Rust::Function.new(function)

    f.to_rust
  rescue => e
    begin
      "  // function #{f.name} is unsupported (#{e})"
    rescue
      raise e
    end
  end
end.join("\n")

frameworks = BridgeSupport.xpath('/signatures/depends_on/@path').map do |path|
  Rust::Attribute.new("link(name = \"#{path.content.split('/').last.split('.').first}\", kind = \"framework\"").encode_attribute
end

puts structs
puts
puts opaques
puts
puts enums
puts
puts frameworks
puts "extern {"
puts functions
puts "}"