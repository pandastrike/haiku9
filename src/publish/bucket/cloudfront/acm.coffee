{async, collect, where, empty} = require "fairmont"

{root, regularlyQualify} = require "../url"

module.exports = (acm) ->

  fetch = async (name) ->
    wild = (name) -> regularlyQualify "*." + root name

    try
      data = yield acm.listCertificates CertificateStatuses: [ "ISSUED" ]
      cert = collect where {DomainName: wild name}, data.CertificateSummaryList
    catch e
      console.error "Unexpected response while searching SSL certs.", e
      throw new Error()

    if empty cert
      console.error "You do not have an active certificate for", wild name
      throw new Error()
    else
      cert[0].CertificateArn

  {fetch}
