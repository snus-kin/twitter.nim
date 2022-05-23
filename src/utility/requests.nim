import strtabs, httpclient
import strutils
import sequtils
import json
import algorithm
import base64
import times
import uuids
import hmac

import ./types

# v1.1 : add 1.1/
# v2 : add 2/
const baseUrl = "https://api.twitter.com/"
const uploadUrl = "https://upload.twitter.com/1.1/"
const publishUrl = "https://publish.twitter.com"

# TODO investigate this, seems to be new?
# const dataAPIUrl = "https://data-api.twitter.com"

const clientUserAgent = "twitter.nim/2.0.0"

# Stolen from cgi.nim
proc encodeUrl*(s: string): string =
  ## Exclude A..Z a..z 0..9 - . _ ~
  ## See https://dev.twitter.com/oauth/overview/percent-encoding-parameters
  result = newStringOfCap(s.len + s.len shr 2) # assume 12% non-alnum-chars
  for i in 0..s.len-1:
    case s[i]
    of 'a'..'z', 'A'..'Z', '0'..'9', '_', '-', '.', '~':
      add(result, s[i])
    else:
      add(result, '%')
      add(result, toHex(ord(s[i]), 2))


proc signature(consumerSecret, accessTokenSecret, httpMethod, url: string,
    params: StringTableRef): string =
  var keys: seq[string] = @[]

  for key in params.keys:
    keys.add(key)

  keys.sort(cmpIgnoreCase)
  var query: string = keys.map(proc(x: string): string = x & "=" & params[
      x]).join("&")
  let key: string = encodeUrl(consumerSecret) & "&" & encodeUrl(accessTokenSecret)
  let base: string = httpMethod & "&" & encodeUrl(url) & "&" & encodeUrl(query)

  return encodeUrl(encode(hmac_sha1(key, base)))


proc buildParams(consumerKey, accessToken: string,
                 additionalParams: StringTableRef = nil): StringTableRef =
  var params: StringTableRef = {
                                  "oauth_version": "1.0",
                                  "oauth_consumer_key": consumerKey,
                                  "oauth_nonce": $genUUID(),
                                  "oauth_signature_method": "HMAC-SHA1",
                                  "oauth_timestamp": $(epochTime().toInt),
                                  "oauth_token": accessToken
                                }.newStringTable

  for key, value in params:
    params[key] = encodeUrl(value)
  if additionalParams != nil:
    for key, value in additionalParams:
      params[key] = encodeUrl(value)
  return params


proc buildParams(additionalParams: StringTableRef = nil): StringTableRef =
  var params: StringTableRef = newStringTable()
  if additionalParams != nil:
    for key, value in additionalParams:
      params[key] = encodeUrl(value)
  return params


proc request*(twitter: TwitterAPI, endPoint, httpMethod: string,
              additionalParams: StringTableRef = nil,
              requestUrl: string = baseUrl, data: string = ""): Response =
  let url = requestUrl & endPoint
  var keys: seq[string] = @[]

  var params = newStringTable()
  var authorize = ""
  if twitter.bearerToken == "":
    # OAuth1a flow
    authorize = "OAuth "
    params = buildParams(twitter.consumerToken.consumerKey,
                             twitter.accessToken,
                             additionalParams)
    params["oauth_signature"] = signature(twitter.consumerToken.consumerSecret,
                                          twitter.accessTokenSecret,
                                          httpMethod, url, params)

    for key in params.keys:
      if key.startsWith("oauth_"):
        authorize = authorize & key & "=" & params[key] & ","
      else:
        keys.add(key)
  else:
    # OAuth2 flow
    # TODO can we do this ? https://developer.twitter.com/en/docs/authentication/oauth-2-0/authorization-code
    params = buildParams(additionalParams)
    for key in params.keys:
      keys.add(key)

    authorize = "Bearer " & twitter.bearerToken

  let path = keys.map(proc(x: string): string = x & "=" & params[x]).join("&")
  let client = newHttpClient(userAgent = clientUserAgent)

  # Data must be in a multipart
  if data != "":
    client.headers = newHttpHeaders({"Authorization": authorize,
        "Content-Type": "multipart/form-data"})
    var mediaMultipart = newMultiPartData()
    mediaMultipart["media"] = data
    if httpMethod == "POST":
      return httpclient.post(client, url & "?" & path,
          multipart = mediaMultipart)
    else:
      raise newException(ValueError, "Can only POST with data")

  client.headers = newHttpHeaders({"Authorization": authorize,
      "Content-Type": "application/x-www-form-urlencoded"})
  if httpMethod == "GET":
    return httpclient.get(client, url & "?" & path)
  elif httpMethod == "POST":
    return httpclient.post(client, url & "?" & path)
  elif httpMethod == "DELETE":
    return httpclient.delete(client, url & "?" & path)
  elif httpMethod == "PUT":
    return httpclient.put(client, url & "?" & path)


