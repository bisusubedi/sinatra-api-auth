require 'sinatra'

module Sinatra::ApiAUth

  def self.registered(app)
    # Hang on to our application instance, so we can add settings later
    @app = app
  end

  # Sets the method used to perform authentication checks. The method must take
  # one argument, the token, and return a boolean.
  def api_auth_method(api_auth_method)
    @app.set :api_auth_method, auth_method
  end

  # Sets the request parameter to use as the API token
  def api_auth_token(api_auth_token)
    @app.set :api_auth_token
  end

  # Require authentication for the given routes. If authentication fails, then
  # routing is halted and a 403 is returned. A 403 error handler can be added
  # to customize what exactly is returned.
  def requires_api_auth(*routes)
    routes.each do |route|
      before route do
        method = settings[:api_auth_method]
        token  = settings[:api_auth_token]

        if not send(method, token)
          halt 403
        end
      end
    end
  end
end

module Sinatra
  register Sinatra::ApiAuth
end
