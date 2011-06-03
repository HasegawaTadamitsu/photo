class CreateUploadFiles < ActiveRecord::Migration
  def self.up
    create_table :upload_files do |t|
      t.string :upload_file_name,:null=>false
      t.string :saved_file_name ,:null=>false
      t.string :saved_file_name_with_path,:null=>false
      t.string :upload_client_ip ,:null=>false
      t.date :upload_time,  :null=>false
      t.integer :file_size ,:null=>false
      t.date :last_show_time
      t.timestamps
    end
    add_index :upload_files, :saved_file_name
  end

  def self.down
    drop_table :upload_files
    remove_index :upload_files, :saved_file_name
  end
end
