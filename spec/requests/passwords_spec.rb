require 'rails_helper'

RSpec.describe "Passwords", type: :request do
  let(:user) { create(:user) }

  describe "GET /new" do
    it "returns http success" do
      get new_password_path, headers: { "Host" => "localhost" }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT /update" do
    let(:token) { user.password_reset_token }

    context "with valid params" do
      let(:valid_params) {
        { user: { password: "new_password", password_confirmation: "new_password" } }
      }

      it "redirects to the new session path" do
        put password_path(token), params: valid_params
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "with invalid params" do
      let(:invalid_params) {
        { user: { password: "new_password", password_confirmation: "invalid" } }
      }

      it "renders the edit template" do
        put password_path(token), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
