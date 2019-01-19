require 'rails_helper'

RSpec.describe 'Products API', type: :request do
  # initialize test data with Faker 
  let!(:products) { create_list(:product, 10) }
  let(:product_id) { products.first.id }

  # create fake login data with Faker 
  let!(:user) { create(:user) }
  let!(:admin) { create(:user, :admin) }
  let(:user_id) { user.id }
  let(:admin_id) { admin.id }
  let(:auth_token) { JsonWebToken.encode(user_id: user_id) }
  let(:admin_token) { JsonWebToken.encode(user_id: admin_id) }

  # Test suite for GET /products
  describe 'GET /products' do
    # make HTTP get request before each example
    let(:header) {}
    before { get '/products', headers: header }

    context 'when the request does not have header auth' do
      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(response.body).to match(/Validation failed: Missing token/)
      end
    end

    context 'when the request does not have valid token' do
      let(:header) { { 'Authorization' => 'asdasdasdsadas' } }
      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(response.body).to match(/Validation failed: Invalid token/)
      end
    end

    context 'when the request have valid token' do
      let(:header) { { 'Authorization' => auth_token } }
      it 'returns list of all products' do
        # check json responses
        expect(json).not_to be_empty
        expect(json.size).to eq(10)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end

  # Test suite for GET /products/:id
  describe 'GET /products/:id' do
    let(:header) {}
    before { get "/products/#{product_id}", headers: header }

    context 'when the request does not have header auth' do
      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(response.body).to match(/Validation failed: Missing token/)
      end
    end

    context 'when the request does not have valid token' do
      let(:header) { { 'Authorization' => 'asdasdasdsadas' } }
      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(response.body).to match(/Validation failed: Invalid token/)
      end
    end

    context 'when the request have valid token' do
      let(:header) { { 'Authorization' => auth_token } }
      context 'and the product exists' do
        it 'returns the product detail' do
          expect(json).not_to be_empty
          expect(json['id']).to eq(product_id)
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
      end

      context 'and the product does not exist' do
        let(:product_id) { 100 }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Product/)
        end
      end
    end
  end

  # Test suite for POST /products
  describe 'POST /products' do
    # valid payload
    let(:valid_attributes) { { title: 'Learn Elm', price: '130.55', inventory_count: '15' } }
    let(:header) {}
    before { post '/products', params: valid_attributes, headers: header }

    context 'when the request does not have header auth' do
      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(response.body).to match(/Validation failed: Missing token/)
      end
    end

    context 'when the request does not have valid token' do
      let(:header) { { 'Authorization' => 'asdasdasdsadas' } }
      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(response.body).to match(/Validation failed: Invalid token/)
      end
    end

    context 'when the request have valid token' do
      let(:header) { { 'Authorization' => auth_token } }
      context 'and the user is not an admin' do
        it 'returns status code 401' do
          expect(response).to have_http_status(401)
        end
  
        it 'returns only admin message' do
          expect(response.body).to match(/Only admin is authorized/)
        end
      end

      context ', the user is admin' do
        let(:header) { { 'Authorization' => admin_token } }
        context ', and the request is valid' do
          it 'creates a new product' do
            expect(json['title']).to eq('Learn Elm')
          end
  
          it 'returns status code 201' do
            expect(response).to have_http_status(201)
          end
        end

        context ', and the request is invalid' do
          let(:valid_attributes) { { title: 'Learn Elm Third Ed', inventory_count: '15' } }
          it 'returns status code 422' do
            expect(response).to have_http_status(422)
          end
  
          it 'returns a validation failure message' do
            expect(response.body)
              .to match(/Validation failed: Price can't be blank/)
          end
        end
      end
    end
  end

  # Test suite for PUT /products/:id
  describe 'PUT /products/:id' do
    let(:valid_attributes) { { title: 'Shopping' } }
    let(:header) {}
    before { put "/products/#{product_id}", params: valid_attributes, headers: header }

    context 'when the request does not have header auth' do
      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(response.body).to match(/Validation failed: Missing token/)
      end
    end

    context 'when the request does not have valid token' do
      let(:header) { { 'Authorization' => 'asdasdasdsadas' } }
      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(response.body).to match(/Validation failed: Invalid token/)
      end
    end

    context 'when the request have valid token' do
      let(:header) { { 'Authorization' => auth_token } }
      context 'and the user is not an admin' do
        it 'returns status code 401' do
          expect(response).to have_http_status(401)
        end
  
        it 'returns only admin message' do
          expect(response.body).to match(/Only admin is authorized/)
        end
      end

      context ', the user is admin' do
        let(:header) { { 'Authorization' => admin_token } }
        context ', and the item exists' do
          it 'returns status code 204' do
            expect(response).to have_http_status(204)
          end
    
          it 'updates the item' do
            updated_product = Product.find(product_id)
            expect(updated_product.title).to match(/Shopping/)
          end
        end

        context ', and the item does not exist' do
          let(:product_id) { 0 }
          it 'returns status code 404' do
            expect(response).to have_http_status(404)
          end

          it 'returns a not found message' do
            expect(response.body).to match(/Couldn't find Product/)
          end
        end
      end
    end
  end

  # Test suite for DELETE /products/:id
  describe 'DELETE /products/:id' do
    let(:header) {}
    before { delete "/products/#{product_id}", headers: header }

    context 'when the request does not have header auth' do
      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(response.body).to match(/Validation failed: Missing token/)
      end
    end

    context 'when the request does not have valid token' do
      let(:header) { { 'Authorization' => 'asdasdasdsadas' } }
      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(response.body).to match(/Validation failed: Invalid token/)
      end
    end

    context 'when the request have valid token' do
      let(:header) { { 'Authorization' => auth_token } }
      context 'and the user is not an admin' do
        it 'returns status code 401' do
          expect(response).to have_http_status(401)
        end
  
        it 'returns only admin message' do
          expect(response.body).to match(/Only admin is authorized/)
        end
      end

      context ', the user is admin' do
        let(:header) { { 'Authorization' => admin_token } }
        it 'returns status code 204' do
          expect(response).to have_http_status(204)
        end
      end
    end
  end
end