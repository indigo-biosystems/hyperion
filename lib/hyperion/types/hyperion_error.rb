class HyperionError < RuntimeError
end

def hyperion_raise(msg)
  raise HyperionError, msg
end
