# -*- coding: utf-8 -*-
require 'RMagick'


class UploadFile < ActiveRecord::Base

  belongs_to :moshikomi

  validate :on=>:create do 
    do_validate_on_create
  end

  MAX_FILE_SIZE_BYTE = 6.megabytes
  SHOW_DIR = "/var/tmp/upload/show/"
  DELETED_DIR = "/var/tmp/upload/deleted/"

  MAX_COLUMNS  = 680
  MAX_ROWS = 400

  def after_init!
    self.comment = Util.str_cut(comment,10)
    if self.upload_file_name.nil?
      return
    end
    self.upload_file_size = upload_file_name.tempfile.size
    @tmp_uploaded_file    = upload_file_name.tempfile.path
    self.upload_file_name = upload_file_name.original_filename
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
    self.saved_file_name  = html_url + "_" + seq.to_s
    self.upload_columns   = @images.first.columns
    self.upload_rows      = @images.first.rows
    move_image
  end

  def do_validate_on_create

    if !need_save_data?
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
      @images = Magick::Image.read(@tmp_uploaded_file)
      format = @images.first.format
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
    imageList = Magick::ImageList.new
    @images.each do |img|
      format = img.format
      unless %w(JPEG GIF PNG).member?(format)
        raise  "意図したフォーマットではありません。#{format}"
      end
      columns = img.columns
      rows =   img.rows

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
      img.resize!(bai)
      
      resized_columns = img.columns
      resized_rows    = img.rows
      if resized_columns > 100 and resized_rows > 10 
        dr =Magick::Draw.new
        dr.annotate(img,0,0,0,0,"www.uhpic.com") do
          dr.gravity = Magick::NorthWestGravity
          dr.pointsize = 20
          dr.fill ="white"
          dr.stroke = "gray"
          dr.stroke_width 1
        end
      end
      img.profile!("*",nil)
      img.strip!
      imageList.push img
    end
    imageList = imageList.optimize_layers(Magick::OptimizeLayer)
    format = @images.first.format
    tmp_file = show_file_name_with_path + "." + format
    imageList.write tmp_file
    FileUtils.mv( tmp_file, show_file_name_with_path )
  end

end
