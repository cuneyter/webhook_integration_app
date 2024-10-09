class ChangeStatusToBeStringInInboundWebhooks < ActiveRecord::Migration[7.2]
  def up
    change_column :inbound_webhooks, :status, :string, default: "pending", null: false
  end

  def down
    change_column :inbound_webhooks, :status, :integer, using: 'status::integer'
  end
end
