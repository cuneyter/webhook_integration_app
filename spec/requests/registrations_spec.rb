require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get new_registration_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /registration" do
    it "registers a new user" do
      post registration_path, params: {
        user: {
          email_address: "test@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
      expect(response).to have_http_status(:redirect)
      expect(User.find_by(email_address: "test@example.com")).to be_present
    end
  end
end
