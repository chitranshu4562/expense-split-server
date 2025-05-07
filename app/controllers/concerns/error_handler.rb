module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
    rescue_from RecordNotFound, with: :handle_record_not_found
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
    rescue_from ValidationError, with: :handle_validation_error
    rescue_from InvalidToken, with: :handle_invalid_token
    rescue_from BadRequest, with: :handle_bad_request
  end

  private
  def handle_record_not_found(exception)
    send_error_response(exception,404)
  end

  def handle_validation_error(exception)
    send_error_response(exception, 422)
  end

  def handle_invalid_token(exception)
    send_error_response(exception, 401)
  end

  def handle_bad_request(exception)
    send_error_response(exception, 400)
  end

  def send_error_response(exception, status)
    render json: { message: exception.message }, status: status
  end
end