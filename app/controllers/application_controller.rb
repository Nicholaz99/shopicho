class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler

  before_action :authenticate_request
  attr_reader :current_user

  private

  def authenticate_request
    command = AuthorizeApiRequest.call(request.headers)
    @current_user = command.result
    json_response({ message: 'Not Authorized', error: command.errors }, :unauthorized) unless @current_user
  end

  def authenticate_admin
    @current_user = AuthorizeApiRequest.call(request.headers).result
    json_response({ message: 'Only admin is authorized' }, :unauthorized) unless @current_user.admin?
  end
end
