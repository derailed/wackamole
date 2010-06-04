module FlashHelper
 helpers do
   
   # clear out flash object
   def clear_flash!
     @flash = session[:flash] || BSON::OrderedHash.new     
     @flash.clear
     session[:flash] = @flash
   end
   
   # add flash message
   def flash_it!( type, msg )
     @flash = session[:flash] || BSON::OrderedHash.new
     @flash[type] = msg
     session[:flash] = @flash
   end
 end
end
