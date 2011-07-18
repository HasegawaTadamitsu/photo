# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110603022918) do

  create_table "messages", :force => true do |t|
    t.integer  "moshikomi_id", :null => false
    t.string   "title"
    t.string   "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "moshikomis", :force => true do |t|
    t.string   "html_url",                             :null => false
    t.string   "upload_client_ip",                     :null => false
    t.string   "upload_agent",                         :null => false
    t.datetime "upload_datetime",                      :null => false
    t.string   "kikan_start",                          :null => false
    t.integer  "kikan_day",                            :null => false
    t.datetime "will_deleted_datetime",                :null => false
    t.datetime "last_access_datetime"
    t.datetime "deleted_datetime"
    t.integer  "access_count",          :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "moshikomis", ["html_url"], :name => "index_moshikomis_on_html_url"

  create_table "upload_files", :force => true do |t|
    t.integer  "moshikomi_id",     :null => false
    t.string   "saved_file_name",  :null => false
    t.string   "upload_file_name", :null => false
    t.integer  "upload_file_size", :null => false
    t.integer  "upload_columns",   :null => false
    t.integer  "upload_rows",      :null => false
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "upload_files", ["saved_file_name"], :name => "index_upload_files_on_saved_file_name"

end
