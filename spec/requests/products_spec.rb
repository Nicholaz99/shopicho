require 'rails_helper'

RSpec.describe 'Products API', type: :request do
  # initialize test data with Faker 
  let!(:products) { create_list(:product, 10) }
  let(:product_id) { products.first.id }

  # Test suite for GET /products
  describe 'GET /products' do
    # make HTTP get request before each example
    before { get '/products' }

    it 'returns list of all products' do
      # check json responses
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /products/:id
  describe 'GET /products/:id' do
    before { get "/products/#{product_id}" }

    context 'when the product exists' do
      it 'returns the product detail' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(product_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the product does not exist' do
      let(:product_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Product/)
      end
    end
  end

  # Test suite for POST /products
  describe 'POST /products' do
    # valid payload
    let(:valid_attributes) { { title: 'Learn Elm', price: '130.55', inventory_count: '15' } }

    context 'when the request is valid' do
      before { post '/products', params: valid_attributes }

      it 'creates a new product' do
        expect(json['title']).to eq('Learn Elm')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/products', params: { title: 'Foobar', inventory_count: '1' } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/Validation failed: Price can't be blank/)
      end
    end
  end

  # Test suite for PUT /products/:id
  describe 'PUT /products/:id' do
    let(:valid_attributes) { { title: 'Shopping' } }

    context 'when the product exists' do
      before { put "/products/#{product_id}", params: valid_attributes }

      it 'updates the product' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  # Test suite for DELETE /products/:id
  describe 'DELETE /products/:id' do
    before { delete "/products/#{product_id}" }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end