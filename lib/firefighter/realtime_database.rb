module Firefighter
  class RealtimeDatabase
    include Web

    def self.from_env
      new(
        db_name: ENV['FIREBASE_WEB_DB_NAME'],
        db_secret: ENV['FIREBASE_WEB_DB_SECRET'],
        db_host: ENV['FIREBASE_WEB_DB_NAME'] || DEFAULT_DB_HOST,
      )
    end

    DB_HOSTS = {
      'us-central1' => 'firebaseio.com',
      'europe-west1' => 'europe-west1.firebasedatabase.app',
    }
    DEFAULT_DB_HOST = DB_HOSTS['us-central1']

    def initialize(db_name:, db_secret:, db_host: DEFAULT_DB_HOST)
      @db_name = db_name
      @db_secret = db_secret
      @db_host = db_host
    end

    def listen(path)
      url = endpoint(path)
      sse(url) do |connection, event, payload|
        data = JSON.parse(payload)
        yield connection, event, data['path'], data['data']
      end
    end

    def read(path)
      url = endpoint(path)
      call(:get, url)
    end

    def write(path, data)
      url = endpoint(path)
      call(:put, url, data)
    end

    def add(path, data)
      url = endpoint(path)
      call(:post, url, data)
    end

    def delete(path)
      url = endpoint(path)
      call(:delete, url)
    end

    private

    def endpoint(path)
      "https://#{@db_name}.#{@db_host}/#{path}.json?auth=#{@db_secret}"
    end
  end
end
