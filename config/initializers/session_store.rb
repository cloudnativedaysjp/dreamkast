Rails.application.config.session_store(:redis_session_store, **{
                                         redis_server: ENV['REDIS_URL'],
    expire_after: 1.weeks
                                       })
