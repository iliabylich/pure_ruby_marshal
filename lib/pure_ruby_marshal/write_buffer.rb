class PureRubyMarshal::WriteBuffer
  attr_reader :object, :data

  def initialize(object)
    @object = object
    @data = "\x04\b" # '4.8' (version)
  end

  def write(current_object = object)
    case current_object
    when nil then write_nil
    when true then write_true
    when false then write_false
    when Fixnum
      append('i')
      write_fixnum(current_object)
    when String
      append('"')
      write_string(current_object)
    when Symbol
      append(':')
      write_symbol(current_object)
    when Array
      append('[')
      write_array(current_object)
    when Hash
      append('{')
      write_hash(current_object)
    when Float
      append('f')
      write_float(current_object)
    when Class
      append('c')
      write_class(current_object)
    when Module
      append('m')
      write_module(current_object)
    when Struct
      append('S')
      write_struct(current_object)
    when Regexp
      append('/')
      write_regexp(current_object)
    when Object
      append('o')
      write_object(current_object)
    else raise NotImplementedError
    end

    data
  end

  def append(s)
    @data += s
  end

  def write_nil
    append('0')
  end

  def write_true
    append('T')
  end

  def write_false
    append('F')
  end

  def write_fixnum(n)
    if n == 0
      append n.chr
    elsif n > 0 && n < 123
      append (n + 5).chr
    elsif n < 0 && n > -124
      append (256 + n - 5).chr
    else
      count = 0
      result = ""
      4.times do |i|
        b = n & 255
        result += b.chr
        n >>= 8
        count += 1
        break if n == 0 || n == -1
      end

      l_byte = n < 0 ? 256 - count : count

      append(l_byte.chr)
      append(result)
    end
  end

  def write_string(s)
    write_fixnum(s.length)
    append(s)
  end

  def write_symbol(sym)
    write_fixnum(sym.length)
    append(sym.to_s)
  end

  def write_array(a)
    write_fixnum(a.length)
    a.each { |item| write(item) }
  end

  def write_hash(hash)
    write_fixnum(hash.length)
    hash.each do |k, v|
      write(k)
      write(v)
    end
  end

  def write_float(f)
    write_string(f.to_s)
  end

  def write_class(klass)
    write_string(klass.name)
  end

  def write_module(mod)
    write_string(mod.name)
  end

  def write_struct(struct)
    write(struct.class.name.to_sym)
    hash = struct.members.zip(struct.values)
    write_hash(hash)
  end

  def write_regexp(regexp)
    write_string(regexp.source)
    write_fixnum(regexp.options)
  end

  def write_object(object)
    write(object.class.name.to_sym)
    ivar_data = object.instance_variables.map do |ivar_name|
      [ivar_name, object.instance_variable_get(ivar_name)]
    end
    ivar_data = Hash[ivar_data]
    write_hash(ivar_data)
  end
end
