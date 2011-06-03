class CreateUploadFiles < ActiveRecord::Migration
  def self.up
    create_table :upload_files do |t|
      t.string :upload_file_name
      t.string :saved_file_name
      t.string :saved_file_name_with_path
      t.string :upload_client_ip
      t.date :upload_time
      t.integer :file_size

      t.timestamps
    end
  end

  def self.down
    drop_table :upload_files
  end
end
