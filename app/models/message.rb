# -*- coding: utf-8 -*-

class Message < ActiveRecord::Base

  belongs_to :moshikomi

  def after_init!
    self.title = Util.str_cut(title,10)
    self.body  = Util.str_cut(body,  10)
  end

end
