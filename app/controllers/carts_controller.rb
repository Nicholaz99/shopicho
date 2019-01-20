class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :update, :destroy]
  before_action :authenticate_user, only: [:show, :update]
  before_action :is_checkout, only: [:update]

  # GET /carts
  def index
    @carts = Cart.where(user_id: @current_user.id)
    json_response(@carts)
  end

  # GET /carts/:id
  def show
    json_response(@cart)
  end

  # PUT /carts/:id
  def update
    # check if user has enough money to checkout the cart
    if @current_user.balance >= @cart.total_amount
      # check if items are not out of stock
      @cart.cart_items.each do |item|
        product = Product.find(item.product_id)
        json_response({ 'message': 'Some items are out of stock, please re-check your cart items' }, :method_not_allowed) unless product.inventory_count >= item.quantity
      end

      # process items
      @cart.cart_items.each do |item|
        product = Product.find(item.product_id).decrement!(:inventory_count, item.quantity)
      end

      # payment
      @current_user.decrement!(:balance, @cart.total_amount)

      # update cart's checkout status
      @cart.update_attribute(:checkout, true)

      # create a new cart for current user
      Cart.create!(user_id: @current_user.id)
      json_response({ 'message': 'Thank you for purchasing our products' })
    else
      json_response({ 'message': 'Insufficient balance' }, :method_not_allowed)
    end
  end

  private

  def authenticate_user
    json_response({ 'message': 'Not Authorized' }, :unauthorized) unless @current_user.id == @cart.user_id || @current_user.admin
  end

  def set_cart
    @cart = Cart.find(params[:id])
  end

  def is_checkout
    json_response({ 'message': 'This cart is already checkout' }, :forbidden) if @cart.checkout
  end
end
