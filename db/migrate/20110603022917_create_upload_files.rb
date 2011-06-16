class CreateUploadFiles < ActiveRecord::Migration
  def self.up
    create_table :upload_files do |t|
      t.integer  :moshikomi_id,     :null => false
      t.string   :saved_file_name,  :null => false
      t.string   :upload_file_name, :null => false
      t.integer  :upload_file_size, :null => false
      t.integer  :upload_columns,   :null => false
      t.integer  :upload_rows,      :null => false
      t.string   :comment
      t.timestamps
    end
    add_index :upload_files, :saved_file_name
  end

  def self.down
    drop_table :upload_files
    remove_index :upload_files, :saved_file_name
  end
end

