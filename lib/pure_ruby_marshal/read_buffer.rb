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
    when 'i' then read_integer
    else
      raise NotImplementedError, "Unknown object type #{char}"
    end
  end

  def read_integer
    # c is our first byte
    c = (read_byte ^ 128) - 128

    if c == 0
      # 0 means 0
      0
    elsif c > 0
      if 4 < c && c < 128
        # case for small numbers
        c - 5
      else
        # otherwise c next bytes is our number
        c.
          times.
          map { |i| [i, read_byte] }.
          inject(0) { |result, (i, byte)| result | (byte << (8*i))  }
      end
    else
      if -129 < c && c < -4
        # case for small numbers
        c + 5
      else
        # (-c) next bytes os our number
        (-c).
          times.
          map { |i| [i, read_byte] }.
          inject(-1) do |result, (i, byte)|
            a = ~(0xff << (8*i))
            b = byte << (8*i)
            (result & a) | b
          end
      end
    end
  end
end
