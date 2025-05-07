# frozen_string_literal: true

class BadRequest < StandardError
  def initialize(msg = '')
    super(msg)
  end
end
