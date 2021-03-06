class CartItemsController < ApplicationController
  before_action :set_cart
  before_action :is_checkout, only: [:create, :update, :destroy]
  before_action :check_product_stock, only: [:create]
  before_action :set_cart_item, only: [:show, :update, :destroy]
  before_action :check_cart_item_stock, only: [:update]

  # GET /carts/:cart_id/cart_items
  def index
    json_response(@cart.cart_items)
  end

  # GET /carts/:cart_id/cart_items/:id
  def show
    json_response(@cart_item)
  end

  # POST /carts/:cart_id/cart_items
  def create
    item = CartItem.find_by(cart_id: params[:cart_id], product_id: params[:product_id])
    # if such item has already existed on your cart
    if item
      product = Product.find(params[:product_id])
      if item.quantity + params[:quantity].to_i <= product.inventory_count
        curr_total = @cart.total_amount
        old_item_total = item.quantity * item.price
        item.increment!(:quantity, params[:quantity].to_i)
        new_item_total = item.quantity * item.price
        @cart.update_attribute(:total_amount, curr_total - old_item_total + new_item_total)
        json_response({ 'message': 'Cart Item is updated' })
      else
        json_response({ 'message': 'The product quantity is not that much' })
      end
    else
      @cart.cart_items.create!(cart_item_params)
      @cart.increment!(:total_amount, params[:quantity].to_i * Product.find(params[:product_id]).price)
      json_response({ 'message': 'Cart Item is added to the cart' }, :created)
    end
  end

  # PUT /carts/:cart_id/cart_items/:id
  def update
    curr_total = @cart.total_amount
    old_item_total = @cart_item.quantity * @cart_item.price
    @cart_item.update!(update_cart_item_params)
    new_item_total = @cart_item.quantity * @cart_item.price
    @cart.update_attribute(:total_amount, curr_total - old_item_total + new_item_total)
    json_response({ 'message': 'Cart Item is updated' })
  end

  # DELETE /carts/:cart_id/cart_items/:id
  def destroy
    @cart.decrement!(:total_amount, @cart_item.quantity * @cart_item.price)
    @cart_item.destroy
    json_response({ 'message': 'Cart Item is deleted' })
  end

  private

  def cart_item_params
    price = Product.find(params[:product_id]).price
    params.merge(:price => price)
    params.require(:cart_item).permit(:cart_id, :product_id, :quantity).merge(:price => price)
  end

  def update_cart_item_params
    params.permit(:quantity)
  end

  def is_checkout
    json_response({ 'message': 'This cart is already checkout' }, :forbidden) if @cart.checkout
  end

  def check_stock(quantity, param_quantity)
    if quantity == 0
      json_response({ 'message': 'Product is out of stock' }, :method_not_allowed)
    elsif param_quantity == 0
      json_response({ 'message': 'Cart Item quantity minimum is 1' }, :method_not_allowed)
    elsif quantity < param_quantity
      json_response({ 'message': 'The product quantity is not that much' }, :method_not_allowed) 
    end
  end

  def check_product_stock
    quantity = Product.find(params[:product_id]).inventory_count
    param_quantity = params[:quantity].to_i
    check_stock(quantity, param_quantity)
  end

  def check_cart_item_stock
    quantity = Product.find(@cart_item.product_id).inventory_count
    param_quantity = params[:quantity].to_i
    check_stock(quantity, param_quantity)
  end

  def set_cart
    @cart = Cart.find(params[:cart_id])
  end

  def set_cart_item
    @cart_item = @cart.cart_items.find_by!(id: params[:id]) if @cart
  end
end
