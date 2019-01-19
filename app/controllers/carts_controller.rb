class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :update, :destroy]
  before_action :check_user, :is_checkout, only: [:update]

  # GET /carts
  def index
    @carts = Cart.where(user_id: @current_user.id)
    json_response(@carts)
  end

  # PUT /carts/:id
  def update
    total_payment = 0
    @cart.cart_items.each do |item|
      total_payment += item.price * item.quantity
    end

    puts total_payment
    puts '----------------------'

    if @current_user.balance >= total_payment
      @current_user.decrement!(:balance, total_payment)
      @cart.cart_items.each do |item|
        Product.find(item.product_id).decrement!(:inventory_count, item.quantity)
      end
      @cart.update_attribute(:checkout, true)
      Cart.create!(user_id: @current_user.id)
      json_response({ 'message': 'Thank you for purchasing our products' })
    else
      json_response({ 'message': 'Insufficient balance' }, :method_not_allowed)
    end
  end

  private

  def check_user
    json_response({ 'message': 'Not Authorized' }, :unauthorized) unless @current_user.id == @cart.user_id
  end

  def set_cart
    @cart = Cart.find_by(id: params[:id], user_id: @current_user.id)
  end

  def is_checkout
    json_response({ 'message': 'This cart is already checkout' }, :forbidden) if @cart.checkout
  end
end
