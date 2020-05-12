require "option_parser"
require "./app"
require "./version"

domain = ""
name = ""
access_token = ""
addresses = Hash(String, Nil | String){
  "ipv4" => nil,
  "ipv6" => nil,
}
options = Hash(String, Bool){
  "set_ipv4" => true,
  "set_ipv6" => true,
}
log_level = Log::Severity::Info

OptionParser.parse do |parser|
  parser.banner = "Usage: dodyndns --domain <domain> --name <name>"

  parser.on("--domain DOMAIN", "The domain name the DNS record is managed on") { |value| domain = value }
  parser.on("--name NAME", "The DNS record name") { |value| name = value }
  parser.on("--access-token ACCESS_TOKEN", "A Digital Oceean Personal Access Token (see https://cloud.digitalocean.com/account/api/tokens/new) - this can also be set using DIGITALOCEAN_ACCESS_TOKEN") { |value| access_token = value }
  parser.on("--ipv4 IPV4", "Explicitly set the IPv4 record to this value") { |value| addresses["ipv4"] = value }
  parser.on("--ipv6 IPV6", "Explicitly set the IPv6 record to this value") { |value| addresses["ipv6"] = value }
  parser.on("--no-ipv4", "Don't manage IPv4 (A) records") { options["set_ipv4"] = false }
  parser.on("--no-ipv6", "Don't manage IPv6 (AAAA) records") { options["set_ipv6"] = false }
  parser.on("--debug", "Enable debug logging") { log_level = Log::Severity::Debug }

  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end

  parser.on("-v", "--version", "Show version and exit") do
    puts Dodyndns::VERSION
    exit
  end

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit 1
  end

  parser.missing_option do |flag|
    STDERR.puts "ERROR: #{flag} has no value set."
    STDERR.puts parser
    exit 1
  end
end

module Dodyndns
  def self.run(domain : String, name : String, access_token : String, addresses : Hash, options : Hash, log_level : Log::Severity)
    app = Dodyndns::App.new(access_token, log_level)

    app.update_ipv4(domain, name, addresses["ipv4"]) if options["set_ipv4"]
    app.update_ipv6(domain, name, addresses["ipv6"]) if options["set_ipv6"]
  end
end

if domain.empty?
  STDERR.puts "ERROR: domain is not given"
  exit 1
end

if name.empty?
  STDERR.puts "ERROR: name is not given"
  exit 1
end

if access_token.empty?
  access_token = ENV["DIGITALOCEAN_ACCESS_TOKEN"] if ENV.has_key?("DIGITALOCEAN_ACCESS_TOKEN")

  if access_token.empty?
    STDERR.puts "ERROR: access-token is not given"
    exit 1
  end
end

Dodyndns.run(domain, name, access_token, addresses, options, log_level)
