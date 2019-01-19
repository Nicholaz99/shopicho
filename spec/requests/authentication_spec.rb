require 'rails_helper'

RSpec.describe 'Authenticate User API', type: :request do
  # initialize test data with Faker 
  let!(:users) { create_list(:user, 10) }
  let(:user_email) { users.first.email }
  let(:user_password) { 'iwantinternship' }

  # Test suite for POST /login
  describe 'POST /login' do
    # valid payload
    let(:valid_attributes) { { email: user_email, password: user_password } }

    context 'when the request is valid' do
      before { post '/login', params: valid_attributes }

      it 'generates JWT' do
        expect(json['auth_token'])
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is invalid' do
      before { post '/login', params: { email: 'Foobar', password: '1' } }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/Invalid Credentials/)
      end
    end
  end
end