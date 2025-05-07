# frozen_string_literal: true

class CurrentUser < BaseClass
  attr_reader :current_user
  def initialize(params, current_user)
    @current_user = current_user
    super(params)
  end
end
