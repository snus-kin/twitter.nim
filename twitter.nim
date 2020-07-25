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
const publishUrl = "https://publish.twitter.com"
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
  elif httpMethod == "PUT":
    return httpclient.put(client, url & "?" & path)


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
          additionalParams: StringTableRef = nil, media: bool = false, publish: bool = false): Response =
  ## Raw get proc. `media` optional parameter changes request URL to
  ## `upload.twitter.com`
  if media:
    return request(twitter, endPoint, "GET", additionalParams, requestUrl=uploadUrl)
  elif publish:
    return request(twitter, endPoint, "GET", additionalParams, requestUrl=publishUrl)
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


proc put*(twitter: TwitterAPI, endPoint: string, 
             additionalParams: StringTableRef = nil): Response = 
  return request(twitter, endPoint, "PUT", additionalParams)


# --------------
# authentication
# --------------


proc oauthAuthenticate*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `oauth/authenticate` endpoint
  return get(twitter, "oauth/authenticate", additionalParams)


proc oauthAuthorize*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response = 
  ## `oauth/authorize` endpoint
  return get(twitter, "oauth/authorize", additionalParams)


proc oauthAccessToken*(twitter: TwitterAPI, oauthToken: string, oauthVerifier: string, additionalParams: StringTableRef = nil): Response =
  ## `oauth/access_token` endpoint
  if additionalParams != nil:
    additionalParams["oauth_token"] = oauthToken
    additionalParams["oauth_verifier"] = oauthVerifier
    return post(twitter, "oauth/access_token", additionalParams)
  else:
    return post(twitter, "oauth/access_token", {"oauth_token": oauthToken, "oauth_verifier": oauthVerifier}.newStringTable)


proc oauthInvalidateToken*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `oauth/invalidate_token` endpoint
  return post(twitter, "oauth/invalidate_token", additionalParams)


proc oauthRequestToken*(twitter: TwitterAPI, oauthCallback: string, additionalParams: StringTableRef = nil): Response =
  ## `oauth/request_token` endpoint
  if additionalParams != nil:
    additionalParams["oauth_callback"] = oauthCallback
    return post(twitter, "oauth/request_token", additionalParams)
  else:
    return post(twitter, "oauth/request_token", {"oauth_callback": oauthCallback}.newStringTable)


proc oauth2InvalidateToken*(twitter: TwitterAPI, accessToken: string, additionalParams: StringTableRef = nil): Response =
  ## `oauth2/invalidate_token` endpoint
  if additionalParams != nil:
    additionalParams["access_token"] = accessToken
    return post(twitter, "oauth2/invalidate_token", additionalParams)
  else:
    return post(twitter, "oauth2/invalidate_token", {"access_token": accessToken}.newStringTable)


proc oauth2Token*(twitter: TwitterAPI, grantType: string, additionalParams: StringTableRef = nil): Response =
  ## `oauth2/token` endpoint
  if additionalParams != nil:
    additionalParams["grant_type"] = grantType
    return post(twitter, "oauth2/token", additionalParams)
  else:
    return post(twitter, "oauth2/token", {"grant_type": grantType}.newStringTable)

# -----
# lists
# -----
proc listsList*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  ## `lists/list.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "lists/list.json", additionalParams)
  else:
    return get(twitter, "lists/list.json", {"screen_name": screenName}.newStringTable)


proc listsList*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  ## `lists/list.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "lists/list.json", additionalParams)
  else:
    return get(twitter, "lists/list.json", {"user_id": $userId}.newStringTable)


proc listsMembers*(twitter: TwitterAPI, slug: string,  additionalParams: StringTableRef = nil): Response =
  ## `lists/members.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return get(twitter, "lists/members.json", additionalParams)
  else:
    return get(twitter, "lists/members.json", {"slug": slug}.newStringTable)


proc listsMembers*(twitter: TwitterAPI, listId: int,  additionalParams: StringTableRef = nil): Response =
  ## `lists/members.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return get(twitter, "lists/members.json", additionalParams)
  else:
    return get(twitter, "lists/members.json", {"list_id": $listId}.newStringTable)


proc listsMembersShow*(twitter: TwitterAPI, slug: string,  additionalParams: StringTableRef = nil): Response =
  ## `lists/members/show.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return get(twitter, "lists/members/show.json", additionalParams)
  else:
    return get(twitter, "lists/members/show.json", {"slug": slug}.newStringTable)


proc listsMembersShow*(twitter: TwitterAPI, listId: int,  additionalParams: StringTableRef = nil): Response =
  ## `lists/members/show.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return get(twitter, "lists/members/show.json", additionalParams)
  else:
    return get(twitter, "lists/members/show.json", {"list_id": $listId}.newStringTable)


proc listsMemberships*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  ## `lists/memberships.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "lists/memberships.json", additionalParams)
  else:
    return get(twitter, "lists/memberships.json", {"screen_name": screenName}.newStringTable)


