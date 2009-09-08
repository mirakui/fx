
class RingBuffer
  def initialize(size)
    @buffer = Array.new(size)
    @head = 0
  end

  def <<(obj)
    @buffer[@head] = obj
    @head = (@head + 1) % @buffer.size
  end

  def [](index)
    @buffer[(@head + index) % @buffer.size]
  end

  def []=(index, obj)
    self[index] = obj
  end

  def differential
    dif = 0
    (@buffer.size-1).times do |i|
      dif += (self[i+1]||0) - (self[i]||0)
    end
    dif
  end

  def to_a
    @buffer[@head..@buffer.size] + @buffer[0,@head]
  end
end

__END__

b = RingBuffer.new(5)
b << 1
b << 2
b << 3
b << 4
p b.differential


