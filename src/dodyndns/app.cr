require "log"
require "./client"
require "./json_mapping"

module Dodyndns
  class App
    def initialize(access_token : String, log_level = Log::Severity)
      @client = Dodyndns::Client.new(access_token)

      backend = Log::IOBackend.new(STDOUT)
      Log.builder.bind("*", log_level, backend)
    end

    def update_ipv4(domain : String, name : String, ip : String | Nil)
      update_ip(domain, name, 4, ip)
    end

    def update_ipv6(domain : String, name : String, ip : String | Nil)
      update_ip(domain, name, 6, ip)
    end

    private def update_ip(domain : String, name : String, ip_version : Int32, ip : String | Nil)
      unless [4, 6].includes?(ip_version)
        Log.error { "IP version is not 4 or 6. It's #{ip_version}." }
        exit 1
      end

      Log.debug { "Domain: #{domain}" }
      Log.debug { "Name: #{name}" }
      Log.debug { "IP Version: #{ip_version}" }

      dns_type = ip_version == 4 ? "A" : "AAAA"
      Log.debug { "DNS Type: #{dns_type}" }

      unless ip
        ip_response = HTTP::Client.get("https://ipv#{ip_version}.srvd.be")
        if ip_response.success?
          ip = ip_response.body.lines.first
        else
          Log.error { "Could not figure out the IP address." }
          Log.debug { "Response: #{ip_response.body}" }
          exit 1
        end
      end

      Log.debug { "IP: #{ip}" }

      records_response = @client.get("/v2/domains/#{domain}/records?per_page=200")
      if records_response.success?
        json = records_response.body
      else
        Log.error { "Could not fetch DNS records for #{domain}." }
        Log.debug { "Response: #{records_response.body}" }
        exit 1
      end

      records = Dodyndns::DomainRecords.from_json(json).domain_records
      records.select! { |record| record.name == name && record.type == dns_type }

      if records.size == 0
        Log.error { "No #{dns_type} record found for #{name}.#{domain}. Please create a record (manually) first." }
        exit 1
      elsif records.size > 1
        Log.error { "#{records.size} #{dns_type} records found for #{name}.#{domain}. Please make sure only one exists." }
        exit 1
      end

      record = records.first

      Log.debug { "Record ID: #{record.id}" }
      Log.debug { "Current IP: #{record.data}" }

      if record.data == ip
        Log.info { "Not updating #{dns_type} record for #{name}.#{domain} since the IP address hasn't changed." }
      else
        Log.info { "Updating #{dns_type} record for #{name}.#{domain} from #{record.data} to #{ip}." }
        res = @client.put("/v2/domains/#{domain}/records/#{record.id}", "{\"data\":\"#{ip}\"}")
        Log.debug { "Update response: #{res.body}" } # TODO
      end
    end
  end
end
