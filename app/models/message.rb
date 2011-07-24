# -*- coding: utf-8 -*-

require 'Util'

class Message < ActiveRecord::Base

  belongs_to :moshikomi
  MAX_TITLE_LENGTH =  50
  MAX_BODY_LENGTH  = 100

  def after_init!
    self.title = Util.str_cut(title, MAX_TITLE_LENGTH)
    self.body  = Util.str_cut(body,  MAX_BODY_LENGTH)
  end

end
