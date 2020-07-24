class RescueFromInvalidAuthenticityToken
  def initialize(app)
    @app = app 
  end 
  
  def call(env)
    # yield
    @app.call(env)
  rescue ActionController::InvalidAuthenticityToken
    [302, {'Location' => "/", 'Content-Type' => 'text/html'}, ['Invalid Authenticity Token']]
  end
end
