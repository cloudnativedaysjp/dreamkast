require Rails.root.join('app/middlewares/dreamkast_exporter')
Rails.application.config.middleware.use(DreamkastExporter)
