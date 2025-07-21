require "rails_helper"

RSpec.describe "Applications", type: :request do
  describe "GET /" do
    it "returns http redirect" do
      get "/"
      expect(response).to have_http_status(:redirect)
    end
  end
end
