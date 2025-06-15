require 'rails_helper'

RSpec.describe "Passwords", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get new_password_path
      expect(response).to have_http_status(:success)
    end
  end
end
