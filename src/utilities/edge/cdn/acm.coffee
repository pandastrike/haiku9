{async, collect, where, empty, cat, compact, intersection, first, project} = require "fairmont"

module.exports = (config, acm) ->
  # TODO: Consider how to handle multiple region cert placement.
  {root, regularlyQualify} = require("../url")(config)

  wild = (name) -> regularlyQualify "*." + root name
  apex = (name) -> regularlyQualify root name
  needsApex = -> config.aws.domain in config.aws.hostnames

  list = async (current=[], token) ->
    params = CertificateStatuses: [ "ISSUED" ]
    params.NextToken = token if token
    {CertificateSummaryList, NextToken} = yield acm.listCertificates params
    current = cat current, CertificateSummaryList

    if NextToken
      yield list current, NextToken
    else
      current

  # Looks through many certs looking for a given domain as the primary.
  get = (name, list) -> collect where {DomainName: name}, list
  wildGet = (name, list) -> get wild(name), list
  apexGet = (name, list) -> get apex(name), list

  # Looks within an individual cert for its coverage of a given domain.
  scan = async (name, CertificateArn) ->
    {Certificate} = yield acm.describeCertificate {CertificateArn}
    alternates = Certificate.SubjectAlternativeNames
    if name in alternates then CertificateArn else undefined

  multiScan = async (name, list) ->
    arns = (yield scan name, cert.CertificateArn for cert in list)
    collect compact arns

  wildScan = async (name, list) -> yield multiScan wild(name), list
  apexScan = async (name, list) -> yield multiScan apex(name), list

  containsWild = async (name, list) ->
    wildArns = collect project "CertificateArn", wildGet(name, list)
    certs = apexGet name, list
    cat wildArns, yield wildScan(name, certs)

  containsApex = async (name, list) ->
    apexArns = collect project "CertificateArn", apexGet(name, list)
    certs = wildGet name, list
    cat apexArns, yield apexScan(name, certs)

  hasBoth = async (name, list) ->
    a = yield containsApex name, list
    w = yield containsWild name, list
    i = intersection a, w
    if empty i then false else first i

  match = async (name, list) ->
    if needsApex()
      yield hasBoth name, list
    else
      certs = yield containsWild(name, list)
      if empty certs then false else first certs

  fetch = async (name) ->
    if arn = yield match name, yield list()
      arn
    else
      throw new Error "Unable to find the required certs in ACM."

  {fetch}
