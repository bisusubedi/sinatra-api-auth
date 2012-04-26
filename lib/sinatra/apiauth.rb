require 'sinatra'

module Sinatra::ApiAuth

  def self.registered(app)
    # Hang on to our application instance, so we can add settings later
    @@app = app
  end

  def api_auth_with(hash)

    @@app.set :api_auth, hash
  end

  # Sets the method used to perform authentication checks. The method must take
  # one argument, the token, and return a boolean.
  def api_auth_method(api_auth_method)
    @@app.set :api_auth_method, api_auth_method
  end

  # Sets the request parameter to use as the API token
  def api_auth_token(api_auth_token)
    @@app.set :api_auth_token, api_auth_token
  end

  # Require authentication for the given routes. If authentication fails, then
  # routing is halted and a 403 is returned. A 403 error handler can be added
  # to customize what exactly is returned.
  def requires_api_auth(*routes)
    routes.each do |route|
      before route do
        method = settings.api_auth[:method]
        token  = settings.api_auth[:token]

        if not send(method, request[token])
          logger.info "Authentication request for #{request.path_info} failed"
          halt 403
        else
          logger.info "Authentication request for #{request.path_info} succeeded"
        end
      end
    end
  end
end

module Sinatra
  register Sinatra::ApiAuth
end