proc listsMemberships*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  ## `lists/memberships.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "lists/memberships.json", additionalParams)
  else:
    return get(twitter, "lists/memberships.json", {"user_id": $userId}.newStringTable)


proc listsOwnerships*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  ## `lists/ownerships.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "lists/ownerships.json", additionalParams)
  else:
    return get(twitter, "lists/ownerships.json", {"screen_name": screenName}.newStringTable)


proc listsOwnerships*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  ## `lists/ownerships.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "lists/ownerships.json", additionalParams)
  else:
    return get(twitter, "lists/ownerships.json", {"user_id": $userId}.newStringTable)


proc listsShow*(twitter: TwitterAPI, slug: string,  additionalParams: StringTableRef = nil): Response =
  ## `lists/show.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return get(twitter, "lists/show.json", additionalParams)
  else:
    return get(twitter, "lists/show.json", {"slug": slug}.newStringTable)


proc listsShow*(twitter: TwitterAPI, listId: int,  additionalParams: StringTableRef = nil): Response =
  ## `lists/show.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return get(twitter, "lists/show.json", additionalParams)
  else:
    return get(twitter, "lists/show.json", {"list_id": $listId}.newStringTable)


proc listsStatuses*(twitter: TwitterAPI, slug: string,  additionalParams: StringTableRef = nil): Response =
  ## `lists/statuses.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return get(twitter, "lists/statuses.json", additionalParams)
  else:
    return get(twitter, "lists/statuses.json", {"slug": slug}.newStringTable)


proc listsStatuses*(twitter: TwitterAPI, listId: int,  additionalParams: StringTableRef = nil): Response =
  ## `lists/statuses.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return get(twitter, "lists/statuses.json", additionalParams)
  else:
    return get(twitter, "lists/statuses.json", {"list_id": $listId}.newStringTable)


proc listsSubscribers*(twitter: TwitterAPI, slug: string,  additionalParams: StringTableRef = nil): Response =
  ## `lists/subscribers.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return get(twitter, "lists/subscribers.json", additionalParams)
  else:
    return get(twitter, "lists/subscribers.json", {"slug": slug}.newStringTable)


proc listsSubscribers*(twitter: TwitterAPI, listId: int,  additionalParams: StringTableRef = nil): Response =
  ## `lists/subscribers.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return get(twitter, "lists/subscribers.json", additionalParams)
  else:
    return get(twitter, "lists/subscribers.json", {"list_id": $listId}.newStringTable)


proc listsSubscribersShow*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `lists/subscribers/show.json` endpoint
  # NB: this could be, I think 4, overloading procs but I have decided not to for simplicity
  return get(twitter, "lists/subscribers/show.json", additionalParams)


proc listsSubscriptions*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  ## `lists/subscriptions.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "lists/subscriptions.json", additionalParams)
  else:
    return get(twitter, "lists/subscriptions.json", {"screen_name": screenName}.newStringTable)


proc listsSubscriptions*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  ## `lists/subscriptions.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "lists/subscriptions.json", additionalParams)
  else:
    return get(twitter, "lists/subscriptions.json", {"user_id": $userId}.newStringTable)


proc listsCreate*(twitter: TwitterAPI, slug: string, additionalParams: StringTableRef = nil): Response =
  ## `lists/create.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return post(twitter, "lists/create.json", additionalParams)
  else:
    return post(twitter, "lists/create.json", {"slug": slug}.newStringTable)


proc listsCreate*(twitter: TwitterAPI, listId: int, additionalParams: StringTableRef = nil): Response =
  ## `lists/create.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return post(twitter, "lists/create.json", additionalParams)
  else:
    return post(twitter, "lists/create.json", {"list_id": $listId}.newStringTable)


proc listsDestroy*(twitter: TwitterAPI, slug: string, additionalParams: StringTableRef = nil): Response =
  ## `lists/destroy.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return post(twitter, "lists/destroy.json", additionalParams)
  else:
    return post(twitter, "lists/destroy.json", {"slug": slug}.newStringTable)


proc listsDestroy*(twitter: TwitterAPI, listId: int, additionalParams: StringTableRef = nil): Response =
  ## `lists/destroy.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return post(twitter, "lists/destroy.json", additionalParams)
  else:
    return post(twitter, "lists/destroy.json", {"list_id": $listId}.newStringTable)


proc listsMembersCreate*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `lists/members/create.json` endpoint
  # NB: this could be, I think 4, overloading procs but I have decided not to for simplicity
  return post(twitter, "lists/members/create.json", additionalParams)


proc listsMembersCreateAll*(twitter: TwitterAPI, listId: int, additionalParams: StringTableRef = nil): Response =
  ## `lists/members/create_all.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return post(twitter, "lists/members/create_all.json", additionalParams)
  else:
    return post(twitter, "lists/members/create_all.json", {"list_id": $listId}.newStringTable)


