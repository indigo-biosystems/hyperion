class HyperionError < StandardError
end

def hyperion_raise(msg)
  raise HyperionError, msg
end
