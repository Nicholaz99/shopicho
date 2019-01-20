class UsersController < ApplicationController
  before_action :set_user, :authenticate_user, only: [:show, :update, :destroy]
  before_action :authenticate_admin, only: [:index]
  skip_before_action :authenticate_request, only: [:create]
  wrap_parameters include: controller_name.singularize.classify.safe_constantize.attribute_names + [ :password, :password_confirmation]

  # GET /users
  def index
    @users = User.all
    json_response(@users)
  end

  # POST /users
  def create
    @user = User.create!(user_params)
    json_response({ 'message': 'Your account is successfully registered', 'user': @user }, :created)
  end

  # GET /users/:id
  def show
    json_response(@user)
  end

  # PUT /users/:id
  def update
    @user.update!(user_params)
    json_response({ 'message': 'Your profile is updated', 'user': @user })
  end

  # DELETE /users/:id
  def destroy
    @user.destroy
    json_response({ 'message': 'Your account is deleted' })
  end

  private

  def user_params
    # whitelist params
    params.require(:user).permit(:name, :email, :balance, :password, :password_confirmation)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def authenticate_user
    json_response({ 'message': 'Not Authorized' }, :unauthorized) unless @user.id == @current_user.id || @current_user.admin
  end
end
