module ApplicationHelper
  def extract_token_from_request(request)
    request.headers['Authorization'].split(' ').last
  end
end