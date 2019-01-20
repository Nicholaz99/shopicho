require 'rails_helper'

RSpec.describe 'Carts API', type: :request do
  # initialize test data with Faker 
  let!(:users) { create_list(:user, 10) }
  let!(:cart) { create(:cart, user_id: users.first.id) }
  let!(:dummy_cart) { create(:cart, user_id: users.second.id) }
  let!(:cart_id) { cart.id }
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

  # Test suite for GET /carts
  describe 'GET /carts' do
    # make HTTP get request before each example
    let(:header) {}
    before { get '/carts', headers: header }

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
      it 'returns list of all current cart carts' do
        # check json responses
        expect(json).not_to be_empty
        expect(json.size).to eq(2)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
  end

  # Test suite for GET /carts/:id
  describe 'GET /carts/:id' do
    let(:header) {}
    before { get "/carts/#{cart_id}", headers: header }

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
        context ', and it is the current user cart id' do
          it 'returns the cart detail' do
            expect(json).not_to be_empty
            expect(json['id']).to eq(cart_id)
          end
  
          it 'returns status code 200' do
            expect(response).to have_http_status(200)
          end
        end

        context ', and it is not the current user cart id' do
          let(:cart_id) { 2 }
          let(:header) { { 'Authorization' => dummy_auth_token } }
          it 'returns a not authorized message' do
            expect(response.body).to match(/Not Authorized/)
          end
  
          it 'returns status code 401' do
            expect(response).to have_http_status(401)
          end
        end

        context ', and the current user is admin' do
          let(:header) { { 'Authorization' => admin_token } }
          let(:cart_id) { 2 }
          it 'returns the cart detail' do
            expect(json).not_to be_empty
            expect(json['id']).to eq(cart_id)
          end
  
          it 'returns status code 200' do
            expect(response).to have_http_status(200)
          end
        end
      end

      context 'and the cart does not exist' do
        let(:cart_id) { 100 }
  
        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end
  
        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Cart/)
        end
      end
    end
  end

  # Test suite for PUT /carts/:id
  describe 'PUT /carts/:id' do
    # let(:attributes) { { name: 'Shopify' } }
    let(:header) {}
    before { put "/carts/#{cart_id}", headers: header }

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
      let(:cart_id) { checkout_cart_id }
      context ', the cart exists' do
        context ', it is the current user cart id' do
          context ', and the cart has been checkout' do
            it 'returns forbidden message' do
              expect(response.body).to match(/This cart is already checkout/)
            end
    
            it 'returns status code 403' do
              expect(response).to have_http_status(403)
            end
          end
        end

        context ', and it is not the current user cart id' do
          let(:cart_id) { dummy_cart.id }
          let(:header) { { 'Authorization' => dummy_auth_token } }
          it 'returns a not authorized message' do
            expect(response.body).to match(/Not Authorized/)
          end
  
          it 'returns status code 401' do
            expect(response).to have_http_status(401)
          end
        end
      end

      context 'and the cart does not exist' do
        let(:cart_id) { 100 }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find Cart/)
        end
      end
    end
  end
end