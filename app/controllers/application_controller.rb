class ApplicationController < ActionController::API
  include ErrorHandler
  attr_reader :current_user, :user_jti
  before_action :authenticate_request, except: [:login, :create_user]

  private
  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    unless token.present?
      raise BadRequest, 'Token is missing'
    end

    decoded_token = JsonWebToken.decode(token)
    jti = decoded_token[:jti]

    user_token = UserToken.find_by(jti: jti)
    raise RecordNotFound, 'User is already logged out' if user_token.nil?

    @current_user = user_token.user
    @user_jti = jti
  end
end
