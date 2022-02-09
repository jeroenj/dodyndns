require "json"

module Dodyndns
  class DomainRecords
    include JSON::Serializable

    property domain_records : Array(DomainRecord)
  end

  class DomainRecord
    include JSON::Serializable

    property id : Int64
    property type : String
    property name : String
    property data : String
  end
end
