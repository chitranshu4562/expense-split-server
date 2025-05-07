class UsersController < ApplicationController
  def create_user
    name = params[:name].presence
    raise ValidationError, 'Name must be present' unless name.present?

    password = params[:password].presence
    raise ValidationError, 'Password must be present' unless password.present?

    email = params[:email].presence
    raise ValidationError, 'Email must be present' unless email.present?

    user = User.new(name: name, password: password)
    user.email = email if email.present?
    user.save!

    token = Auth::LoginService.generate_auth_token(user)
    auth_response = {
      token: token,
      user: user
    }

    render json: { data: auth_response, message: 'User is signed up successfully' }, status: :created
  end

  def fetch_users
    query = params[:query].presence

    users = User.all
    users = users.where("name ILIKE :query OR email ILIKE :query", query: "%#{query}%") if query.present?

    users_data = users.select(:id, :name)
    render json: { data: users_data, message: 'Users is fetched successfully' }, status: :ok
  end
end