class ChangeStatusToBeStringInInboundWebhooks < ActiveRecord::Migration[7.2]
  def up
    add_column :inbound_webhooks, :status_string, :string, default: "pending", null: false

    InboundWebhook.find_each do |webhook|
      p 'webhook_status:', webhook.status
      webhook.update_column(:status_string, webhook.status.to_s)
    end

    remove_column :inbound_webhooks, :status
    rename_column :inbound_webhooks, :status_string, :status
  end

  def down
    add_column :inbound_webhooks, :status_int, :integer

    InboundWebhook.find_each do |webhook|
      status_int = case webhook.status
      when "pending" then 0
      when "processing" then 1
      when "processed" then 2
      when "failed" then 3
      when "unhandled" then 4
      else 0
      end
      webhook.update_column(:status_int, status_int)
    end

    remove_column :inbound_webhooks, :status
    rename_column :inbound_webhooks, :status_int, :status
  end
end
