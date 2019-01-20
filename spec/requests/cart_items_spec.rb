require 'rails_helper'

RSpec.describe 'Cart Items API', type: :request do
  # initialize test data with Faker 
  let!(:products) { create_list(:product, 100) }
  let!(:users) { create_list(:user, 10) }
  let!(:cart) { create(:cart, user_id: users.first.id) }
  let!(:cart_items) { create_list(:cart_item, 3, cart_id: cart.id)}
  let!(:dummy_cart) { create(:cart, user_id: users.second.id) }
  let!(:cart_id) { cart.id }
  let!(:cart_item_id) { cart_items.first.id }
  let!(:checkout_cart) { create(:cart, :checkout, user_id: users.first.id) }
  let!(:checkout_cart_id) { checkout_cart.id }
  let(:cart_email) { cart.email }
  let(:cart_password) { 'iwantinternship' }
  let(:auth_token) { JsonWebToken.encode(user_id: users.first.id) }
  let(:dummy_auth_token) { JsonWebToken.encode(user_id: 1) }

  # create fake admin with Faker
  let!(:admin) { create(:user, :admin) }
  let(:admin_id) { admin.id }
  let(:admin_token) { JsonWebToken.encode(user_id: admin_id) }

  # Test suite for GET /carts/:cart_id/cart_items
  describe 'GET /carts/:cart_id/cart_items' do
    # make HTTP get request before each example
    let(:header) {}
    before { get "/carts/#{cart_id}/cart_items", headers: header }

    context 'when the request does not have header auth' do
      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(response.body).to match(/Missing token/)
      end
    end

    context 'when the request does not have valid token' do
      let(:header) { { 'Authorization' => 'asdasdasdsadas' } }
      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(response.body).to match(/Invalid token/)
      end
    end

    context 'when the request have valid token' do
      let(:header) { { 'Authorization' => auth_token } }
      it 'returns list of all current cart items' do
        # check json responses
        expect(json).not_to be_empty
        expect(json.size).to eq(3)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end

  # Test suite for GET /carts/:cart_id/cart_items/:id
  describe 'GET /carts/:cart_id/cart_items/:id' do
    let(:header) {}
    before { get "/carts/#{cart_id}/cart_items/#{cart_item_id}", headers: header }

    context 'when the request does not have header auth' do
      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(response.body).to match(/Missing token/)
      end
    end

    context 'when the request does not have valid token' do
      let(:header) { { 'Authorization' => 'asdasdasdsadas' } }
      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not authorized message' do
        expect(response.body).to match(/Invalid token/)
      end
    end

    context 'when the request have valid token' do
      let(:header) { { 'Authorization' => auth_token } }
      context ', the cart exists' do
        context ', it is the current user cart id' do
          context ', and the cart item belongs to current cart' do
            it 'returns the cart item detail' do
              expect(json).not_to be_empty
              expect(json['id']).to eq(cart_item_id)
            end
    
            it 'returns status code 200' do
              expect(response).to have_http_status(200)
            end
          end

          context ', and the cart item does not exist on current cart' do
            let(:cart_item_id) { 150 }
            it 'returns not found message' do
              expect(response.body).to match(/Couldn't find CartItem/)
            end
    
            it 'returns status code 404' do
              expect(response).to have_http_status(404)
            end
          end
        end
      end
    end
  end
end