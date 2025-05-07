class AuthController < ApplicationController
  def login
    login_service = Auth::LoginService.new(params)
    token, user = login_service.perform
    auth_response = {
      token: token,
      user: user,
    }
    render json: { data: auth_response, message: 'User is logged in successfully' }, status: :ok
  end

  def logout
    Auth::LogoutService.new(params, current_user, user_jti).perform
    render json: { message: 'User is logged out successfully' }, status: :ok
  end
end