class CreateMoshikomis < ActiveRecord::Migration
  def self.up
    create_table :moshikomis do |t|
      t.string  :html_url,   :null=>false

      t.string    :upload_client_ip,  :null=>false
      t.string    :upload_agent,      :null=>false
      t.datetime  :upload_datetime,   :null=>false

      t.datetime  :last_access_datetime
      t.datetime  :deleted_datetime
      t.integer   :access_count,   :null=>false, :default => 0
      t.timestamps
    end
    add_index :moshikomis, :html_url
  end

  def self.down
    drop_table :moshikomis
    remove_index :moshikomis, :html_url
  end
end
