# frozen_string_literal: true

class RecordNotFound < StandardError
  def initialize(msg = nil)
    super(msg)
  end
end
