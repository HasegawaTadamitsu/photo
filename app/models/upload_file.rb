# -*- coding: utf-8 -*-
class UploadFile < ActiveRecord::Base



  MAX_FILE_SIZE_BYTE = 500.kilobytes

  validates_presence_of :upload_file_name


  protected
  def validate
    if file_size.nil? || file_size == 0
      errors.add(:file_size,"ファイルのサイズが0byteです。")
      return
    end

    if file_size > MAX_FILE_SIZE_BYTE
      errors.add(:file_size,
              "サイズが大きすぎます。"+
              "アップロードしたサイズ#{file_size / 1.kilobytes}kilobytes"+
                 "/ 最大#{MAX_FILE_SIZE_BYTE / 1.kilobytes}kbytes。")
      return
    end

    if upload_file_name.nil?
      errors.add(:saved_file_name,"ファイル名がnilです。")
      return
    end

    if upload_file_name !~ /^(.*)\.(jpeg|jpg|gif|png)$/
      errors.add(:upload_file_name,
                 "拡張子がjpg/jpeg/png/gif以外です。画像でない可能性があります。")
      return
    end

  end
  
  def un_upload
    errors.add(:upload,"参照ボタンを押さずに、uploadボタンを押したか、環境的な問題でアップロードされませんでした。")
  end

end
