class UploadFilesController < ApplicationController

  SAVED_DIR = "/var/tmp/upload/"

  def create_uniq_file_name salt_str
    micro_sec_time = Time.now.to_f
    micro_sec_time_str = micro_sec_time.to_s + salt_str
    digest_str = Digest::MD5.hexdigest(micro_sec_time_str).to_s
  end

  def index
    @upload_files = UploadFile.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end


  def show
    @upload_file = UploadFile.find_by_saved_file_name(params[:id])
    respond_to do |format|
      format.html 
    end
  end


  def show_pic
    @upload_file = UploadFile.find_by_saved_file_name(params[:id])

    send_file @upload_file.saved_file_name_with_path,
    :type=>'image/jpeg',:disposition => 'inline'

  end


  def new
    @upload_file = UploadFile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @upload_file }
    end
  end


  def create
    
    pa = params[:upload_file][:upload_file_name]
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
    saved_file_name_with_path = SAVED_DIR + saved_file_name

    File.rename(tmp_uploaded_file, saved_file_name_with_path)

    @upload_file = UploadFile.new
    @upload_file.file_size = size
    @upload_file.upload_file_name = upload_file_name
    @upload_file.saved_file_name  = saved_file_name
    @upload_file.saved_file_name_with_path = saved_file_name_with_path
    @upload_file.upload_time = Time.now
    @upload_file.upload_client_ip = "!!" # request.env['HTTP_X_FORWARDED_FOR'] 

    respond_to do |format|
      if @upload_file.save
        format.html {
          redirect_to :controller=>'upload_files',
                      :action=>'show',
                      :id => @upload_file.saved_file_name,
                      :notice => 'Upload file was successfully created.' }
      else
        format.html { render :action => "new" }
      end
    end
  end

end