proc listsMembersCreateAll*(twitter: TwitterAPI, slug: string, additionalParams: StringTableRef = nil): Response =
  ## `lists/members/create_all.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return post(twitter, "lists/members/create_all.json", additionalParams)
  else:
    return post(twitter, "lists/members/create_all.json", {"slug": slug}.newStringTable)


proc listsMembersDestroy*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `lists/members/destroy.json` endpoint
  # NB: this could be, I think 4, overloading procs but I have decided not to for simplicity
  return post(twitter, "lists/members/destroy.json", additionalParams)


proc listsMembersDestroyAll*(twitter: TwitterAPI, listId: int, additionalParams: StringTableRef = nil): Response =
  ## `lists/members/destroy_all.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return post(twitter, "lists/members/destroy_all.json", additionalParams)
  else:
    return post(twitter, "lists/members/destroy_all.json", {"list_id": $listId}.newStringTable)


proc listsMembersDestroyAll*(twitter: TwitterAPI, slug: string, additionalParams: StringTableRef = nil): Response =
  ## `lists/members/destroy_all.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return post(twitter, "lists/members/destroy_all.json", additionalParams)
  else:
    return post(twitter, "lists/members/destroy_all.json", {"slug": slug}.newStringTable)


proc listsSubscribersCreate*(twitter: TwitterAPI, slug: string, additionalParams: StringTableRef = nil): Response =
  ## `lists/subscribers/create.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return post(twitter, "lists/subscribers/create.json", additionalParams)
  else:
    return post(twitter, "lists/subscribers/create.json", {"slug": slug}.newStringTable)


proc listsSubscribersCreate*(twitter: TwitterAPI, listId: int, additionalParams: StringTableRef = nil): Response =
  ## `lists/subscribers/create.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return post(twitter, "lists/subscribers/create.json", additionalParams)
  else:
    return post(twitter, "lists/subscribers/create.json", {"list_id": $listId}.newStringTable)


proc listsSubscribersDestroy*(twitter: TwitterAPI, slug: string, additionalParams: StringTableRef = nil): Response =
  ## `lists/subscribers/destroy.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return post(twitter, "lists/subscribers/destroy.json", additionalParams)
  else:
    return post(twitter, "lists/subscribers/destroy.json", {"slug": slug}.newStringTable)


proc listsSubscribersDestroy*(twitter: TwitterAPI, listId: int, additionalParams: StringTableRef = nil): Response =
  ## `lists/subscribers/destroy.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return post(twitter, "lists/subscribers/destroy.json", additionalParams)
  else:
    return post(twitter, "lists/subscribers/destroy.json", {"list_id": $listId}.newStringTable)


proc listsUpdate*(twitter: TwitterAPI, slug: string, additionalParams: StringTableRef = nil): Response =
  ## `lists/update.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return post(twitter, "lists/update.json", additionalParams)
  else:
    return post(twitter, "lists/update.json", {"slug": slug}.newStringTable)


proc listsUpdate*(twitter: TwitterAPI, listId: int, additionalParams: StringTableRef = nil): Response =
  ## `lists/update.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return post(twitter, "lists/update.json", additionalParams)
  else:
    return post(twitter, "lists/update.json", {"list_id": $listId}.newStringTable)


# ---------------------------------
# followers / friends / friendships
# ---------------------------------

proc followersIds*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  ## `followers/ids.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "followers/ids.json", additionalParams)
  else:
    return get(twitter, "followers/ids.json", {"screen_name": screenName}.newStringTable)


proc followersIds*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  ## `followers/id.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "followers/ids.json", additionalParams)
  else:
    return get(twitter, "followers/ids.json", {"user_id": $userId}.newStringTable)


proc followersList*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  ## `followers/list.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "followers/list.json", additionalParams)
  else:
    return get(twitter, "followers/list.json", {"screen_name": screenName}.newStringTable)


proc followersList*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  ## `followers/list.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "followers/list.json", additionalParams)
  else:
    return get(twitter, "followers/list.json", {"user_id": $userId}.newStringTable)


proc friendsIds*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  ## `friends/ids.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "friends/ids.json", additionalParams)
  else:
    return get(twitter, "friends/ids.json", {"screen_name": screenName}.newStringTable)


proc friendsIds*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  ## `friends/id.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "friends/ids.json", additionalParams)
  else:
    return get(twitter, "friends/ids.json", {"user_id": $userId}.newStringTable)


proc friendsList*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  ## `friends/list.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "friends/list.json", additionalParams)
  else:
    return get(twitter, "friends/list.json", {"screen_name": screenName}.newStringTable)


proc friendsList*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  ## `friends/list.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "friends/list.json", additionalParams)
  else:
    return get(twitter, "friends/list.json", {"user_id": $userId}.newStringTable)


