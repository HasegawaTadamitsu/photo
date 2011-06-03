# -*- coding: utf-8 -*-
class UploadFile < ActiveRecord::Base

 validates_presence_of :upload_file_name


  protected
  def validate
    if file_size.nil? || file_size == 0
      errors.add(:file_size,"うまくuploadできなかったか、サイズが0byteです。")
      return
    end
    if file_size > 999999
      errors.add(:file_size,"サイズが大きすぎます。")
      return
    end
  end
  
  def un_upload
    errors.add(:file_size,"うまくuploadできなかったか、サイズが0byteです。")
  end

end
