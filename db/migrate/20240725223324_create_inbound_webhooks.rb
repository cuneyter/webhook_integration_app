class CreateInboundWebhooks < ActiveRecord::Migration[7.2]
  def change
    create_table :inbound_webhooks do |t|
      t.string :event, null: false
      t.integer :status, default: 0, null: false
      t.jsonb :payload, null: false
      t.string :controller_name, null: false
      t.text :error_message
      t.string :source_ip # The IP address from which the webhook request originated
      t.string :inbound_webhook_id # The unique identifier for the webhook request
      t.datetime :processed_at

      t.timestamps
    end

    add_index :inbound_webhooks, :inbound_webhook_id, unique: true
    add_index :inbound_webhooks, :event
    add_index :inbound_webhooks, :status
  end
end