proc friendshipsIncoming*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `friendships/incoming.json` endpoint
  return get(twitter, "friendships/incoming.json", additionalParams)


proc friendshipsLookup*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `friendships/lookup.json` endpoint
  return get(twitter, "friendships/lookup.json", additionalParams)


proc friendshipsNoRetweetsIds*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `friendships/no_retweets/ids.json`
  return get(twitter, "friendships/no_retweets/ids.json", additionalParams)


proc friendshipsOutgoing*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `friendships/outgoing.json` endpoint
  return get(twitter, "friendships/outgoing.json", additionalParams)


proc friendshipsShow*(twitter: TwitterAPI, sourceId: int, targetId: int, additionalParams: StringTableRef = nil): Response =
  ## `friendships/show.json` endpoint
  if additionalParams != nil:
    additionalParams["source_id"] = $sourceId
    additionalParams["target_id"] = $targetId
    return get(twitter, "friendships/show.json", additionalParams)
  else:
    return get(twitter, "friendships/show.json", {"source_id": $sourceId, "target_id": $targetId}.newStringTable)


proc friendshipsShow*(twitter: TwitterAPI, sourceScreenName: string, targetScreenName: string, additionalParams: StringTableRef = nil): Response =
  ## `friendships/show.json` endpoint
  if additionalParams != nil:
    additionalParams["source_screen_name"] = sourceScreenName
    additionalParams["target_screen_name"] = targetScreenName
    return get(twitter, "friendships/show.json", additionalParams)
  else:
    return get(twitter, "friendships/show.json", {"source_screen_name": sourceScreenName, "target_screen_name": targetScreenName}.newStringTable)


proc friendshipsCreate*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  ## `friendships/create.json` endpoint
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return post(twitter, "friendships/create.json", additionalParams)
  else:
    return post(twitter, "friendships/create.json", {"screen_name": screenName}.newStringTable)


proc friendshipsCreate*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  ## `friendships/create.json` endpoint
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "friendships/create.json", additionalParams)
  else:
    return post(twitter, "friendships/create.json", {"user_id": $userId}.newStringTable)


proc friendshipsDestroy*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  ## `friendships/destroy.json` endpoint
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return post(twitter, "friendships/destroy.json", additionalParams)
  else:
    return post(twitter, "friendships/destroy.json", {"screen_name": screenName}.newStringTable)


proc friendshipsDestroy*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  ## `friendships/destroy.json` endpoint
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "friendships/destroy.json", additionalParams)
  else:
    return post(twitter, "friendships/destroy.json", {"user_id": $userId}.newStringTable)


proc friendshipsUpdate*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  ## `friendships/update.json` endpoint
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return post(twitter, "friendships/update.json", additionalParams)
  else:
    return post(twitter, "friendships/update.json", {"screen_name": screenName}.newStringTable)


proc friendshipsUpdate*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  ## `friendships/update.json` endpoint
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "friendships/update.json", additionalParams)
  else:
    return post(twitter, "friendships/update.json", {"user_id": $userId}.newStringTable)


# -----
# users
# -----


proc usersLookup*(twitter:TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  ## `users/lookup.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "users/lookup.json", additionalParams)
  else:
    return post(twitter, "users/lookup.json", {"user_id": $userId}.newStringTable)


proc usersLookup*(twitter:TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  ## `users/lookup.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return post(twitter, "users/lookup.json", additionalParams)
  else:
    return post(twitter, "users/lookup.json", {"screen_name": screenName}.newStringTable)


proc usersSearch*(twitter:TwitterAPI, q: string, additionalParams: StringTableRef = nil): Response =
  ## `users/search.json` endpoint
  if additionalParams != nil:
    additionalParams["q"] = q
    return get(twitter, "users/search.json", additionalParams)
  else:
    return get(twitter, "users/search.json", {"q": q}.newStringTable)


proc usersProfileBanner*(twitter:TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  ## `users/profile_banner.json` endpoint
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "users/profile_banner.json", additionalParams)
  else:
    return get(twitter, "users/profile_banner.json", {"screen_name": screenName}.newStringTable)


proc usersProfileBanner*(twitter:TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  ## `users/profile_banner.json` endpoint
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "users/profile_banner.json", additionalParams)
  else:
    return get(twitter, "users/profile_banner.json", {"user_id": $userId}.newStringTable)


proc usersShow*(twitter: TwitterAPI, screenName: string,
           additionalParams: StringTableRef = nil): Response =
  ## `users/show.json` endpoint for screen names (@username)
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "users/show.json", additionalParams)
  else:
    return get(twitter, "users/show.json", {"screen_name": screenName}.newStringTable)


proc usersShow*(twitter: TwitterAPI, userId: int,
           additionalParams: StringTableRef = nil): Response =
  ## `users/show.json` endpoint for user id (e.g. `783214 => @twitter`)
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "users/show.json", additionalParams)
  else:
    return get(twitter, "users/show.json", {"user_id": $userId}.newStringTable)


