require 'abstractivator/enum'

class ErrorInfo
  define_enum :Code,
              :missing,            # the resource does not exist
              :missing_field,      # a required field on a resource has not been set ()
              :invalid,            # a parameter or the content of a POSTed document/field is invalid
              :unsupported,        # an unsupported message type, message version, or format was requested
              :already_exists      # another resource has the same unique key

  attr_reader :code      # [ErrorInfo::Code]  type of error
  attr_reader :resource  # [String]           the thing with the error
  attr_reader :field     # [String, Nil]      the location of the error within the resource
  attr_reader :value     # [Object, Nil]      the problematic data
  attr_reader :reason    # [Object, Nil]      an explanation of the error. usually a String.

  def initialize(code, resource, opts={})
    @code = canonical_code(code)
    @resource = resource
    @field = opts[:field] || ''
    @value = opts[:value] || ''
    @reason = opts[:reason] || ''
  end

  def as_json
    {
        'code' => code,
        'resource' => resource,
        'field' => field,
        'value' => value,
        'reason' => reason
    }
  end

  def self.from_attrs(attrs)
    code = attrs['code']
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
    x.is_a?(Symbol) ? Code.from_symbol(x) : x
  end
end
