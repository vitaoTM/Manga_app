Rails.application.configure do
  config.litestream.replica_bucket     = ENV["LITESTREAM_REPLICA_BUCKET"]
  config.litestream.replica_key_id     = ENV["LITESTREAM_REPLICA_KEY_ID"]
  config.litestream.replica_access_key = ENV["LITESTREAM_REPLICA_ACCESS_KEY"]
  config.litestream.replica_endpoint   = ENV["LITESTREAM_REPLICA_ENDPOINT"]
end
