class Util


  def self.str_cut str,len
   if str.nil? 
     return nil
   end
   if str.split(//u).size > len
     str = str.split(//u)[0..len].join
   end
   return str
 end

end
