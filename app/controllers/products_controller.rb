class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :update, :destroy]
  before_action :authenticate_admin, only: [:create, :update, :destroy]

  # GET /products
  def index
    @products = Product.where(Product.arel_table[:inventory_count].gt(0)).all
    json_response(@products)
  end

  # POST /products
  def create
    @product = Product.create!(product_params)
    json_response(@product, :created)
  end

  # GET /products/:id
  def show
    json_response(@product)
  end

  # PUT /products/:id
  def update
    @product.update!(product_params)
    json_response({ 'message': 'Product is updated' })
  end

  # DELETE /products/:id
  def destroy
    @product.destroy
    json_response({ 'message': 'Product is deleted' })
  end

  private

  def product_params
    # whitelist params
    params.permit(:title, :price, :inventory_count)
  end

  def set_product
    @product = Product.find(params[:id])
  end
end
