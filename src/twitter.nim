import httpclient, strtabs, json

import utility/[types, requests]
include endpoints/[lists, followers, auth, collections, users, statuses, directmessages, media]

export types, requests

# -------------------
# developer utilities
# -------------------


proc applicationRateLimitData*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `application/rate_limit_status.json` endpoint
  return get(twitter, "application/rate_limit_status.json", additionalParams)


proc helpConfiguration*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `help/configuration.json` endpoint
  return get(twitter, "help/configuration.json", additionalParams)


proc helpLanguages*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `help/languages.json` endpoint
  return get(twitter, "help/languages.json", additionalParams)


# -------
# account
# -------


proc accountSettings*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `account/settings.json` endpoint
  return get(twitter, "account/settings.json", additionalParams)


proc accountVerifyCredentials*(twitter: TwitterAPI,
           additionalParams: StringTableRef = nil): Response =
  ## `account/verify_credentials.json` endpoint
  return get(twitter, "account/verify_credentials.json", additionalParams)


proc accountRemoveProfileBanner*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `account/remove_profile_banner.json` endpoint
  return post(twitter, "account/remove_profile_banner.json", additionalParams)


proc accountUpdateSettings*(twitter: TwitterAPI,
    additionalParams: StringTableRef): Response =
  ## `account/update_settings.json` endpoint
  return post(twitter, "account/update_settings.json", additionalParams)


proc accountUpdateProfile*(twitter: TwitterAPI,
    additionalParams: StringTableRef): Response =
  ## `account/update_profile.json` endpoint
  return post(twitter, "account/update_profile.json", additionalParams)


proc accountUpdateProfileBanner*(twitter: TwitterAPI, banner: string,
    additionalParams: StringTableRef = nil): Response =
  ## `account/update_profile_banner.json` endpoint
  if additionalParams != nil:
    additionalParams["banner"] = banner
    return post(twitter, "account/update_profile_banner.json", additionalParams)
  else:
    return post(twitter, "account/update_profile_banner.json", {
        "banner": banner}.newStringTable)


proc accountUpdateProfileImage*(twitter: TwitterAPI, image: string,
    additionalParams: StringTableRef = nil): Response =
  ## `account/update_profile_image.json` endpoint
  if additionalParams != nil:
    additionalParams["image"] = image
    return post(twitter, "account/update_profile_image.json", additionalParams)
  else:
    return post(twitter, "account/update_profile_image.json", {
        "image": image}.newStringTable)


# --------------
# saved_searches
# --------------


proc savedSeachesList*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `saved_searches/list.json` endpoint
  return get(twitter, "saved_searches/list.json", additionalParams)


proc savedSearchesShow*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `saved_searches/show/:id.json` endpoint
  return get(twitter, "saved_searches/show/" & $id & ".json", additionalParams)


proc savedSearchesCreate*(twitter: TwitterAPI, query: string,
    additionalParams: StringTableRef = nil): Response =
  ## `saved_searches/create.json` endpoint
  if additionalParams != nil:
    additionalParams["query"] = query
    return post(twitter, "saved_searches/create.json", additionalParams)
  else:
    return post(twitter, "saved_searches/create.json", {
        "query": query}.newStringTable)


proc savedSeachesDestroy*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
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


proc mutesUsersIds*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `mutes/users/ids.json` endpoint
  return get(twitter, "mutes/users/ids.json", additionalParams)


proc mutesUsersList*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `mutes/users/list.json` endpoint
  return get(twitter, "mutes/users/list.json", additionalParams)


proc blocksCreate*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  # `blocks/create.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["user_id"] = $screenName
    return post(twitter, "blocks/create.json", additionalParams)
  else:
    return post(twitter, "blocks/create.json", {
        "screen_name": $screenName}.newStringTable)


proc blocksCreate*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  # `blocks/create.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "blocks/create.json", additionalParams)
  else:
    return post(twitter, "blocks/create.json", {
        "user_id": $userId}.newStringTable)


proc blocksDestroy*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  # `blocks/destroy.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["user_id"] = $screenName
    return post(twitter, "blocks/destroy.json", additionalParams)
  else:
    return post(twitter, "blocks/destroy.json", {
        "screen_name": $screenName}.newStringTable)


proc blocksDestroy*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  # `blocks/destroy.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "blocks/destroy.json", additionalParams)
  else:
    return post(twitter, "blocks/destroy.json", {
        "user_id": $userId}.newStringTable)


