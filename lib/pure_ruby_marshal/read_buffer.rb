class PureRubyMarshal::ReadBuffer
  attr_reader :data, :major_version, :minor_version

  def initialize(data)
    @data = data.split('')
    @major_version = read_byte
    @minor_version = read_byte
  end

  def read_byte
    read_char.ord
  end

  def read_char
    data.shift
  end

  def read
    char = read_char
    case char
    when '0' then nil
    when 'T' then true
    when 'F' then false
    else
      raise NotImplementedError, "Unknown object type #{char}"
    end
  end
end
