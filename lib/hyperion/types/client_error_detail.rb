require 'hyperion/types/client_error_code'

class ClientErrorDetail
  attr_reader :code      # [ClientErrorCode]            type of error
  attr_reader :resource  # [String]                     the thing with the error
  attr_reader :field     # [String, Nil]                the location of the error within the resource
  attr_reader :value     # [Object, Nil]                the problematic data
  attr_reader :reason    # [Object, Nil]                an explanation of the error. usually a String.

  def initialize(code, resource, opts={})
    @code = canonical_code(code)
    @resource = resource
    @field = opts[:field] || ''
    @value = opts[:value] || ''
    @reason = opts[:reason] || ''
  end

  def as_json
    {
        'code' => code.value,
        'resource' => resource,
        'field' => field,
        'value' => value,
        'reason' => reason
    }
  end

  def self.from_attrs(attrs)
    code = ClientErrorCode.from(attrs['code'])
    resource = attrs['resource']
    field = attrs['field']
    value = attrs['value']
    reason = attrs['reason']
    self.new(code, resource, field: field, value: value, reason: reason)
  end

  # make mongoid validations happy
  def to_s; reason; end
  def empty?; false; end

  private

  def canonical_code(x)
    x.is_a?(Symbol) ? ClientErrorCode.from_symbol(x) : ClientErrorCode.from(x)
  end
end
