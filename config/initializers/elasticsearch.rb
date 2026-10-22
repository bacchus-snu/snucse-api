conf = Rails.application.config_for(:elasticsearch)
Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: ENV['ELASTICSEARCH_URL'].presence || conf['host']
)
