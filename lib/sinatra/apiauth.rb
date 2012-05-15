require 'sinatra'

module Sinatra::ApiAuth
  # Add REST endpoint protection using API keys. Given a method that takes
  # an API key as an argument and determines if that user is allowed access,
  # you can quickly wrap actions with auth.
  #
  # Example:
  #
  #   register Sinatra::ApiAuth
  #
  #   api_auth_with :method => :authenticate, :token => :token
  #   requires_api_auth '/my/protected/url', %r[/my/regex.*/url]


  def self.registered(app)
    # Hang on to our application instance, so we can add settings later
    @@app = app
  end

  # Register the method to be called that can provide authentication. The
  # method needs to be an instance method.
  def api_auth_with(hash)
    # TODO: validate input
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
    # TODO ensure that the method and token are defined and valid before the
    # before filters are added
    routes.each do |route|
      before route do
        method = settings.api_auth[:method]
        token  = settings.api_auth[:token]

        if not send(method, request[token])
          logger.debug "Authentication request for #{request.path_info} failed"
          halt 403
        else
          logger.debug "Authentication request for #{request.path_info} succeeded"
        end
      end
    end
  end
end

module Sinatra
  register Sinatra::ApiAuth
end
