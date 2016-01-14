class PureRubyMarshal::ReadBuffer
  attr_reader :data, :major_version, :minor_version

  def initialize(data)
    @data = data.split('')
    @major_version = read_byte
    @minor_version = read_byte
    @symbols_cache = []
    @objects_cache = []
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
    when 'f' then read_float
    when 'c' then read_class
    when 'm' then read_module
    when 'S' then read_struct
    when '/' then read_regexp
    when 'o' then read_object
    when 'C' then read_userclass
    when 'e' then read_extended_object
    when ';' then read_symbol_link
    when '@' then read_object_link
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

  def cache_object(&block)
    object = block.call
    @objects_cache << object
    object
  end

  def read_symbol
    symbol = read_integer.times.map { read_char }.join.to_sym
    @symbols_cache << symbol
    symbol
  end

  def read_string(cache: true)
    string = read_integer.times.map { read_char }.join
    @objects_cache << string if cache
    string
  end

  def read_array
    cache_object {
      read_integer.times.map { read }
    }
  end

  def read_hash(cache: true)
    pairs = read_integer.times.map { [read, read] }
    hash = Hash[pairs]
    @objects_cache << hash if cache
    hash
  end

  def read_float
    cache_object {
      read_string(cache: false).to_f
    }
  end

  def marshal_const_get(const_name)
    begin
      Object.const_get(const_name)
    rescue NameError
      raise ArgumentError, "undefined class/module #{const_name}"
    end
  end

  def read_class
    cache_object {
      const_name = read_string
      klass = marshal_const_get(const_name)
      unless klass.instance_of?(Class)
        raise ArgumentError, "#{const_name} does not refer to a Class"
      end
      klass
    }
  end

  def read_module
    cache_object {
      const_name = read_string
      klass = marshal_const_get(const_name)
      unless klass.instance_of?(Module)
        raise ArgumentError, "#{const_name} does not refer to a Module"
      end
      klass
    }
  end

  def read_struct
    cache_object {
      klass = marshal_const_get(read)
      attributes = read_hash(cache: false)
      values = attributes.values_at(*klass.members)
      klass.new(*values)
    }
  end

  def read_regexp
    cache_object {
      string = read_string
      kcode = read_byte
      Regexp.new(string, kcode)
    }
  end

  def read_object
    cache_object {
      klass = marshal_const_get(read)
      ivars_data = read_hash(cache: false)
      object = klass.allocate
      ivars_data.each do |ivar_name, value|
        object.instance_variable_set(ivar_name, value)
      end
      object
    }
  end

  def read_userclass
    cache_object {
      klass = marshal_const_get(read)
      data = read
      klass.new(data)
    }
  end

  def read_extended_object
    cache_object {
      mod = marshal_const_get(read)
      object = read
      object.extend(mod)
    }
  end

  def read_symbol_link
    @symbols_cache[read_integer]
  end

  def read_object_link
    @objects_cache[read_integer]
  end
end
