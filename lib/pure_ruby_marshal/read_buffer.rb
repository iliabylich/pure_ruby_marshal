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
    when ':' then read_symbol
    when '"' then read_string
    when 'I' then read
    when '[' then read_array
    when '{' then read_hash
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

  def read_symbol
    read_integer.times.map { read_char }.join.to_sym
  end

  def read_string
    read_integer.times.map { read_char }.join
  end

  def read_array
    read_integer.times.map { read }
  end

  def read_hash
    pairs = read_integer.times.map { [read, read] }
    Hash[pairs]
  end
end
