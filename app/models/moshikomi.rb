# -*- coding: utf-8 -*-

class Moshikomi < ActiveRecord::Base

  has_one :message 
  has_many :upload_files, :dependent => :destroy,
           :order => :saved_file_name
  accepts_nested_attributes_for :upload_files, :message

  validate :on=>:create do 
    do_validate_on_create
  end

  def self.kikan_start_choices
    [
     ["現在の時刻から",0],
     ["最後にアクセスしてから",1]
    ]
  end

  def self.kikan_day_choices
    [
     ["1日後",1],
     ["3日後",3],
     ["1週間後",7],
     ["2週間後",14],
    ]
  end

  def after_init! request
    self.html_url         = create_uniq_file_name
    self.upload_client_ip = request.remote_ip.to_str
    agent = request.env["HTTP_USER_AGENT"]
    if !agent.nil? 
      agent.strip!
    end
    self.upload_agent     = agent[0..100]
    self.upload_datetime  = Time.now

    set_will_deleted_datetime_from_now
  end

 
  def access!
    self.access_count = self.access_count + 1
    self.last_access_datetime = Time.now

    if kikan_start == "1"
      set_will_deleted_datetime_from_now
    end

    self.save
  end

  def delete_now!
    self.deleted_datetime = Time.now
    upload_files.each_with_index do |upload_file,index|
      upload_file.delete_now!
    end
    self.save
  end

  def show?
    if !self.deleted_datetime.nil?
      return false
    end
    if will_deleted_datetime < Time.now
      return false
    end
    upload_files.each_with_index do |upload_file,index|
      res = upload_file.show?
      if res == false
        return false
      end
    end
    return true
  end

  before_create :before_create_callback


  def before_create_callback
    upload_files.delete_if do |upload_file|
      !upload_file.need_save_data?
    end
    upload_files.each_with_index do |upload_file,index|
      upload_file.my_before_create html_url, index
    end
  end



  def do_validate_on_create
    if  kikan_day > 20
          errors.add(:kikan_day,
               "いたずらはダメだと思います。")
    end

    if  how_many_need_upload_files == 0
          errors.add(:upload,
               "参照ボタンを押さずに、uploadボタンを"+
               "押したか、"+
               "環境的な問題でアップロードされませんでした。")
    end

  end

  private

  def set_will_deleted_datetime_from_now
      self.will_deleted_datetime = Time.now
      self.will_deleted_datetime += kikan_day.days
  end
  
  def create_uniq_file_name
    micro_sec_time = Time.now.to_f
    random_value = rand 100000
    micro_sec_time_str = micro_sec_time.to_s +
                         random_value.to_s
    digest_str = Digest::MD5.hexdigest(
                             micro_sec_time_str).to_s
  end


  def how_many_need_upload_files
    co = 0 
    upload_files.each do |upload_file|
      if upload_file.need_save_data?
        co = co + 1
      end
    end
    return co
  end

end
