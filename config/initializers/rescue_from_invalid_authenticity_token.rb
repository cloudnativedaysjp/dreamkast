require Rails.root.join('app/middlewares/rescue_from_invalid_authenticity_token')
Rails.application.config.middleware.insert_before(OmniAuth::Builder, RescueFromInvalidAuthenticityToken)
