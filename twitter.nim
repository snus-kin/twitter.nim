import algorithm
import base64
import httpclient
import sequtils
import strtabs
import strutils
import times
import uuids
import hmac
import json


const baseUrl = "https://api.twitter.com/1.1/"
const uploadUrl = "https://upload.twitter.com/1.1/"
const clientUserAgent = "twitter.nim/1.0.0"


type
  ConsumerTokenImpl = object
    consumerKey: string
    consumerSecret: string

  ConsumerToken* = ref ConsumerTokenImpl ## \
    ## Consumer token object with a `consumerKey` and `consumerSecret`

  TwitterAPIImpl = object
    consumerToken: ConsumerToken
    accessToken: string
    accessTokenSecret: string

  TwitterAPI* = ref TwitterAPIImpl ## \
    ## TwitterAPI token object with a `consumerToken`, `accessToken`, and `accessTokenSecret`

proc newConsumerToken*(consumerKey, consumerSecret: string): ConsumerToken =
  return ConsumerToken(consumerKey: consumerKey,
                       consumerSecret: consumerSecret)


proc newTwitterAPI*(consumerToken: ConsumerToken, accessToken, accessTokenSecret: string): TwitterAPI =
  return TwitterAPI(consumerToken: consumerToken,
                    accessToken: accessToken,
                    accessTokenSecret: accessTokenSecret)


proc newTwitterAPI*(consumerKey, consumerSecret, 
                    accessToken, accessTokenSecret: string): TwitterAPI =
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
  var query: string = keys.map(proc(x: string): string = x & "=" & params[x]).join("&")
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
  
  # Data must be in a multipart
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
  elif httpMethod == "DELETE":
    return httpclient.delete(client, url & "?" & path)


proc request*(twitter: TwitterAPI, endPoint: string, jsonBody: JsonNode = nil,
              requestUrl: string = baseUrl): Response =
  ## Request proc for endpoints requiring `application/json` bodies
  # You can only send JSON with POST
  let httpMethod = "POST"
  let url = requestUrl & endPoint
  var keys: seq[string] = @[]

  var params = buildParams(twitter.consumerToken.consumerKey,
                           twitter.accessToken)
  params["oauth_signature"] = signature(twitter.consumerToken.consumerSecret,
                                        twitter.accessTokenSecret,
                                        httpMethod, url, params)

  for key in params.keys:
    keys.add(key)

  let authorize = "OAuth " & keys.map(proc(x: string): string = x & "=" & params[x]).join(",")
  let client = newHttpClient(userAgent = clientUserAgent)
  client.headers = newHttpHeaders({"Authorization": authorize, "Content-Type": "application/json; charset=UTF-8"})

  if httpMethod == "POST":
    return httpclient.post(client, url, body= $jsonBody)


proc get*(twitter: TwitterAPI, endPoint: string,
          additionalParams: StringTableRef = nil, media: bool = false): Response =
  ## Raw get proc. `media` optional parameter changes request URL to
  ## `upload.twitter.com`
  if media:
    return request(twitter, endPoint, "GET", additionalParams, requestUrl=uploadUrl)
  return request(twitter, endPoint, "GET", additionalParams)


proc post*(twitter: TwitterAPI, endPoint: string,
           additionalParams: StringTableRef = nil, media: bool = false): Response =
  ## Raw post proc. `media` optional parameter changes request URL to
  ## `upload.twitter.com`
  if media:
    return request(twitter, endPoint, "POST", additionalParams, requestUrl=uploadUrl)
  return request(twitter, endPoint, "POST", additionalParams)


proc post*(twitter: TwitterAPI, endPoint: string, 
           additionalParams: StringTableRef = nil, media: bool = false, 
           data: string): Response =
  ## Overload for post that includes binary data e.g. images / video to upload
  return request(twitter, endPoint, "POST", additionalParams, requestUrl=uploadUrl, data)


proc post*(twitter: TwitterAPI, endPoint: string,
           jsonBody: JsonNode, media: bool = false): Response =
  if media:
    return request(twitter, endPoint, jsonBody, requestUrl=uploadUrl)
  return request(twitter, endPoint, jsonBody)


proc delete*(twitter: TwitterAPI, endPoint: string, 
             additionalParams: StringTableRef = nil): Response = 
  return request(twitter, endPoint, "DELETE", additionalParams)

# --------------
# authentication
# --------------
# TODO


# -----
# lists
# -----
# TODO


# ---------------------------------
# followers / friends / friendships
# ---------------------------------
# TODO


# -----
# users
# -----
# TODO


proc usersShow*(twitter: TwitterAPI, screenName: string,
           additionalParams: StringTableRef = nil): Response =
  ## `users/show.json` endpoint for screen names (@username)
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "users/show.json", additionalParams)
  else:
    return get(twitter, "users/show.json", {"screen_name": screenName}.newStringTable)


