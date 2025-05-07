module Auth
  class LoginService < BaseClass
    def initialize(params)
      super(params)
    end

    def self.generate_auth_token(user)
      jti = SecureRandom.hex(12)
      user.create_user_token(jti)

      payload = {user_id: user.id, jti: jti}
      token = JsonWebToken.encode(payload)
      token
    end

    def perform
      email = params[:email].presence
      raise ValidationError, 'Email is required' if email.blank?

      password = params[:password].presence
      raise ValidationError, 'Password is required' if password.blank?

      user = User.find_by(email: email)
      raise RecordNotFound, 'User not found' if user.blank?

      if user.authenticate(password)
        token = LoginService.generate_auth_token(user)
      else
        raise BadRequest, 'Password is incorrect'
      end

      [token, user]
    end
  end

end