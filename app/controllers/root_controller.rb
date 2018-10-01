require 'app/controllers/fml_controller'

class RootController < FMLController  
  route do |r|
    r.get do
      r.response.headers['Content-Type'] = 'text/html'
      
      view 'index'
    end
  end
end
