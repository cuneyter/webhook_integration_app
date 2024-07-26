FactoryBot.define do
  factory :inbound_webhook do
    event { "test_event" }
    status { "pending" }
    payload { { key: "value" } }
    controller_name { "TestController" }
    inbound_webhook_id { "12345" }
  end
end
