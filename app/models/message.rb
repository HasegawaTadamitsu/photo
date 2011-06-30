# -*- coding: utf-8 -*-

class Message < ActiveRecord::Base

  belongs_to :moshikomi

  def after_init attr
p "ho"
p attr
    title = attr["title"]
p title 
   self.title = title[0..100] unless title.nil?
    body = attr["body"]
    self.body  = body[0..500] unless body.nil?
  end

end
