Point = Struct.new(:x, :y)

FIXTURES = {
  'nil' => nil,
  'true' => true,
  'false' => false,
  'zero' => 0,
  'small positive number' => 10,
  'small negative number' => -10,
  'big positive number' => 99999,
  'big negative number' => -99999,
  'symbol' => :a_symbol,
  'string' => 'a string',
  'empty array' => [],
  'non-empty array' => [1,2,3],
  'empty hash' => {},
  'non-empty hash' => { 15 => 5 },
  'float' => 1.5,
  'class' => Array,
  'module' => Marshal,
  'struct' => Point.new(3, 7),
}
