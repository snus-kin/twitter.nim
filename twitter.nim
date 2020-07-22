import algorithm
import base64
import httpclient
import sequtils
import strtabs
import strutils
import times

import uuids
import hmac


const baseUrl = "https://api.twitter.com/1.1/"
const uploadUrl = "https://upload.twitter.com/1.1/"
const clientUserAgent = "twitter.nim/0.2.2"


type
  ConsumerTokenImpl = object
    consumerKey: string
    consumerSecret: string

  ConsumerToken* = ref ConsumerTokenImpl
  ## Consumer token with a consumerKey and consumerSecret

  TwitterAPIImpl = object
    consumerToken: ConsumerToken
    accessToken: string
    accessTokenSecret: string

  TwitterAPI* = ref TwitterAPIImpl 
  ## TwitterAPI token container with a consumerToken, accessToken, and accessTokenSecret

proc newConsumerToken*(consumerKey, consumerSecret: string): ConsumerToken =
  return ConsumerToken(consumerKey: consumerKey,
                       consumerSecret: consumerSecret)


proc newTwitterAPI*(consumerToken: ConsumerToken, accessToken, accessTokenSecret: string): TwitterAPI =
  return TwitterAPI(consumerToken: consumerToken,
                    accessToken: accessToken,
                    accessTokenSecret: accessTokenSecret)


proc newTwitterAPI*(consumerKey, consumerSecret, accessToken, accessTokenSecret: string): TwitterAPI =
  let consumerToken: ConsumerToken = ConsumerToken(consumerKey: consumerKey,
                                                   consumerSecret: consumerSecret)
  return TwitterAPI(consumerToken: consumerToken,
                    accessToken: accessToken,
                    accessTokenSecret: accessTokenSecret)


# Stolen from cgi.nim
proc encodeUrl(s: string): string =
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


proc signature(consumerSecret, accessTokenSecret, httpMethod, url: string, params: StringTableRef): string =
  var keys: seq[string] = @[]

  for key in params.keys:
    keys.add(key)

  keys.sort(cmpIgnoreCase)

  let query: string = keys.map(proc(x: string): string = x & "=" & params[x]).join("&")
  let key: string = encodeUrl(consumerSecret) & "&" & encodeUrl(accessTokenSecret)
  let base: string = httpMethod & "&" & encodeUrl(url) & "&" & encodeUrl(query)

  return encodeUrl(encode(hmac_sha1(key, base)))


proc buildParams(consumerKey, accessToken: string,
                 additionalParams: StringTableRef = nil): StringTableRef =
  var params: StringTableRef = { "oauth_version": "1.0",
                                 "oauth_consumer_key": consumerKey,
                                 "oauth_nonce": $genUUID(),
                                 "oauth_signature_method": "HMAC-SHA1",
                                 "oauth_timestamp": $(epochTime().toInt),
                                 "oauth_token": accessToken }.newStringTable

  for key, value in params:
    params[key] = encodeUrl(value)
  if additionalParams != nil:
    for key, value in additionalParams:
      params[key] = encodeUrl(value)
  return params


proc request*(twitter: TwitterAPI, endPoint, httpMethod: string,
              additionalParams: StringTableRef = nil,
              requestUrl: string = baseUrl, data: string = ""): Response =
  let url = requestUrl & endPoint
  var keys: seq[string] = @[]

  var params = buildParams(twitter.consumerToken.consumerKey,
                           twitter.accessToken,
                           additionalParams)
  params["oauth_signature"] = signature(twitter.consumerToken.consumerSecret,
                                        twitter.accessTokenSecret,
                                        httpMethod, url, params)

  for key in params.keys:
    keys.add(key)

  let authorizeKeys = keys.filter(proc(x: string): bool = x.startsWith("oauth_"))
  let authorize = "OAuth " & authorizeKeys.map(proc(x: string): string = x & "=" & params[x]).join(",")
  let path = keys.map(proc(x: string): string = x & "=" & params[x]).join("&")
  let client = newHttpClient(userAgent = clientUserAgent)
  client.headers = newHttpHeaders({ "Authorization": authorize })
  
  # Data must be a multiPartData and not a stringTable ref
  if data != "":
    var mediaMultipart = newMultiPartData()
    mediaMultipart["media"] = data
    if httpMethod == "POST":
      return httpclient.post(client, url & "?" & path, multipart=mediaMultipart)
    else:
      raise newException(ValueError, "Can only POST with data")

  if httpMethod == "GET":
    return httpclient.get(client, url & "?" & path)
  elif httpMethod == "POST":
    return httpclient.post(client, url & "?" & path)


