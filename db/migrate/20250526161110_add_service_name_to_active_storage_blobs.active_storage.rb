# This migration comes from active_storage (originally 20190112182829)
class AddServiceNameToActiveStorageBlobs < ActiveRecord::Migration[6.0]
  ##
  # Adds a non-nullable `service_name` column to the `active_storage_blobs` table and populates it with the current Active Storage service name for existing records.
  #
  # The migration only runs if the `active_storage_blobs` table exists and the `service_name` column is not already present.
  # Existing records are updated with the configured service name, if available, before enforcing the NOT NULL constraint.
  def up
    return unless table_exists?(:active_storage_blobs)

    unless column_exists?(:active_storage_blobs, :service_name)
      add_column :active_storage_blobs, :service_name, :string

      if configured_service = ActiveStorage::Blob.service.name
        ActiveStorage::Blob.unscoped.update_all(service_name: configured_service)
      end

      change_column :active_storage_blobs, :service_name, :string, null: false
    end
  end

  ##
  # Removes the `service_name` column from the `active_storage_blobs` table if the table exists.
  def down
    return unless table_exists?(:active_storage_blobs)

    remove_column :active_storage_blobs, :service_name
  end
end
