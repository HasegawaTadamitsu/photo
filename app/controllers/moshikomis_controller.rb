# -*- coding: utf-8 -*-

class MoshikomisController < ApplicationController

  MAX_COUNT_PER_ONE_MOSHIKOMI = 5

  respond_to :html

  def index
    @upload_files = UploadFile
      .where(:deleted_datetime => nil )
      .order(:upload_datetime)
    respond_with @upload_files
  end


  def show
    html_url = params[:id]
    mo = moshikomi_find_by_html_url  html_url
    if  mo.nil?
      not_found
      return
    end

    @data=Hash.new
    @data[:upload_datetime] = mo.upload_datetime
    @data[:access_count] = mo.access_count
    @data[:last_access_datetime] = mo.last_access_datetime

    mo.access!

    @data[:will_delete_datetime] = mo.will_delete_datetime
    @data[:base_pic_url] =  moshikomis_path + "/pic/" 
    @data[:upload_files] = mo.upload_files
    render :action => "show",:layout => "show"
  end

  def show_pic
    up = UploadFile.find_by_saved_file_name(params[:id])
    if up.nil?
      p "not found pic.id #{:id}"
      render :action => "not_found", :status=>404
      return
    end

    parent_id = up.moshikomi_id
    mo = moshikomi_find_by_id parent_id
    if mo.nil?
      return
    end

    file_name = up.show_file_name_with_path
    send_file file_name, :type=>'image/jpeg',:disposition => 'inline'
  end

  def complete
    html_url = params[:id]
    mo = moshikomi_find_by_html_url html_url
    if  mo.nil?
      not_found
      return
    end

    @data=Hash.new
    @data[:url] = url_for( :action=>'show' ) 
    respond_with  @data
  end

  def new
    @mo = Moshikomi.new
    @mo.build_message
    MAX_COUNT_PER_ONE_MOSHIKOMI.times do
      @mo.upload_files.build
    end
    respond_with @mo
  end


  def create
    po = params[:moshikomi]
    if po.nil?
      raise "bad request? params is nil."
    end

    @mo = Moshikomi.new
    @mo.after_init request
    attrs = po[:upload_files_attributes]
    if MAX_COUNT_PER_ONE_MOSHIKOMI < attrs.size 
      raise "bad request? attributes is over.#{attrs.size}"
    end
    attrs.each_key do |key|
      up = @mo.upload_files.build
      up.after_init  attrs[key]
    end
    msg = @mo.build_message
    msg.after_init po[:messages]

    respond_to do |format|
      if @mo.save
        format.html {
          redirect_to :action=>'complete',
                 :id => @mo.html_url     }
      else
        format.html { render :action => "new" }
      end
    end
  end

  private
  def moshikomi_find_by_id id
    mo = Moshikomi.find id
    if mo.nil?
      p "not found. id  #{:id}"
      return nil
    end
    if !mo.show?
      mo.delete_now!
      p "deleted moshikomi id #{:id}/at #{mo.deleted_datetime}"
      return nil
    end
    return mo
  end

  def moshikomi_find_by_html_url  html_url
    mo = Moshikomi.find_by_html_url html_url
    if mo.nil?
      p "not found. html_url #{:html_url}"
      return nil
    end
    if !mo.show?
      mo.delete_now!
      p "deleted moshikomi id #{:html_url}/at #{mo.deleted_datetime}"
      return nil
    end
    return mo
  end

  def not_found
    render :action => "not_found", :status=>404
  end

end
