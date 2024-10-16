class ChangeStatusToBeStringInInboundWebhooks < ActiveRecord::Migration[7.2]
  def up
    add_column :inbound_webhooks, :status_string, :string, default: "pending", null: false

    # * Iterating over each record with find_each can be inefficient and slow for large datasets,
    # * potentially leading to extended migration times and database locks.
    # * Updating all records in a single query using update_all, which is more efficient.
    # InboundWebhook.find_each do |webhook|
    #   webhook.update_column(:status_string, webhook.status.to_s)
    # end
    # ! Note: Resetting the column information ensures that the model is aware of the new column.
    InboundWebhook.reset_column_information
    InboundWebhook.update_all("
      status_string = CASE status
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'processing'
        WHEN 2 THEN 'processed'
        WHEN 3 THEN 'failed'
        WHEN 4 THEN 'unhandled'
        ELSE 'unknown'
      END
    ")

    remove_column :inbound_webhooks, :status
    rename_column :inbound_webhooks, :status_string, :status
  end

  def down
    add_column :inbound_webhooks, :status_int, :integer

    # *  Iterating over records with find_each is inefficient.
    # * Use a single SQL query with a CASE statement to update all records at once.
    # InboundWebhook.find_each do |webhook|
    #   status_int = case webhook.status
    #   when "pending" then 0
    #   when "processing" then 1
    #   when "processed" then 2
    #   when "failed" then 3
    #   when "unhandled" then 4
    #   else 0
    #   end
    #   webhook.update_column(:status_int, status_int)
    # end
    # ! Note: Resetting the column information ensures that the model is aware of the new column.
    InboundWebhook.reset_column_information
    InboundWebhook.update_all("
      status_int = CASE status
        WHEN 'pending' THEN 0
        WHEN 'processing' THEN 1
        WHEN 'processed' THEN 2
        WHEN 'failed' THEN 3
        WHEN 'unhandled' THEN 4
        ELSE 0
      END
    ")

    remove_column :inbound_webhooks, :status
    rename_column :inbound_webhooks, :status_int, :status
  end
end
