# -*- coding: utf-8 -*-

require 'RMagick'

class UploadFile < ActiveRecord::Base

  belongs_to :moshikomi

  MAX_FILE_SIZE_BYTE = 500.kilobytes
  SHOW_DIR = "/var/tmp/upload/show/"
  DELETED_DIR = "/var/tmp/upload/deleted/"

  MAX_COLUMNS  = 680
  MAX_ROWS = 400
  COMMENT_MAX_LENGTH = 100

  def after_init attr
    self.comment = attr["comment"]
    pa = attr["upload_file_name"]
    if !pa.nil?
      self.upload_file_name = pa.original_filename
      tmp_uploaded_file     = pa.tempfile
      if tmp_uploaded_file.nil?
        raise "uploaded file is nil."
      end
      self.upload_file_size = tmp_uploaded_file.size
      @tmp_uploaded_file    = tmp_uploaded_file.path
    end
  end

  def url_without_basepath
    return saved_file_name
  end

  def show_file_name_with_path
    SHOW_DIR + self.saved_file_name
  end

  def  need_save_data?
    if  upload_file_name.blank?
      return false
    end
    return true
  end

  def delete_now!
    file = self.show_file_name_with_path
    if File.exist? file
      FileUtils.mv( file, DELETED_DIR + saved_file_name)
    end
  end

  def show?
    file = self.show_file_name_with_path
    if !File.exist? file
      return false
    end
  end

  def my_before_create  html_url, seq
    p "my_before_save"
    self.saved_file_name  = html_url + "_" + seq.to_s
    self.upload_columns   = @image.columns
    self.upload_rows      = @image.rows
    move_image
  end

  def validate_on_create

    if !need_save_data?
      return 
    end

    if (!self.comment.blank? ) and
        COMMENT_MAX_LENGTH < self.comment.size
      errors.add(:comment,"が長すぎます。")
      return
    end


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
      errors.add(:upload_file_name,"ファイル名がnilです。")
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

end
