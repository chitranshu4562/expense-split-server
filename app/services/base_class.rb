# frozen_string_literal: true

class BaseClass
  attr_reader :params
  def initialize(params)
    @params = params
  end
end