proc get*(twitter: TwitterAPI, endPoint: string,
          additionalParams: StringTableRef = nil, media: bool = false): Response =
  ## Raw get function, media optional parameter enables requests to the twitter media endpoints
  if media:
    return request(twitter, endPoint, "GET", additionalParams, requestUrl=uploadUrl)
  return request(twitter, endPoint, "GET", additionalParams)


proc post*(twitter: TwitterAPI, endPoint: string,
           additionalParams: StringTableRef = nil, media: bool = false): Response =
  ## Raw post function, media optional parameter enables requests to the twitter media endpoints
  if media:
    return request(twitter, endPoint, "POST", additionalParams, requestUrl=uploadUrl)
  return request(twitter, endPoint, "POST", additionalParams)


proc post*(twitter: TwitterAPI, endPoint: string, 
           additionalParams: StringTableRef = nil, media: bool = false, 
           data: string): Response =
  ## Overload for post that includes binary data e.g. images / video to upload
  if media:
    return request(twitter, endPoint, "POST", additionalParams, requestUrl=uploadUrl, data)
  return request(twitter, endPoint, "POST", additionalParams)


proc statusesUpdate*(twitter: TwitterAPI,
                    additionalParams: StringTableRef = nil): Response =
  return post(twitter, "statuses/update.json", additionalParams)


proc userTimeline*(twitter: TwitterAPI,
                   additionalParams: StringTableRef = nil): Response =
  return get(twitter, "statuses/user_timeline.json", additionalParams)


proc homeTimeline*(twitter: TwitterAPI,
                   additionalParams: StringTableRef = nil): Response =
  return get(twitter, "statuses/home_timeline.json", additionalParams)


proc mentionsTimeline*(twitter: TwitterAPI,
                       additionalParams: StringTableRef = nil): Response =
  return get(twitter, "statuses/mentions_timeline.json", additionalParams)


proc retweetsOfMe*(twitter: TwitterAPI,
                   additionalParams: StringTableRef = nil): Response =
  return get(twitter, "statuses/retweets_of_me.json", additionalParams)


proc user*(twitter: TwitterAPI,
           additionalParams: StringTableRef = nil): Response =
  return get(twitter, "account/verify_credentials.json", additionalParams)


proc user*(twitter: TwitterAPI, screenName: string,
           additionalParams: StringTableRef = nil): Response =
  ## users/show.json endpoint for screen names (@username)
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "users/show.json", additionalParams)
  else:
    return get(twitter, "users/show.json", {"screen_name": screenName}.newStringTable)


proc user*(twitter: TwitterAPI, userId: int32,
           additionalParams: StringTableRef = nil): Response =
  ## users/show.json endpoint for user id (e.g. 783214 =is=> @twitter)
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "users/show.json", additionalParams)
  else:
    return get(twitter, "users/show.json", {"user_id": $userId}.newStringTable)


proc uploadFile*(twitter: TwitterAPI, filename: string,
                 mediaType: string, additionalParams: StringTableRef = nil): Response =
  ## Upload a file from a filename, mediaType takes these arguments: `[amplify_video, tweet_gif, tweet_image, tweet_video]`
  # This is a bit 'higher level' than the rest but IMO is routine enough and simple enough to make it useful
  var ubody = additionalParams
  ubody["media_type"] = mediaType
  let data = $ readFile(filename)
  return post(twitter, "media/upload.json", ubody, true, data)