proc mutesUsersCreate*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  # `mutes/users/create.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["user_id"] = $screenName
    return post(twitter, "mutes/users/create.json", additionalParams)
  else:
    return post(twitter, "mutes/users/create.json", {
        "screen_name": $screenName}.newStringTable)


proc mutesUsersCreate*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  # `mutes/users/create.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "mutes/users/create.json", additionalParams)
  else:
    return post(twitter, "mutes/users/create.json", {
        "user_id": $userId}.newStringTable)


proc mutesUsersDestroy*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  # `mutes/users/destroy.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["user_id"] = $screenName
    return post(twitter, "mutes/users/destroy.json", additionalParams)
  else:
    return post(twitter, "mutes/users/destroy.json", {
        "screen_name": $screenName}.newStringTable)


proc mutesUsersDestroy*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  # `mutes/users/destroy.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "mutes/users/destroy.json", additionalParams)
  else:
    return post(twitter, "mutes/users/destroy.json", {
        "user_id": $userId}.newStringTable)


# ---------
# favorites
# ---------


proc favoritesList*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `favorites/list.json` endpoint
  return get(twitter, "favorites/list.json", additionalParams)


proc favoritesCreate*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `favorites/create.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return post(twitter, "favorites/create.json", additionalParams)
  else:
    return post(twitter, "favorites/create.json", {"id": $id}.newStringTable)


proc favoritesDestroy*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `favorites/destroy.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return post(twitter, "favorites/destroy.json", additionalParams)
  else:
    return post(twitter, "favorites/destroy.json", {"id": $id}.newStringTable)


# ------
# search
# ------


proc searchTweets*(twitter: TwitterAPI, q: string,
    additionalParams: StringTableRef = nil): Response =
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


proc customProfilesDestroy*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `custom_profiles/destroy.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return delete(twitter, "custom_profiles/destroy.json", additionalParams)
  else:
    return delete(twitter, "custom_profiles/destroy.json", {
        "id": $id}.newStringTable)


proc customProfilesId*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `custom_profiles/:id.json` endpoint
  return get(twitter, "custom_profiles/" & $id & ".json", additionalParams)


proc customProfilesLists*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `custom_profiles/list.json` endpoint
  return get(twitter, "custom_profiles/list.json", additionalParams)


proc customProfilesNew*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
  ## `custom_profiles/new.json` endpoint
  return post(twitter, "custom_profiles/new.json", jsonBody)


# ------
# trends
# ------


proc trendsAvailable*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `trends/available.json` endpoint
  return get(twitter, "trends/available.json", additionalParams)


proc trendsClosest*(twitter: TwitterAPI, lat: float, lon: float,
    additionalParams: StringTableRef = nil): Response =
  ## `trends/closest.json` endpoint
  if additionalParams != nil:
    additionalParams["lat"] = $ lat
    additionalParams["lon"] = $ lon
    return get(twitter, "trends/closest.json", additionalParams)
  else:
    return get(twitter, "trends/closest.json", {"lat": $lat,
        "lon": $lon}.newStringTable)


proc trendsPlace*(twitter: TwitterAPI, id: int32,
    additionalParams: StringTableRef = nil): Response =
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


proc geoId*(twitter: TwitterAPI, id: string,
    additionalParams: StringTableRef = nil): Response =
  ## `geo/id/:place_id.json` endpoint
  return get(twitter, "geo/id/" & id & ".json", additionalParams)


proc geoReverseGeocode*(twitter: TwitterAPI, lat: float, lon: float,
                        additionalParams: StringTableRef = nil): Response =
  ## `geo/reverse_geocode.json` endpoint
  if additionalParams != nil:
    additionalParams["lat"] = $ lat
    additionalParams["lon"] = $ lon
    return get(twitter, "geo/reverse_geocode.json", additionalParams)
  else:
    return get(twitter, "geo/reverse_geocode.json", {"lat": $lat,
        "lon": $lon}.newStringTable)


proc geoSearch*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
  ## `geo/search.json` endpoint
  return get(twitter, "geo/search.json", additionalParams)


# --------
# insights
# --------


proc insightsEngagementTotals*(twitter: TwitterAPI,
    jsonBody: JsonNode): Response =
  ## `insights/enagement/totals.json` endpoint
  return post(twitter, "insights/enagement/totals.json", jsonBody)


proc insightsEngagementHistorical*(twitter: TwitterAPI,
    jsonBody: JsonNode): Response =
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
