class Lazy < BasicObject
  def initialize(&make)
    @make = make
  end

  def ensure_obj
    if @make
      @obj = @make.call
      @make = nil
    end
    @obj
  end

  def method_missing(method, *args, &block)
    ensure_obj.send(method, *args, &block)
  end

  def ==(other)
    ensure_obj == other
  end

  def !=(other)
    ensure_obj != other
  end

  def !
    !ensure_obj
  end

  def inspect
    "#<Lazy:#{@make ? '' : @obj.class.name + ':'}0x#{__id__.to_s(16)}>"
  end
end

module Kernel
  private
  def lazy(&block)
    Lazy.new(&block)
  end
end
