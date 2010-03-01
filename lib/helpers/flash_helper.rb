module FlashHelper
 helpers do
   
   # clear out flash object
   def clear_flash!
     @flash = session[:flash] || OrderedHash.new     
     @flash.clear
     session[:flash] = @flash
   end
   
   # add flash message
   def flash_it!( type, msg )
     @flash = session[:flash] || OrderedHash.new
     @flash[type] = msg
     session[:flash] = @flash
puts @flash.inspect     
   end
 end
end
