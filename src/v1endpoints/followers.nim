import strtabs, httpclient
import ../utility/[requests, types]
# ---------------------------------
# followers / friends / friendships
# ---------------------------------

proc followersIds*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `followers/ids.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "1.1/followers/ids.json", additionalParams)
  else:
    return get(twitter, "1.1/followers/ids.json", {
        "screen_name": screenName}.newStringTable)


proc followersIds*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `followers/id.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "1.1/followers/ids.json", additionalParams)
  else:
    return get(twitter, "1.1/followers/ids.json", {
        "user_id": $userId}.newStringTable)


proc followersList*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `followers/list.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "1.1/followers/list.json", additionalParams)
  else:
    return get(twitter, "1.1/followers/list.json", {
        "screen_name": screenName}.newStringTable)


proc followersList*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `followers/list.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "1.1/followers/list.json", additionalParams)
  else:
    return get(twitter, "1.1/followers/list.json", {
        "user_id": $userId}.newStringTable)


proc friendsIds*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `friends/ids.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "1.1/friends/ids.json", additionalParams)
  else:
    return get(twitter, "1.1/friends/ids.json", {
        "screen_name": screenName}.newStringTable)


proc friendsIds*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `friends/id.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "1.1/friends/ids.json", additionalParams)
  else:
    return get(twitter, "1.1/friends/ids.json", {"user_id": $userId}.newStringTable)


proc friendsList*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `friends/list.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "1.1/friends/list.json", additionalParams)
  else:
    return get(twitter, "1.1/friends/list.json", {
        "screen_name": screenName}.newStringTable)


proc friendsList*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `friends/list.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "1.1/friends/list.json", additionalParams)
  else:
    return get(twitter, "1.1/friends/list.json", {
        "user_id": $userId}.newStringTable)


proc friendshipsIncoming*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `friendships/incoming.json` endpoint
  return get(twitter, "1.1/friendships/incoming.json", additionalParams)


proc friendshipsLookup*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `friendships/lookup.json` endpoint
  return get(twitter, "1.1/friendships/lookup.json", additionalParams)


proc friendshipsNoRetweetsIds*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `friendships/no_retweets/ids.json`
  return get(twitter, "1.1/friendships/no_retweets/ids.json", additionalParams)


proc friendshipsOutgoing*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `friendships/outgoing.json` endpoint
  return get(twitter, "1.1/friendships/outgoing.json", additionalParams)


proc friendshipsShow*(twitter: TwitterAPI, sourceId: int, targetId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `friendships/show.json` endpoint
  if additionalParams != nil:
    additionalParams["source_id"] = $sourceId
    additionalParams["target_id"] = $targetId
    return get(twitter, "1.1/friendships/show.json", additionalParams)
  else:
    return get(twitter, "1.1/friendships/show.json", {"source_id": $sourceId,
        "target_id": $targetId}.newStringTable)


proc friendshipsShow*(twitter: TwitterAPI, sourceScreenName: string,
    targetScreenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `friendships/show.json` endpoint
  if additionalParams != nil:
    additionalParams["source_screen_name"] = sourceScreenName
    additionalParams["target_screen_name"] = targetScreenName
    return get(twitter, "1.1/friendships/show.json", additionalParams)
  else:
    return get(twitter, "1.1/friendships/show.json", {
        "source_screen_name": sourceScreenName,
        "target_screen_name": targetScreenName}.newStringTable)


proc friendshipsCreate*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `friendships/create.json` endpoint
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return post(twitter, "1.1/friendships/create.json", additionalParams)
  else:
    return post(twitter, "1.1/friendships/create.json", {
        "screen_name": screenName}.newStringTable)


proc friendshipsCreate*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `friendships/create.json` endpoint
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "1.1/friendships/create.json", additionalParams)
  else:
    return post(twitter, "1.1/friendships/create.json", {
        "user_id": $userId}.newStringTable)


proc friendshipsDestroy*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `friendships/destroy.json` endpoint
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return post(twitter, "1.1/friendships/destroy.json", additionalParams)
  else:
    return post(twitter, "1.1/friendships/destroy.json", {
        "screen_name": screenName}.newStringTable)


proc friendshipsDestroy*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `friendships/destroy.json` endpoint
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "1.1/friendships/destroy.json", additionalParams)
  else:
    return post(twitter, "1.1/friendships/destroy.json", {
        "user_id": $userId}.newStringTable)


proc friendshipsUpdate*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `friendships/update.json` endpoint
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return post(twitter, "1.1/friendships/update.json", additionalParams)
  else:
    return post(twitter, "1.1/friendships/update.json", {
        "screen_name": screenName}.newStringTable)


proc friendshipsUpdate*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `friendships/update.json` endpoint
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "1.1/friendships/update.json", additionalParams)
  else:
    return post(twitter, "1.1/friendships/update.json", {
        "user_id": $userId}.newStringTable)