proc usersShow*(twitter: TwitterAPI, userId: int32,
           additionalParams: StringTableRef = nil): Response =
  ## `users/show.json` endpoint for user id (e.g. `783214 => @twitter`)
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "users/show.json", additionalParams)
  else:
    return get(twitter, "users/show.json", {"user_id": $userId}.newStringTable)


# -------
# account
# -------
# TODO

proc accountVerifyCredentials*(twitter: TwitterAPI,
           additionalParams: StringTableRef = nil): Response =
  ## `account/verify_credentials.json` endpoint
  return get(twitter, "account/verify_credentials.json", additionalParams)

# --------------
# saved_searches
# --------------
#TODO


# --------------
# blocks / mutes
# --------------
#TODO


# -----------
# collections
# -----------
# TODO


# --------
# statuses
# --------
# TODO

proc statusesUpdate*(twitter: TwitterAPI,
                    additionalParams: StringTableRef = nil): Response =
  ## `statuses/update.json` endpoint
  return post(twitter, "statuses/update.json", additionalParams)


proc statusesUserTimeline*(twitter: TwitterAPI,
                   additionalParams: StringTableRef = nil): Response =
  ## `statuses/user_timeline.json` endpoint
  return get(twitter, "statuses/user_timeline.json", additionalParams)


proc statusesHomeTimeline*(twitter: TwitterAPI,
                   additionalParams: StringTableRef = nil): Response =
  ## `statuses/home_timeline.json` endpoint
  return get(twitter, "statuses/home_timeline.json", additionalParams)


proc statusesMentionsTimeline*(twitter: TwitterAPI,
                       additionalParams: StringTableRef = nil): Response =
  ## `statuses/mentions_timeline.json` endpoint
  return get(twitter, "statuses/mentions_timeline.json", additionalParams)


proc statusesRetweetsOfMe*(twitter: TwitterAPI,
                   additionalParams: StringTableRef = nil): Response =
  ## `statuses/retweets_of_me.json` endpoint
  return get(twitter, "statuses/retweets_of_me.json", additionalParams)


# ---------
# favorites
# ---------
# TODO


# ----------
# compliance
# ----------
# TODO


# ---------------
# custom_profiles
# ---------------
# TODO


# ---------------
# direct_messages
# ---------------
# TODO


# -----
# media
# -----

proc mediaUploadInit*(twitter: TwitterAPI, 
                      mediaType: string, totalBytes: string, 
                      additionalParams: StringTableRef = nil): Response =
  ## `INIT` command for `media/upload.json` endpoint
  ##
  ## Docs: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-upload-init
  ##
  ## `mediaType` should be the MIME type for the data you are sending.
  ##
  ## The response returned from this will contain a media_id field that you
  ## need to provide to the other `mediaUpload` procs
  if additionalParams != nil:
    additionalParams["command"] = "INIT"
    additionalParams["media_type"] = mediaType
    additionalParams["total_bytes"] = totalBytes
    return post(twitter, "media/upload.json", additionalParams, true)
  else:
    return post(twitter, "media/upload.json", {"command":"INIT", "media_type":mediaType, "total_bytes":totalBytes}.newStringTable, true)


proc mediaUploadAppend*(twitter: TwitterAPI, mediaId: string, segmentId: string,
                        data: string, additionalParams: StringTableRef = nil): Response =
  ## `APPEND` command for `media/upload.json` endpoint
  ##
  ## Docs: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-upload-append
  ##
  ## Appends a chunk of data to a media upload, can accept base64 or binary
  if additionalParams != nil:
    additionalParams["command"] = "APPEND"
    additionalParams["media_id"] = mediaId
    additionalParams["segment_index"] = segmentId
    return post(twitter, "media/upload.json", additionalParams, true, data)
  else:
    return post(twitter, "media/upload.json", {"command":"APPEND", "media_id":mediaId, "segment_index":segmentId}.newStringTable, true, data)


proc mediaUploadStatus*(twitter: TwitterAPI, mediaId: string,
           additionalParams: StringTableRef = nil): Response=
  ## `STATUS` command for `media/upload.json` endpoint 
  ##
  ## Docs: https://developer.twitter.com/en/docs/media/upload-media/api-reference/get-media-upload-status
  ##
  ## Used to check the processing status of an upload. This should only be run
  ## when mediaUploadFinalize_ returns a `processing_info` field otherwise a
  ## 404 will be generated
  if additionalParams != nil:
    additionalParams["command"] = "STATUS"
    additionalParams["media_id"] = mediaId
    return get(twitter, "media/upload.json", additionalParams, true)
  else:
    return get(twitter, "media/upload.json", {"command":"STATUS", "media_id":mediaId}.newStringTable, true)