proc usersReportSpam*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  ## `users/report_spam.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["user_id"] = $screenName
    return get(twitter, "users/report_spam.json", additionalParams)
  else:
    return get(twitter, "users/report_spam.json", {"screen_name": $screenName}.newStringTable)


proc usersReportSpam*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  ## `users/report_spam.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "users/report_spam.json", additionalParams)
  else:
    return get(twitter, "users/report_spam.json", {"user_id": $userId}.newStringTable)


# -------
# account
# -------


proc accountSettings*(twitter:TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `account/settings.json` endpoint
  return get(twitter, "account/settings.json", additionalParams)


proc accountVerifyCredentials*(twitter: TwitterAPI,
           additionalParams: StringTableRef = nil): Response =
  ## `account/verify_credentials.json` endpoint
  return get(twitter, "account/verify_credentials.json", additionalParams)


proc accountRemoveProfileBanner*(twitter:TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `account/remove_profile_banner.json` endpoint
  return post(twitter, "account/remove_profile_banner.json", additionalParams)


proc accountUpdateSettings*(twitter:TwitterAPI, additionalParams: StringTableRef): Response =
  ## `account/update_settings.json` endpoint
  return post(twitter, "account/update_settings.json", additionalParams)


proc accountUpdateProfile*(twitter:TwitterAPI, additionalParams: StringTableRef): Response =
  ## `account/update_profile.json` endpoint
  return post(twitter, "account/update_profile.json", additionalParams)


proc accountUpdateProfileBanner*(twitter: TwitterAPI, banner: string, additionalParams: StringTableRef = nil): Response =
  ## `account/update_profile_banner.json` endpoint
  if additionalParams != nil:
    additionalParams["banner"] = banner
    return post(twitter, "account/update_profile_banner.json", additionalParams)
  else:
    return post(twitter, "account/update_profile_banner.json", {"banner": banner}.newStringTable)


proc accountUpdateProfileImage*(twitter: TwitterAPI, image: string, additionalParams: StringTableRef = nil): Response =
  ## `account/update_profile_image.json` endpoint
  if additionalParams != nil:
    additionalParams["image"] = image
    return post(twitter, "account/update_profile_image.json", additionalParams)
  else:
    return post(twitter, "account/update_profile_image.json", {"image": image}.newStringTable)


# --------------
# saved_searches
# --------------


proc savedSeachesList*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `saved_searches/list.json` endpoint
  return get(twitter, "saved_searches/list.json", additionalParams)


proc savedSearchesShow*(twitter: TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response =
  ## `saved_searches/show/:id.json` endpoint
  return get(twitter, "saved_searches/show/" & $id & ".json", additionalParams)


proc savedSearchesCreate*(twitter: TwitterAPI, query: string, additionalParams: StringTableRef = nil): Response =
  ## `saved_searches/create.json` endpoint
  if additionalParams != nil:
    additionalParams["query"] = query
    return post(twitter, "saved_searches/create.json", additionalParams)
  else:
    return post(twitter, "saved_searches/create.json", {"query": query}.newStringTable)


proc savedSeachesDestroy*(twitter: TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response =
  ## `saved_searches/destroy/:id.json` endpoint
  return post(twitter, "saved_searches/destroy/" & $id & ".json", additionalParams)


# --------------
# blocks / mutes
# --------------


proc blocksIds*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `blocks/ids.json` endpoint
  return get(twitter, "blocks/ids.json", additionalParams)


proc blocksList*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `blocks/list.json` endpoint
  return get(twitter, "blocks/list.json", additionalParams)


proc mutesUsersIds*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `mutes/users/ids.json` endpoint
  return get(twitter, "mutes/users/ids.json", additionalParams)


proc mutesUsersList*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `mutes/users/list.json` endpoint
  return get(twitter, "mutes/users/list.json", additionalParams)


proc blocksCreate*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  # `blocks/create.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["user_id"] = $screenName
    return post(twitter, "blocks/create.json", additionalParams)
  else:
    return post(twitter, "blocks/create.json", {"screen_name": $screenName}.newStringTable)


proc blocksCreate*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  # `blocks/create.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "blocks/create.json", additionalParams)
  else:
    return post(twitter, "blocks/create.json", {"user_id": $userId}.newStringTable)


proc blocksDestroy*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  # `blocks/destroy.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["user_id"] = $screenName
    return post(twitter, "blocks/destroy.json", additionalParams)
  else:
    return post(twitter, "blocks/destroy.json", {"screen_name": $screenName}.newStringTable)


proc blocksDestroy*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  # `blocks/destroy.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "blocks/destroy.json", additionalParams)
  else:
    return post(twitter, "blocks/destroy.json", {"user_id": $userId}.newStringTable)


proc mutesUsersCreate*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  # `mutes/users/create.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["user_id"] = $screenName
    return post(twitter, "mutes/users/create.json", additionalParams)
  else:
    return post(twitter, "mutes/users/create.json", {"screen_name": $screenName}.newStringTable)


proc mutesUsersCreate*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  # `mutes/users/create.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "mutes/users/create.json", additionalParams)
  else:
    return post(twitter, "mutes/users/create.json", {"user_id": $userId}.newStringTable)


proc mutesUsersDestroy*(twitter: TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  # `mutes/users/destroy.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["user_id"] = $screenName
    return post(twitter, "mutes/users/destroy.json", additionalParams)
  else:
    return post(twitter, "mutes/users/destroy.json", {"screen_name": $screenName}.newStringTable)


proc mutesUsersDestroy*(twitter: TwitterAPI, userId: int, additionalParams: StringTableRef = nil): Response =
  # `mutes/users/destroy.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "mutes/users/destroy.json", additionalParams)
  else:
    return post(twitter, "mutes/users/destroy.json", {"user_id": $userId}.newStringTable)


# -----------
# collections
# -----------


proc collectionsEntries*(twitter:TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
  ## `collections/entries.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = id
    return get(twitter, "collections/entries.json", additionalParams)
  else:
    return get(twitter, "collections/entries.json", {"id": id}.newStringTable)


proc collectionsList*(twitter:TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response =
  ## `collections/list.json` endpoint for twitter user id
  if additionalParams != nil:
    additionalParams["id"] = $id
    return get(twitter, "collections/list.json", additionalParams)
  else:
    return get(twitter, "collections/list.json", {"id": $id}.newStringTable)


proc collectionsList*(twitter:TwitterAPI, screenName: string, additionalParams: StringTableRef = nil): Response =
  ## `collections/list.json` for twitter user screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "collections/list.json", additionalParams)
  else:
    return get(twitter, "collections/list.json", {"screen_name": screenName}.newStringTable)


proc collectionsShow*(twitter:TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
  ## `collections/show.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = id
    return get(twitter, "collections/show.json", additionalParams)
  else:
    return get(twitter, "collections/show.json", {"id": id}.newStringTable)


proc collectionsCreate*(twitter:TwitterAPI, name: string, additionalParams: StringTableRef = nil): Response =
  ## `collections/create.json` endpoint
  if additionalParams != nil:
    additionalParams["name"] = name
    return post(twitter, "collections/create.json", additionalParams)
  else:
    return post(twitter, "collections/create.json", {"name": name}.newStringTable)


proc collectionsDestroy*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
  if additionalParams != nil:
    additionalParams["id"] = id
    return post(twitter, "collections/destroy.json", additionalParams)
  else:
    return post(twitter, "collections/destroy.json", {"id": id}.newStringTable)


proc collectionsEntriesAdd*(twitter: TwitterAPI, id: string, tweet_id: int, additionalParams: StringTableRef = nil): Response =
  ## `collections/entries/add.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = id
    additionalParams["tweet_id"] = $tweet_id
    return post(twitter, "collections/entries/add.json", additionalParams)
  else:
    return post(twitter, "collections/entries/add.json", {"id": id, "tweet_id": $tweet_id}.newStringTable)


proc collectionsEntriesCurate*(twitter: TwitterAPI, jsonBody: JsonNode): Response = 
  ## `collections/entries/curate.json` endpoint
  # This is honestly one of the worst parts of the API docs. I can't work out what it does. 
  return post(twitter, "collections/entries/curate.json", jsonBody)


proc collectionsEntriesMove*(twitter: TwitterAPI, id: string, tweet_id: int, relative_to: int, additionalParams: StringTableRef = nil): Response =
  ## `collections/entries/move.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = id
    additionalParams["tweet_id"] = $tweet_id
    additionalParams["relative_to"] = $relative_to
    return post(twitter, "collections/entries/move.json", additionalParams)
  else:
    return post(twitter, "collections/entries/move.json", {"id": id, "tweet_id": $tweet_id, "relative_to": $relative_to}.newStringTable)


proc collectionsEntriesRemove*(twitter: TwitterAPI, id: string, tweet_id: int, additionalParams: StringTableRef = nil): Response =
  ## `collections/entries/remove.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = id
    additionalParams["tweet_id"] = $tweet_id
    return post(twitter, "collections/entries/remove.json", additionalParams)
  else:
    return post(twitter, "collections/entries/remove.json", {"id": id, "tweet_id": $tweet_id}.newStringTable)


proc collectionsUpdate*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
  ## `collections/update.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = id
    return post(twitter, "collections/update.json", additionalParams)
  else:
    return post(twitter, "collections/update.json", {"id": id}.newStringTable)


# --------
# statuses
# --------


proc statusesFilter*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `statuses/filter.json` endpoint
  return post(twitter, "statuses/filter.json", additionalParams)


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


proc statusesLookup*(twitter: TwitterAPI, ids: string, additionalParams: StringTableRef = nil): Response =
  ## `statuses/lookup.json` endpoint
  ##
  ## ids is a string of comma seperated tweet ids
  if additionalParams != nil:
    additionalParams["id"] = ids
    return get(twitter, "statuses/lookup.json", additionalParams)
  else:
    return get(twitter, "statuses/lookup.json", {"id": ids}.newStringTable)


proc statusesOembed*(twitter: TwitterAPI, url: string, additionalParams: StringTableRef = nil): Response =
  ## `oembed` endpoint
  ##
  ##  Used for generating embeds from tweets, uses publish.twitter.com as a url
  if additionalParams != nil:
    additionalParams["url"] = url
    return get(twitter, "statuses/retweeters/ids.json", additionalParams, publish=true)
  else:
    return get(twitter, "statuses/retweeters/ids.json", {"url": url}.newStringTable, publish=true)


proc statusesRetweetersIds*(twitter: TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response =
  ## `statuses/retweeters/ids.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return get(twitter, "statuses/retweeters/ids.json", additionalParams)
  else:
    return get(twitter, "statuses/retweeters/ids.json", {"id": $id}.newStringTable)


proc statusesRetweets*(twitter: TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response =
  ## `statuses/retweets/:id.json` endpoint
  return get(twitter, "statuses/retweets/" & $id & ".json", additionalParams)


proc statusesRetweetsOfMe*(twitter: TwitterAPI,
                   additionalParams: StringTableRef = nil): Response =
  ## `statuses/retweets_of_me.json` endpoint
  return get(twitter, "statuses/retweets_of_me.json", additionalParams)


proc statusesShow*(twitter: TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response = 
  ## `statuses/show.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return get(twitter, "statuses/show.json", additionalParams)
  else:
    return get(twitter, "statuses/show.json", {"id": $id}.newStringTable)


proc statusesDestroy*(twitter: TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response = 
  ## `statuses/destroy/:id.json` endpoint
  return post(twitter, "statuses/destroy/" & $id & ".json", additionalParams)


proc statusesRetweet*(twitter: TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response = 
  ## `statuses/retweet/:id` endpoint
  return post(twitter, "statuses/retweet/" & $id & ".json", additionalParams)


proc statusesUnretweet*(twitter: TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response = 
  ## `statuses/unretweet/:id.json` endpoint
  return post(twitter, "statuses/unretweet/" & $id & ".json", additionalParams)


proc statusesUpdate*(twitter: TwitterAPI, status: string, 
                    additionalParams: StringTableRef = nil): Response =
  ## `statuses/update.json` endpoint
  if additionalParams != nil: 
    additionalParams["status"] = status
    return post(twitter, "statuses/update.json", additionalParams)
  else:
    return post(twitter, "statuses/update.json", {"status": status}.newStringTable)


proc statusesSample*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `statuses/sample.json` endpoint
  return get(twitter, "statuses/sample.json", additionalParams)


# ---------
# favorites
# ---------


proc favoritesList*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response = 
  ## `favorites/list.json` endpoint
  return get(twitter, "favorites/list.json", additionalParams)


proc favoritesCreate*(twitter: TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response =
  ## `favorites/create.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return post(twitter, "favorites/create.json", additionalParams)
  else:
    return post(twitter, "favorites/create.json", {"id": $id}.newStringTable)


proc favoritesDestroy*(twitter: TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response =
  ## `favorites/destroy.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return post(twitter, "favorites/destroy.json", additionalParams)
  else:
    return post(twitter, "favorites/destroy.json", {"id": $id}.newStringTable)


# ------
# search
# ------


proc searchTweets*(twitter:TwitterAPI, q: string, additionalParams: StringTableRef = nil): Response = 
  ## `search/tweets.json` endpoint
  ##
  ## Standard tier search endpoint
  if additionalParams != nil:
    additionalParams["q"] = q
    return get(twitter, "search/tweets.json", additionalParams)
  else:
    return get(twitter, "search/tweets.json", {"q": q}.newStringTable)


# ---------------
# custom_profiles
# ---------------


proc customProfilesDestroy*(twitter:TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response =
  ## `custom_profiles/destroy.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return delete(twitter, "custom_profiles/destroy.json", additionalParams)
  else:
    return delete(twitter, "custom_profiles/destroy.json", {"id": $id}.newStringTable)


proc customProfilesId*(twitter:TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response = 
  ## `custom_profiles/:id.json` endpoint
  return get(twitter, "custom_profiles/" & $id & ".json", additionalParams)


proc customProfilesLists*(twitter:TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `custom_profiles/list.json` endpoint
  return get(twitter, "custom_profiles/list.json", additionalParams)


proc customProfilesNew*(twitter:TwitterAPI, jsonBody: JsonNode): Response =
  ## `custom_profiles/new.json` endpoint
  return post(twitter, "custom_profiles/new.json", jsonBody)


# ---------------
# direct_messages
# ---------------


proc directMessagesEventsDestroy*(twitter: TwitterAPI, id: int,
                                           additionalParams: StringTableRef = nil): Response = 
  ## `direct_messages/events/destroy.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return delete(twitter, "direct_messages/events/destroy.json", additionalParams)
  else:
    return delete(twitter, "direct_messages/events/destroy.json", {"id": $id}.newStringTable)


proc directMessagsEventsList*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/events/list.json` endpoint
  return get(twitter, "direct_messages/events/list.json", additionalParams)


proc directMessagesEventsShow*(twitter: TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response = 
  ## `direct_messages/events/show.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return get(twitter, "direct_messages/events/show.json", additionalParams)
  else:
    return get(twitter, "direct_messages/events/show.json", {"id": $id}.newStringTable)


proc directMessagesEventsNew*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
  ## `direct_messages/events/new.json` endpoint (message_create)
  return post(twitter, "direct_messages/events/new.json", jsonBody)


proc directMessagesIndicateTyping*(twitter: TwitterAPI, jsonBody: JsonNode): Response = 
  ## `direct_messages/indicate_typing.json` endpoint
  return post(twitter, "direct_messages/indicate_typing.json", jsonBody)


proc directMessagesMarkRead*(twitter: TwitterAPI, lastReadEventId: int, recipientId: int, additionalParams: StringTableRef = nil): Response = 
  ## `direct_messages/mark_read.json` endpoint
  if additionalParams != nil:
    additionalParams["last_read_event_id"] = $lastReadEventId
    additionalParams["recipient_id"] = $recipientId
    return post(twitter, "direct_messages/mark_read.json", additionalParams)
  else:
    return post(twitter, "direct_messages/mark_read.json", {"last_read_event_id": $lastReadEventId, "recipient_id": $recipientId}.newStringTable)


proc directMessagesWelcomeMessagesDestroy*(twitter: TwitterAPI, id: int,
                                           additionalParams: StringTableRef = nil): Response = 
  ## `direct_messages/welcome_messages/destroy.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return delete(twitter, "direct_messages/welcome_messages/destroy.json", additionalParams)
  else:
    return delete(twitter, "direct_messages/welcome_messages/destroy.json", {"id": $id}.newStringTable)


proc directMessagesWelcomeMessagesRulesDestroy*(twitter: TwitterAPI, id: int,
                                           additionalParams: StringTableRef = nil): Response = 
  ## `direct_messages/welcome_messages/rules/destroy.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return delete(twitter, "direct_messages/rules/welcome_messages/destroy.json", additionalParams)
  else:
    return delete(twitter, "direct_messages/rules/welcome_messages/destroy.json", {"id": $id}.newStringTable)


proc directMessagesWelcomeMessagesUpdate*(twitter: TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/welcome_messages/update.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return put(twitter, "direct_messages/welcome_messages/update.json", additionalParams)
  else:
    return put(twitter, "direct_messages/welcome_messages/update.json", {"id": $id}.newStringTable)


proc directMessagesWelcomeMessagesList*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/welcome_messages/list.json` endpoint
  return get(twitter, "direct_messages/welcome_messages/list.json", additionalParams)


proc directMessagesWelcomeMessagesRulesList*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/welcome_messages/rules/list.json` endpoint
  return get(twitter, "direct_messages/welcome_messages/rules/list.json", additionalParams)


proc directMessagesWelcomeMessagesRulesShow*(twitter: TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/welcome_messages/rules/show.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $ id
    return get(twitter, "direct_messages/welcome_messages/rules/show.json", additionalParams)
  else:
    return get(twitter, "direct_messages/welcome_messages/rules/show.json", {"id": $id}.newStringTable)


proc directMessagesWelcomeMessagesShow*(twitter: TwitterAPI, id: int, additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/welcome_messages/show.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $ id
    return get(twitter, "direct_messages/welcome_messages/show.json", additionalParams)
  else:
    return get(twitter, "direct_messages/welcome_messages/show.json", {"id": $id}.newStringTable)


proc directMessagesWelcomeMessagesNew*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
  ## `direct_messages/welcome_messages/new.json` endpoint
  return post(twitter, "direct_messages/welcome_messages/new.json", jsonBody)


proc directMessagesWelcomeMessagesRulesNew*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
  ## `direct_messages/welcome_messages/rules/new.json` endpoint
  return post(twitter, "direct_messages/welcome_messages/rules/new.json", jsonBody)


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
