require "json"

module Dodyndns
  class DomainRecords
    JSON.mapping(
      domain_records: {type: Array(DomainRecord)}
    )
  end

  class DomainRecord
    JSON.mapping(
      id: Int64,
      type: String,
      name: String,
      data: String
    )
  end
end
