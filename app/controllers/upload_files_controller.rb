# -*- coding: utf-8 -*-

class UploadFilesController < ApplicationController

  respond_to :html

  def index
    @upload_files = UploadFile.all
    respond_with @upload_files
  end


  def show
    @upload_file = UploadFile.find_by_saved_file_name(params[:id])
    if @upload_file.nil?
      p "not found data.id #{:id}"
      render :action => "not_found", :status=>404
      return
    end
    if !@upload_file.show?
      p "deleted data id #{:id}/at #{@upload_file.deleted_datetime}"
      render :action => "not_found",:status => 404
      return
    end
    @data=Hash.new
    @data[:upload_datetime] = @upload_file.upload_datetime
    @data[:access_count] = @upload_file.access_count
    @data[:last_access_datetime] = @upload_file.last_access_datetime
    @upload_file.access
    @upload_file.save
    @data[:will_delete_datetime] = @upload_file.will_delete_datetime
    @data[:pic_url] = upload_files_path + "/pic/" +
      @upload_file.saved_file_name
    respond_with( @data, :layout => "show")
  end

  def show_pic
    @upload_file = UploadFile.find_by_saved_file_name(params[:id])
    if @upload_file.nil?
      p "not found pic.id #{:id}"
      render :action => "not_found", :status=>404
      return
    end
    if !@upload_file.show?
      p "deleted pic id #{:id}/at #{@upload_file.deleted_time}"
      render :action => "not_found",:status => 404
      return
    end
    send_file @upload_file.saved_file_name_with_path,
    :type=>'image/jpeg',:disposition => 'inline'
  end

  def complete
    @upload_file = UploadFile.find_by_saved_file_name(params[:id])
    if @upload_file.nil?
      p "not found data.id #{:id}"
      render :action => "not_found"
      return
    end
    @data=Hash.new
    @data[:url] = url_for( :action=>'show' ) 
    respond_with  @data
  end

  def new
    @upload_file = UploadFile.new
    respond_with @upload_file
  end


  def create
    po = params[:upload_file]
    if po.nil?
      @upload_file = UploadFile.new
      @upload_file.un_upload
      render :action => "new"
      return 
    end

    pa = po[:upload_file_name]
    if pa.nil?
      raise "paramete is nil."
    end

    tmp_uploaded_file = pa.tempfile
    if tmp_uploaded_file.nil?
      raise "uploaded file is nil."
    end
    size = tmp_uploaded_file.size
    upload_file_name = pa.original_filename
    saved_file_name  = create_uniq_file_name upload_file_name

    @upload_file = UploadFile.new
    @upload_file.upload_file_size = size
    @upload_file.upload_file_name = upload_file_name
    @upload_file.saved_file_name  = saved_file_name
    @upload_file.upload_datetime  = Time.now
    @upload_file.upload_client_ip = request.remote_ip.to_str
    @upload_file.upload_agent     = request.env( "HTTP_USER_AGENT" )
    @upload_file.tmp_uploaded_file = tmp_uploaded_file.path

    respond_to do |format|
      if @upload_file.save
        format.html {
          redirect_to :action=>'complete',
                 :id => @upload_file.saved_file_name     }
      else
        File.delete(tmp_uploaded_file)
        format.html { render :action => "new" }
      end
    end
  end

  private
  def create_uniq_file_name salt_str
    micro_sec_time = Time.now.to_f
    random_value = rand 100000
    micro_sec_time_str = micro_sec_time.to_s + salt_str + random_value.to_s
    digest_str = Digest::MD5.hexdigest(micro_sec_time_str).to_s
  end

end
