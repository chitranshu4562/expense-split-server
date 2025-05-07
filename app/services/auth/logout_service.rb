# frozen_string_literal: true

module Auth
  class LogoutService < CurrentUser
    def initialize(params, current_user, jti)
      super(params, current_user)
      @jti = jti
    end

    def perform
      user_id = params[:user_id].presence
      raise BadRequest, 'User id must be present.' if user_id.blank?

      raise BadRequest, 'Jti is required.' if @jti.blank?

      value = params[:is_global_logout].presence
      is_global_logout = value == 'true' ? true : false

      user_tokens = UserToken.where(user_id: user_id)
      unless is_global_logout
        user_tokens = user_tokens.where(jti: @jti)
      end

      user_tokens.destroy_all
    end
  end

end