# -*- coding: utf-8 -*-
class CreateMoshikomis < ActiveRecord::Migration
  def self.up
    create_table :moshikomis do |t|
      t.string  :html_url,   :null=>false

      t.string    :upload_client_ip,  :null=>false
      t.string    :upload_agent,      :null=>false
      t.datetime  :upload_datetime,   :null=>false

      #期間 choiseの値
      t.string    :kikan_start,       :null=>false
      #期間 choiseの値
      t.integer   :kikan_day,         :null=>false

      #削除予定日時
      t.datetime  :will_deleted_datetime,:null=>false

      # 公開時のアクセス日時
      t.datetime  :last_access_datetime

      # 非公開　日時。非公開にした時間。ここに値がはいっていると非公開。
      t.datetime  :deleted_datetime

      #　公開時のアクセス件数
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
