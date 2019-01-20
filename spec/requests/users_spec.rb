require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  # initialize test data with Faker 
  let!(:users) { create_list(:user, 10) }
  let(:user_id) { users.first.id }
  let(:auth_token) { JsonWebToken.encode(user_id: user_id) }
  let(:dummy_auth_token) { JsonWebToken.encode(user_id: 1) }

  # create fake admin with Faker
  let!(:admin) { create(:user, :admin) }
  let(:admin_id) { admin.id }
  let(:admin_token) { JsonWebToken.encode(user_id: admin_id) }

  # Test suite for GET /users
  describe 'GET /users' do
    # make HTTP get request before each example
    let(:header) {}
    before { get '/users', headers: header }

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
          it 'returns list of all users' do
            # check json responses
            expect(json).not_to be_empty
            expect(json.size).to eq(11)
          end
    
          it 'returns status code 200' do
            expect(response).to have_http_status(200)
          end
        end
      end
    end
  end

  # Test suite for GET /users/:id
  describe 'GET /users/:id' do
    let(:header) {}
    before { get "/users/#{user_id}", headers: header }

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
      context ', the user exists' do
        context ', and it is the current user id' do
          it 'returns the user detail' do
            expect(json).not_to be_empty
            expect(json['id']).to eq(user_id)
          end
  
          it 'returns status code 200' do
            expect(response).to have_http_status(200)
          end
        end

        context ', and it is not the current user id' do
          let(:user_id) { 3 }
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
          let(:user_id) { 3 }
          it 'returns the user detail' do
            expect(json).not_to be_empty
            expect(json['id']).to eq(user_id)
          end
  
          it 'returns status code 200' do
            expect(response).to have_http_status(200)
          end
        end
      end

      context 'and the user does not exist' do
        let(:user_id) { 100 }
  
        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end
  
        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find User/)
        end
      end
    end
  end

  # Test suite for POST /users
  describe 'POST /users' do
    # valid payload
    let(:attributes) {
      {
        name: 'Learn Elm',
        email: 'larry@gmail.com',
        balance: '1800.55',
        password: 'tester',
        password_confirmation: 'tester'
      } 
    }
    before { post '/users', params: { user: attributes } }
    context 'when the request is valid' do
      it 'returns successful message' do
        expect(response.body).to match(/Your account is successfully registered/)
      end

      it 'returns user registration detail' do
        expect(json['user'])
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      let(:attributes) {
        {
          name: 'Learn',
          email: users.first.email,
          balance: '-100',
          password: 'aaa',
          password_confirmation: 'haa',
        }
      }
      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(/Validation failed: /)
      end
    end
  end

  # Test suite for PUT /users/:id
  describe 'PUT /users/:id' do
    let(:attributes) { { name: 'Shopify' } }
    let(:header) {}
    before { put "/users/#{user_id}", params: { user: attributes }, headers: header }

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
      context ', the user exists' do
        context ', it is the current user id' do
          context ', and the request is valid' do
            it 'returns successful message' do
              expect(response.body).to match(/Your profile is updated/)
            end
      
            it 'returns user updated detail' do
              expect(json['user'])
            end
    
            it 'returns status code 200' do
              expect(response).to have_http_status(200)
            end
          end

          context 'when the request is invalid' do
            let(:attributes) {
              {
                name: 'Learn',
                email: users.first.email,
                balance: '-100',
              }
            }
            it 'returns status code 422' do
              expect(response).to have_http_status(422)
            end
      
            it 'returns a validation failure message' do
              expect(response.body).to match(/Validation failed: /)
            end
          end
        end

        context ', and it is not the current user id' do
          let(:user_id) { 3 }
          let(:header) { { 'Authorization' => dummy_auth_token } }
          it 'returns a not authorized message' do
            expect(response.body).to match(/Not Authorized/)
          end
  
          it 'returns status code 401' do
            expect(response).to have_http_status(401)
          end
        end

        context ', the current user is admin' do
          let(:header) { { 'Authorization' => admin_token } }
          let(:user_id) { 3 }
          context ', and the request is valid' do
            it 'returns successful message' do
              expect(response.body).to match(/Your profile is updated/)
            end
      
            it 'returns user updated detail' do
              expect(json['user'])
            end
    
            it 'returns status code 200' do
              expect(response).to have_http_status(200)
            end
          end

          context 'when the request is invalid' do
            let(:attributes) {
              {
                name: 'Learn',
                email: users.first.email,
                balance: '-100',
              }
            }
            it 'returns status code 422' do
              expect(response).to have_http_status(422)
            end
      
            it 'returns a validation failure message' do
              expect(response.body).to match(/Validation failed: /)
            end
          end
        end
      end

      context 'and the user does not exist' do
        let(:user_id) { 100 }

        it 'returns status code 404' do
          expect(response).to have_http_status(404)
        end

        it 'returns a not found message' do
          expect(response.body).to match(/Couldn't find User/)
        end
      end
    end
  end

  # Test suite for DELETE /users/:id
  describe 'DELETE /users/:id' do
    let(:header) {}
    before { delete "/users/#{user_id}", headers: header }

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
      context ', the user is exist' do
        context ', and it is the current user id' do
          it 'returns status code 200' do
            expect(response).to have_http_status(200)
          end

          it 'returns a successful message' do
            expect(response.body).to match(/Your account is deleted/)
          end
        end

        context ', and it is not the current user id' do
          let(:header) { { 'Authorization' => dummy_auth_token } }
          let(:user_id) { 3 }

          it 'returns status code 401' do
            expect(response).to have_http_status(401)
          end
    
          it 'returns not authorized message' do
            expect(response.body).to match(/Not Authorized/)
          end
        end

        context ', and the current user is admin' do
          let(:header) { { 'Authorization' => admin_token } }
          let(:user_id) { 3 }

          it 'returns status code 200' do
            expect(response).to have_http_status(200)
          end

          it 'returns a successful message' do
            expect(response.body).to match(/Your account is deleted/)
          end
        end
      end
    end

    context 'and the user does not exist' do
      let(:user_id) { 100 }
      let(:header) { { 'Authorization' => auth_token } }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find User/)
      end
    end
  end
end