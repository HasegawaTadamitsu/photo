# -*- coding: utf-8 -*-

require 'RMagick'

class UploadFile < ActiveRecord::Base

  MAX_FILE_SIZE_BYTE = 500.kilobytes
  SAVED_DIR = "/var/tmp/upload/"
  MAX_COLUMNS  = 120
  MAX_ROWS = 10

  def tmp_uploaded_file= str
    @tmp_uploaded_file = str
  end
 
  def will_delete_datetime 
    last = self.last_access_datetime
    return  last + 3.days
  end

  def saved_file_name_with_path
    return SAVED_DIR + saved_file_name
  end

  def access
    self.access_count = self.access_count + 1
    self.last_access_datetime = Time.now
  end
 
  def show?
    if !self.deleted_datetime.nil?
      return false
    end
    if self.last_access_datetime.nil?
      return true
    end
    if will_delete_datetime < Time.now
      self.deleted_datetime = Time.now
      self.save
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
    p columns
    p rows

    bai = 1.0
    if columns > MAX_COLUMNS
      bai = MAX_COLUMNS.to_f / columns.to_f
      p "over size columns #{columns}/MAX#{MAX_COLUMNS}/bairitsu#{bai}"
    end
    resized_rows = rows * bai
    if resized_rows > MAX_ROWS
      bai = MAX_ROWS.to_f / resized_rows.to_f
      p "over size resized_rows #{resized_rows}" +
        "/MAX#{MAX_ROWS}/bairitsu#{bai}"
    end
    @image.resize!(bai)

    columns = @image.columns
    rows =   @image.rows
    p columns
    p rows

    @image.write saved_file_name_with_path
  end

end