proc mediaUploadFinalize*(twitter: TwitterAPI, mediaId: string,
           additionalParams: StringTableRef = nil): Response=
  ## `FINALIZE` command for `media/upload.json` endpoint
  ##
  ## Docs: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-upload-finalize
  ##
  ## Used to tell twitter your upload is finished. Will return a response
  ## with a `processing_info` field if further processing needs to be done use
  ## mediaUploadStatus_ to poll until completion.
  if additionalParams != nil:
    additionalParams["command"] = "FINALIZE"
    additionalParams["media_id"] = mediaId
    return post(twitter, "media/upload.json", additionalParams, true)
  else:
    return post(twitter, "media/upload.json", {"command":"FINALIZE", "media_id":mediaId}.newStringTable, true)


proc mediaMetadataCreate*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
  ## `media/metadata/create.json` endpoint
  ##
  ## Docs: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-metadata-create
  return post(twitter, "media/metadata/create.json", jsonBody, media=true)


proc mediaSubtitlesCreate*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
  ## `media/subtitles/create.json` endpoint
  ##
  ## Docs: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-subtitles-create
  return post(twitter, "media/subtitles/create.json", jsonBody, media=true)


proc mediaSubtitlesDelete*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
  ## `media/subtitles/delete.json` endpoint
  ##
  ## Docs: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-subtitles-create
  return post(twitter, "media/subtitles/delete.json", jsonBody, media=true)


# ------
# trends
# ------


proc trendsAvailable*(twitter:TwitterAPI, additionalParams: StringTableRef = nil): Response = 
  ## `trends/available.json` endpoint
  return get(twitter, "trends/available.json", additionalParams)


proc trendsClosest*(twitter:TwitterAPI, lat: float, lon: float, additionalParams: StringTableRef = nil): Response = 
  ## `trends/closest.json` endpoint
  if additionalParams != nil:
    additionalParams["lat"] = $ lat
    additionalParams["lon"] = $ lon
    return get(twitter, "trends/closest.json", additionalParams)
  else:
    return get(twitter, "trends/closest.json", {"lat": $lat, "lon": $lon}.newStringTable)


proc trendsPlace*(twitter:TwitterAPI, id: int32, additionalParams: StringTableRef = nil): Response = 
  ## `trends/place.json` endpoint
  # id is explicitly int32 since it is Yahoo WOED which uses 32 bit ints
  if additionalParams != nil:
    additionalParams["id"] = $ id
    return get(twitter, "trends/place.json", additionalParams)
  else:
    return get(twitter, "trends/place.json", {"id": $id}.newStringTable)


# ---
# geo
# ---


proc geoId*(twitter:TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
  ## `geo/id/:place_id.json` endpoint
  return get(twitter, "geo/id/" & id & ".json", additionalParams)


proc geoReverseGeocode*(twitter:TwitterAPI, lat: float, lon: float,
                        additionalParams: StringTableRef = nil): Response =
  ## `geo/reverse_geocode.json` endpoint
  if additionalParams != nil:
    additionalParams["lat"] = $ lat
    additionalParams["lon"] = $ lon
    return get(twitter, "geo/reverse_geocode.json", additionalParams)
  else:
    return get(twitter, "geo/reverse_geocode.json", {"lat": $lat, "lon": $lon}.newStringTable)


proc geoSearch*(twitter:TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `geo/search.json` endpoint
  return get(twitter, "geo/search.json", additionalParams)


# --------
# insights
# --------


proc insightsEngagementTotals*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
  ## `insights/enagement/totals.json` endpoint
  return post(twitter, "insights/enagement/totals.json", jsonBody)


proc insightsEngagementHistorical*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
  ## `insights/enagement/historical.json` endpoint
  return post(twitter, "insights/enagement/historical.json", jsonBody)


proc insightsEngagement28h*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
  ## `insights/enagement/28h.json` endpoint
  return post(twitter, "insights/enagement/28h.json", jsonBody)
  

# -------
# utility
# -------
# General-use functions that might be useful without being too compicated

proc uploadFile*(twitter: TwitterAPI, filename: string,
                 mediaType: string, additionalParams: StringTableRef = nil): Response =
  ## Upload a file from a filename 
  ##
  ## mediaType takes these arguments: `amplify_video, tweet_gif, tweet_image, tweet_video`
  # This is a bit 'higher level' than the rest but IMO is routine enough and simple enough to make it useful
  var ubody = additionalParams
  ubody["media_type"] = mediaType
  let data = $ readFile(filename)
  return post(twitter, "media/upload.json", ubody, true, data)


template callAPI*(twitter: TwitterAPI, api: untyped,
                  additionalParams: StringTableRef = nil): untyped =
  ## Template to callAPI
  ##
  ## Example:
  ## ```nim 
  ## var testStatus = {"status": "test"}.newStringTable
  ## var resp = twitterAPI.callAPI(statusesUpdate, testStatus)```
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
