# -*- coding: utf-8 -*-
class Moshikomi < ActiveRecord::Base

  has_many :upload_files, :dependent => :destroy, :order => :saved_file_name
  accepts_nested_attributes_for :upload_files

  def un_upload
    errors.add(:upload,"参照ボタンを押さずに、uploadボタンを押したか、"+
               "環境的な問題でアップロードされませんでした。")
  end

  def set_all request
    self.html_url         = create_uniq_file_name
    self.upload_client_ip = request.remote_ip.to_str
    self.upload_agent     = request.env["HTTP_USER_AGENT"]
    self.upload_datetime  = Time.now
    self.last_access_datetime = Time.now
  end

  def will_delete_datetime 
    last = self.last_access_datetime
    return  last + 3.days
  end
 
  def access!
    self.access_count = self.access_count + 1
    self.last_access_datetime = Time.now
    self.save
  end

  def delete_now!
    self.deleted_datetime = Time.now
    file = self.show_file_name_with_path
    if File.exist? file
#      FileUtils.mv( SHOW_DIR + saved_file_name,
#                    DELETED_DIR + saved_file_name)
    end
    self.save
  end

  def show?
    if !self.deleted_datetime.nil?
      return false
    end
    if will_delete_datetime < Time.now
      return false
    end
#    file = self.show_file_name_with_path
#    if !File.exist? file
#      return false
#    end
    return true
  end


  private
  def create_uniq_file_name
    micro_sec_time = Time.now.to_f
    random_value = rand 100000
    micro_sec_time_str = micro_sec_time.to_s + random_value.to_s
    digest_str = Digest::MD5.hexdigest(micro_sec_time_str).to_s
  end

end
