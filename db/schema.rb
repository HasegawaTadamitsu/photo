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

ActiveRecord::Schema.define(:version => 20110603022917) do

  create_table "upload_files", :force => true do |t|
    t.string   "upload_file_name",          :null => false
    t.string   "saved_file_name",           :null => false
    t.string   "saved_file_name_with_path", :null => false
    t.string   "upload_client_ip",          :null => false
    t.date     "upload_time",               :null => false
    t.integer  "file_size",                 :null => false
    t.date     "last_show_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "upload_files", ["saved_file_name"], :name => "index_upload_files_on_saved_file_name"

end