proc request*(twitter: TwitterAPI, endPoint: string, jsonBody: JsonNode = nil,
              requestUrl: string = baseUrl): Response =
  ## Request proc for endpoints requiring `application/json` bodies
  # You can only send JSON with POST
  let httpMethod = "POST"
  let url = requestUrl & endPoint
  var keys: seq[string] = @[]

  var params = newStringTable()
  var authorize = ""
  if twitter.bearerToken == "":
    # OAuth1a flow
    authorize = "OAuth "
    params = buildParams(twitter.consumerToken.consumerKey,
                             twitter.accessToken)
    params["oauth_signature"] = signature(twitter.consumerToken.consumerSecret,
                                          twitter.accessTokenSecret,
                                          httpMethod, url, params)
    for key in params.keys:
      authorize = authorize & key & "=" & params[key] & ","
  else:
    # Oauth2 flow
    authorize = "Bearer " & twitter.bearerToken

  let client = newHttpClient(userAgent = clientUserAgent)
  client.headers = newHttpHeaders({"Authorization": authorize,
      "Content-Type": "application/json; charset=UTF-8"})

  if httpMethod == "POST":
    return httpclient.post(client, url, body = $jsonBody)


proc get*(twitter: TwitterAPI, endPoint: string,
          additionalParams: StringTableRef = nil, media: bool = false,
              publish: bool = false): Response =
  ## Raw get proc. `media` optional parameter changes request URL to
  ## `upload.twitter.com`
  if media:
    return request(twitter, endPoint, "GET", additionalParams,
        requestUrl = uploadUrl)
  elif publish:
    return request(twitter, endPoint, "GET", additionalParams,
        requestUrl = publishUrl)
  return request(twitter, endPoint, "GET", additionalParams)


proc post*(twitter: TwitterAPI, endPoint: string,
           additionalParams: StringTableRef = nil,
               media: bool = false): Response =
  ## Raw post proc. `media` optional parameter changes request URL to
  ## `upload.twitter.com`
  if media:
    return request(twitter, endPoint, "POST", additionalParams,
        requestUrl = uploadUrl)
  return request(twitter, endPoint, "POST", additionalParams)


proc post*(twitter: TwitterAPI, endPoint: string,
           additionalParams: StringTableRef = nil, media: bool = false,
           data: string): Response =
  ## Overload for post that includes binary data e.g. images / video to upload
  return request(twitter, endPoint, "POST", additionalParams,
      requestUrl = uploadUrl, data)


proc post*(twitter: TwitterAPI, endPoint: string,
           jsonBody: JsonNode, media: bool = false): Response =
  if media:
    return request(twitter, endPoint, jsonBody, requestUrl = uploadUrl)
  return request(twitter, endPoint, jsonBody)


proc delete*(twitter: TwitterAPI, endPoint: string,
             additionalParams: StringTableRef = nil): Response =
  return request(twitter, endPoint, "DELETE", additionalParams)


proc put*(twitter: TwitterAPI, endPoint: string,
             additionalParams: StringTableRef = nil): Response =
  return request(twitter, endPoint, "PUT", additionalParams)


