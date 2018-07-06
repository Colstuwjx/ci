require "spec_helper"
require "app/features-json/user_json_controller"
require "app/services/user_service"

describe FastlaneCI::UserJSONController do
  def app
    described_class
  end
  let(:json) { JSON.parse(last_response.body) }

  before do
    allow(FastlaneCI.dot_keys).to receive(:encryption_key).and_return("test")
  end

  describe "/api/user" do
    it "creates a new user and attach the provider credentials" do
      email = "email@email.com"
      allow(FastlaneCI::Services.user_service.user_data_source).to receive(:user_exist?).with({ email: email }).and_return(false)

      post "/api/user", { github_token: "github_token", password: "password", email: email }.to_json, { "CONTENT_TYPE" => "application/json" }
      expect(last_response).to be_ok
      expect(json["status"]).to eq("success")
    end

    it "returns an error if the user already exists" do
      email = "email@email.com"
      allow(FastlaneCI::Services.user_service.user_data_source).to receive(:user_exist?).with({ email: email }).and_return(true)

      post "/api/user", { github_token: "github_token", password: "password", email: email }.to_json, { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(400)
      expect(json["key"]).to eq("User.Error")
      expect(json["message"]).to eq("Error creating new user")
    end
  end
end
