
logger = RAILS_DEFAULT_LOGGER
logger.info "Start batch"

logger.info "End batch"


moshikomis = Moshikomi.delete
  puts "id,show?,upload_datetime," +
  "will_deleted_datetime,last_access_datetime,"+
  "access_count"

moshikomis.each_with_index do |m,index|
  can_show = m.show?
  puts "#{m.id},#{can_show},#{m.upload_datetime},"+
    "#{m.will_deleted_datetime}," +
    "#{m.last_access_datetime}," +
    "#{m.access_count}"
  m.show_and_delete
end


