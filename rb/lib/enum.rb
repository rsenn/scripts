class Enum

  @@names = []

  private

  def self.enum_attr(name, num = nil)
    name = name.to_s

    if num === nil then
      num = @@names.length
    end

    define_method(name + '?') do
      @value == num
    end

    define_method(name) do
      @value = num
    end

    define_method(name + '=') do |set|
      if set
        @value = num
      else
        @value = nil
      end
    end

    @@names[num] = name
  end

  public

  def initialize(num = nil)
    if num.instance_of? Symbol then
      num = num.to_s
    end
    if num.instance_of? Numeric then
      @value = Integer.new num
    elsif num.instance_of? String and num.size > 0 then
      self.method(num).call
    else
      @value = nil
    end
  end

  def to_i
    @value
  end

  def to_s
    @@names[@value]
  end

  def to_sym
    to_s.to_sym
  end
end