require "http/client"
require "json"

module Dodyndns
  class Client
    def initialize(@access_token : String)
      @headers = HTTP::Headers{
        "Authorization" => "Bearer #{@access_token}",
        "Content-Type" => "application/json"
      }
      @http_client = HTTP::Client.new("api.digitalocean.com", 443, true)
    end

    def get(url : String)
      @http_client.get(url, @headers)
    end

    def put(url : String, body : String)
      @http_client.put(url, @headers, body)
    end
  end
end