proc mediaUploadInit*(twitter: TwitterAPI, 
                      mediaType: string, totalBytes: string, 
                      additionalParams: StringTableRef = nil): Response =
  ## INIT command for media upload 
  ## See: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-upload-init
  ## mediaType should be the MIME type for the data you are sending, 
  ## The response returned from this will contain a media_id field that you need to provide to the other mediaUpload procs
  # These need to be multipart form data 
  var ubody = newStringTable()
  if additionalParams != nil:
    ubody = additionalParams
  ubody["command"] = "INIT"
  ubody["media_type"] = mediaType
  ubody["total_bytes"] = totalBytes
  return post(twitter, "media/upload.json", ubody, true)


proc mediaUploadAppend*(twitter: TwitterAPI, mediaId: string, segmentId: string,
                        data: string, additionalParams: StringTableRef = nil): Response =
  ## APPEND command for media upload 
  ## See: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-upload-append
  # These need to be multipart form data 
  var ubody = newStringTable()
  if additionalParams != nil:
    ubody = additionalParams
  ubody["command"] = "APPEND"
  ubody["media_id"] = mediaId
  ubody["segment_index"] = segmentId
  return post(twitter, "media/upload.json", ubody, true, data)


proc mediaUploadStatus*(twitter: TwitterAPI, mediaId: string,
           additionalParams: StringTableRef = nil): Response=
  ## STATUS command for media upload see: https://developer.twitter.com/en/docs/media/upload-media/api-reference/get-media-upload-status
  var ubody = newStringTable()
  if additionalParams != nil:
    ubody = additionalParams
  ubody["command"] = "STATUS"
  ubody["media_id"] = mediaId
  return get(twitter, "media/upload.json", ubody, true)


proc mediaUploadFinalize*(twitter: TwitterAPI, mediaId: string,
           additionalParams: StringTableRef = nil): Response=
  ## FINALIZE command for media upload 
  ## See: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-upload-finalize
  var ubody = newStringTable()
  if additionalParams != nil:
    ubody = additionalParams
  ubody["command"] = "FINALIZE"
  ubody["media_id"] = mediaId
  return post(twitter, "media/upload.json", ubody, true)


template callAPI*(twitter: TwitterAPI, api: untyped,
                  additionalParams: StringTableRef = nil): untyped =
  api(twitter, additionalParams)


when isMainModule:
  import unittest

  suite "test for encodeUrl":
    # https://dev.twitter.com/oauth/overview/percent-encoding-parameters
    test "examples from twitter's percent-encoding parameters.":
      check(encodeUrl("Ladies + Gentlemen") == "Ladies%20%2B%20Gentlemen")
      check(encodeUrl("An encoded string!") == "An%20encoded%20string%21")
      check(encodeUrl("Dogs, Cats & Mice") == "Dogs%2C%20Cats%20%26%20Mice")
      check(encodeUrl("☃") == "%E2%98%83")

  suite "test for hmacSha1":
    # https://dev.twitter.com/oauth/overview/creating-signatures
    test "test for hmacSha1 function.":
      check(encode(hmac_sha1("kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw&LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE",
                     "POST&https%3A%2F%2Fapi.twitter.com%2F1%2Fstatuses%2Fupdate.json&include_entities%3Dtrue%26oauth_consumer_key%3Dxvz1evFS4wEEPTGEFPHBog%26oauth_nonce%3DkYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1318622958%26oauth_token%3D370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb%26oauth_version%3D1.0%26status%3DHello%2520Ladies%2520%252B%2520Gentlemen%252C%2520a%2520signed%2520OAuth%2520request%2521")) == "tnnArxj06cWHq44gCs1OSKk/jLY=")
