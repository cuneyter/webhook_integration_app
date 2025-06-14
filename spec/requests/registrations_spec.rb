require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get new_registration_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /registration" do
    it "registers a new user" do
      expect {
        post registration_path, params: { user: attributes_for(:user) }
      }.to change(User, :count).by(1)
      expect(response).to have_http_status(:found) # 302
      follow_redirect!
      expect(response).to be_successful
    end
  end
end
