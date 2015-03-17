require 'abstractivator/enum'

define_enum :HyperionStatus,
            :success,
            :timed_out,
            :no_response,
            :bad_route,        # 404 (route not implemented)
            :client_error,     # 400
            :server_error,     # 500
            :check_code        # everything else
