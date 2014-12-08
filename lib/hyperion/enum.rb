module Enum
  def values
    self.constants.map { |sym| self.const_get(sym) }
  end
end