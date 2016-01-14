require "pure_ruby_marshal/version"

module PureRubyMarshal
  extend self

  autoload :ReadBuffer,  'pure_ruby_marshal/read_buffer'
  autoload :WriteBuffer, 'pure_ruby_marshal/read_buffer'
  MAJOR_VERSION = 4
  MINOR_VERSION = 8

  def dump(object)
    WriteBuffer.new(object).write
  end

  def load(data)
    ReadBuffer.new(data).read
  end
end

include PureRubyMarshal
