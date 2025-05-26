# This migration comes from active_storage (originally 20211119233751)
class RemoveNotNullOnActiveStorageBlobsChecksum < ActiveRecord::Migration[6.0]
  # Alters the active_storage_blobs table to allow NULL values in the checksum column, ensuring compatibility with schema changes or legacy data.
  def change
    return unless table_exists?(:active_storage_blobs)

    change_column_null(:active_storage_blobs, :checksum, true)
  end
end
