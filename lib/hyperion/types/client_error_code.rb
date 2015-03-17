require 'abstractivator/enum'

define_enum :ClientErrorCode,
            :missing,            # the resource does not exist
            :missing_field,      # a required field on a resource has not been set ()
            :invalid,            # a parameter or the content of a POSTed document/field is invalid
            :unsupported,        # an unsupported message type, message version, or format was requested
            :already_exists,     # another resource has the same unique key
            :unknown             # something else
