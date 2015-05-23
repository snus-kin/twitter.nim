import algorithm
import base64
import tables
import times
import strutils
import sequtils
import unsigned
import httpclient

import nuuid
import sha1


const baseUrl = "https://api.twitter.com/1.1/"
const oauthBaseUrl = "https://api.twitter.com/oauth/"


type ConsumerToken* = object
  consumerKey: string
  consumerSecret: string


type TwitterAPI* = object
  consumerToken: ConsumerToken
  accessToken: string
  accessTokenSecret: string


proc newConsumerToken*(consumerKey, consumerSecret: string): ConsumerToken =
  return ConsumerToken(consumerKey: consumerKey,
                       consumerSecret: consumerSecret)


proc newTwitterAPI*(consumerToken: ConsumerToken, accessToken, accessTokenSecret: string): TwitterAPI =
  return TwitterAPI(consumerToken: consumerToken,
                    accessToken: accessToken,
                    accessTokenSecret: accessTokenSecret)


proc newTwitterAPI*(consumerKey, consumerSecret, accessToken, accessTokenSecret: string): TwitterAPI =
  var consumerToken: ConsumerToken = ConsumerToken(consumerKey: consumerKey,
                                                   consumerSecret: consumerSecret)
  return TwitterAPI(consumerToken: consumerToken,
                    accessToken: accessToken,
                    accessTokenSecret: accessTokenSecret)


# Stolen from cgi.nim
proc encodeUrl*(s: string): string =
  # Exclude A..Z a..z 0..9 - . _ ~
  # See https://dev.twitter.com/oauth/overview/percent-encoding-parameters
  result = newStringOfCap(s.len + s.len shr 2) # assume 12% non-alnum-chars
  for i in 0..s.len-1:
    case s[i]
    of 'a'..'z', 'A'..'Z', '0'..'9', '_', '-', '.', '~': add(result, s[i])
    else:
      add(result, '%')
      add(result, toHex(ord(s[i]), 2))


proc padding(k: seq[uint8]): seq[uint8] =
  if 64 < k.len:
    var arr = newSeq[uint8]()
    for i, x in sha1.compute(cast[string](k)): arr.insert(x, i)
    return arr & newSeq[uint8](64 - arr.len)
  else:
    return k & newSeq[uint8](64 - k.len)


proc hmacSha1*(key, message: string): SHA1Digest =
  var k1: seq[uint8] = padding(cast[seq[uint8]](key))
  var k2: seq[uint8] = padding(cast[seq[uint8]](key))

  k1.mapIt(it xor 0x5c)
  k2.mapIt(it xor 0x36)

  var arr: seq[uint8] = @[]

  for x in sha1.compute(cast[string](k2) & message):
    arr.add(x)

  return sha1.compute(k1 & arr)


proc signature*(consumerSecret, accessTokenSecret, httpMethod, url: string, params: Table): string =
  var keys: seq[string] = @[]

  for key in params.keys:
    keys.add(key)

  keys.sort(cmpIgnoreCase)

  var query: string = keys.mapIt(string, $(it & "=" & params[it])).join("&")
  var key: string = encodeUrl(consumerSecret) & "&" & encodeUrl(accessTokenSecret)
  var base: string = httpMethod & "&" & encodeUrl(url) & "&" & encodeUrl(query)

  return encodeUrl(hmacSha1(key, base).toBase64)


proc buildParams(consumerKey, accessToken: string,
                 additionalParams: Table[string, string] = initTable[string, string]()
                 ): Table[string, string] =
  var params: Table[string, string] = initTable[string, string]()
  params["oauth_version"] = "1.0"
  params["oauth_consumer_key"] = consumerKey
  params["oauth_nonce"] = generateUUID()
  params["oauth_signature_method"] = "HMAC-SHA1"
  params["oauth_timestamp"] = epochTime().toInt.repr
  params["oauth_token"] = accessToken

  for key, value in params: params[key] = encodeUrl(value)
  for key, value in additionalParams: params[key] = encodeUrl(value)
  return params


proc request*(twitter: TwitterAPI, endPoint, httpMethod: string,
              additionalParams: Table[string, string] = initTable[string, string]()): Response =
  var url = baseUrl & endPoint
  var keys: seq[string] = @[]

  var params: Table[string, string] = buildParams(twitter.consumerToken.consumerKey,
                                                  twitter.accessToken,
                                                  additionalParams)
  params["oauth_signature"] = signature(twitter.consumerToken.consumerSecret,
                                        twitter.accessTokenSecret,
                                        httpMethod, url, params)

  for key in params.keys:
    keys.add(key)

  var authorizeKeys = keys.filter(proc(x: string): bool = x.startsWith("oauth_"))
  var authorize = "OAuth " & authorizeKeys.mapIt(string, $(it & "=" & params[it])).join(",")
  var path = keys.mapIt(string, $(it & "=" & params[it])).join("&")

  if httpMethod == "GET":
    return httpclient.get(url & "?" & path, "Authorization: " & authorize & "\c\L")
  elif httpMethod == "POST":
    return httpclient.post(url & "?" & path, " Authorization: " & authorize & "\c\L")


proc get*(twitter: TwitterAPI, endPoint: string,
          additionalParams: Table[string, string] = initTable[string, string]()): Response =
  return request(twitter, endPoint, "GET", additionalParams)


proc post*(twitter: TwitterAPI, endPoint: string,
          additionalParams: Table[string, string] = initTable[string, string]()): Response =
  return request(twitter, endPoint, "POST", additionalParams)


proc statusesUpdate*(twitter: TwitterAPI,
                    additionalParams: Table[string, string]): Response =
  return post(twitter, "statuses/update.json", additionalParams)


proc userTimeline*(twitter: TwitterAPI,
                   additionalParams: Table[string, string] = initTable[string, string]()): Response =
  return get(twitter, "statuses/user_timeline.json", additionalParams)


proc homeTimeline*(twitter: TwitterAPI,
                   additionalParams: Table[string, string] = initTable[string, string]()): Response =
  return get(twitter, "statuses/home_timeline.json", additionalParams)


proc mentionsTimeline*(twitter: TwitterAPI,
                       additionalParams: Table[string, string] = initTable[string, string]()): Response =
  return get(twitter, "statuses/mentions_timeline.json", additionalParams)


proc retweetsOfMe*(twitter: TwitterAPI,
                   additionalParams: Table[string, string] = initTable[string, string]()): Response =
  return get(twitter, "statuses/retweets_of_me.json", additionalParams)


template callAPI*(twitter: TwitterAPI,
                  api: expr,
                  additionalParams: Table[string, string] = initTable[string, string]()): expr =
  api(twitter, additionalParams)
