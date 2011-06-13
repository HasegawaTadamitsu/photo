# -*- coding: utf-8 -*-

require 'RMagick'

class UploadFile < ActiveRecord::Base

  MAX_FILE_SIZE_BYTE = 500.kilobytes
  SHOW_DIR = "/var/tmp/upload/show/"
  DELETED_DIR = "/var/tmp/upload/deleted/"

  MAX_COLUMNS  = 680
  MAX_ROWS = 400

  def set_all size,upload_file_name,tmp_file_name,request
    self.upload_file_size = size
    self.upload_file_name = upload_file_name
    @tmp_uploaded_file =    tmp_file_name
    self.upload_client_ip = request.remote_ip.to_str
    self.upload_agent     = request.env["HTTP_USER_AGENT"]

    self.saved_file_name  = create_uniq_file_name upload_file_name

    self.upload_datetime  = Time.now
    self.last_access_datetime = Time.now
  end
 
  def will_delete_datetime 
    last = self.last_access_datetime
    return  last + 3.days
  end

  def show_file_name_with_path
    return SHOW_DIR + saved_file_name
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
      FileUtils.mv( SHOW_DIR + saved_file_name,
                    DELETED_DIR + saved_file_name)
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
    file = self.show_file_name_with_path
    if !File.exist? file
      return false
    end
    return true
  end

  protected
  def validate_on_create
    if upload_file_size.nil? || upload_file_size == 0
      errors.add(:file_size,"ファイルのサイズが0byteです。")
      return
    end

    if upload_file_size > MAX_FILE_SIZE_BYTE
      errors.add(:file_size,
              "サイズが大きすぎます。"+
              "アップロードしたサイズ" +
                 "#{upload_file_size / 1.kilobytes}kilobytes" +
                 "/ 最大#{MAX_FILE_SIZE_BYTE / 1.kilobytes}kbytes。")
      return
    end

    if upload_file_name.nil?
      errors.add(:saved_file_name,"ファイル名がnilです。")
      return
    end

    if upload_file_name.downcase !~ /^(.*)\.(jpeg|jpg|gif|png)$/
      errors.add(:upload_file_name,
                 "拡張子がjpg/jpeg/png/gif以外です。"+
                 "画像でない可能性があります。")
      return
    end

    begin
      @image = Magick::Image.read(@tmp_uploaded_file).first
      format = @image.format
      unless %w(JPEG GIF PNG).member?(format)
        errors.add(:image, "意図したフォーマットではありません。#{format}")
        return
      end
    rescue Magick::ImageMagickError, RuntimeError => ex
      self.errors.add(:image, "画像が壊れているあります。")
      return
    end

    move_image

  end
  
  def un_upload
    errors.add(:upload,"参照ボタンを押さずに、uploadボタンを押したか、"+
               "環境的な問題でアップロードされませんでした。")
  end

  def move_image 
    columns = @image.columns
    rows =@image.rows

    bai = 1.0
    if columns > MAX_COLUMNS
      bai = MAX_COLUMNS.to_f / columns.to_f
      p "over size columns #{columns}/MAX#{MAX_COLUMNS}/bairitsu#{bai}"
    end
    resized_rows = rows * bai
    if resized_rows > MAX_ROWS
      bai = MAX_ROWS.to_f / resized_rows.to_f * bai
      p "over size resized_rows #{resized_rows}" +
        "/MAX#{MAX_ROWS}/bairitsu#{bai}"
    end
    @image.resize!(bai)

    resized_columns = @image.columns
    resized_rows    = @image.rows
    if resized_columns > 100 and resized_rows > 10 
      dr =Magick::Draw.new
      dr.annotate(@image,0,0,0,0,"www.uhpic.com") do
        dr.gravity = Magick::NorthWestGravity
        dr.pointsize = 20
        dr.fill ="white"
        dr.stroke = "gray"
        dr.stroke_width 1
      end
    end
    @image.profile!("*",nil)
    @image.strip!

    @image.write show_file_name_with_path
  end

  private
  def create_uniq_file_name salt_str
    micro_sec_time = Time.now.to_f
    random_value = rand 100000
    micro_sec_time_str = micro_sec_time.to_s + salt_str + random_value.to_s
    digest_str = Digest::MD5.hexdigest(micro_sec_time_str).to_s
  end

end
