class CreateMoshikomis < ActiveRecord::Migration
  def self.up
    create_table :hoshikomis do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :moshikomis
  end
end


class CreateUploadFiles < ActiveRecord::Migration
  def self.up
    create_table :upload_files do |t|
      t.string :upload_file_name,:null=>false
      t.string :saved_file_name ,:null=>false
      t.string :upload_client_ip,  :null=>false
      t.string :upload_agent,  :null=>false
      t.datetime  :upload_datetime,    :null=>false
      t.integer   :upload_file_size ,     :null=>false
      t.integer   :access_count,   :null=>false, :default => 0
      t.datetime  :last_access_datetime
      t.datetime  :deleted_datetime
      t.timestamps
    end
    add_index :upload_files, :saved_file_name
  end

  def self.down
    drop_table :upload_files
    remove_index :upload_files, :saved_file_name
  end
end
