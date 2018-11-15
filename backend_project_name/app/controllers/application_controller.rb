class ApplicationController < ActionController::API
    #  lock program before anyhting happens
     before_action :authorized

 # make sure logged in !!
  def authorized
    render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
  end

    def encode_token(payload)
    # payload => { beef: 'steak' }
    JWT.encode(payload, 'my_s3cr3t')
    # jwt string: "eyJhbGciOiJIUzI1NiJ9.eyJiZWVmIjoic3RlYWsifQ._IBTHTLGX35ZJWTCcY30tLmwU9arwdpNVxtVU0NpAuI"
  end


  # instead of directly accessing token look at the header where it is
  def auth_header
      # { 'Authorization': 'Bearer <token>' }
      request.headers['Authorization']
    end

    # In other words, if our server receives a bad token,
    # this will raise an exception causing a 500 Internal Server Error.
     # We can account for this by rescuing out of this exception:
    def decoded_token
      if auth_header
          # 'Bearer <token>'.split second value is the token.
        token = auth_header.split(' ')[1]
        # headers: { 'Authorization': 'Bearer <token>' }
        begin
          JWT.decode(token, 'my_s3cr3t', true, algorithm: 'HS256')
          # JWT.decode => [{ "beef"=>"steak" }, { "alg"=>"HS256" }]
        rescue JWT::DecodeError
            # Instead of crashing our server, we simply return nil and keep trucking along.
          nil
        end
      end
    end

    def current_user
  if decoded_token
    # decoded_token=> [{"user_id"=>2}, {"alg"=>"HS256"}]
    # or nil if we can't decode the token
    user_id = decoded_token[0]['user_id']
    @user = User.find_by(id: user_id)
  end
end

def logged_in?
  !!current_user
end
end
