import strtabs, httpclient
import ../utility/[requests, types]
# -----
# users
# -----


proc usersLookup*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `users/lookup.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return post(twitter, "1.1/users/lookup.json", additionalParams)
  else:
    return post(twitter, "1.1/users/lookup.json", {
        "user_id": $userId}.newStringTable)


proc usersLookup*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `users/lookup.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return post(twitter, "1.1/users/lookup.json", additionalParams)
  else:
    return post(twitter, "1.1/users/lookup.json", {
        "screen_name": screenName}.newStringTable)


proc usersSearch*(twitter: TwitterAPI, q: string,
    additionalParams: StringTableRef = nil): Response =
  ## `users/search.json` endpoint
  if additionalParams != nil:
    additionalParams["q"] = q
    return get(twitter, "1.1/users/search.json", additionalParams)
  else:
    return get(twitter, "1.1/users/search.json", {"q": q}.newStringTable)


proc usersProfileBanner*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `users/profile_banner.json` endpoint
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "1.1/users/profile_banner.json", additionalParams)
  else:
    return get(twitter, "1.1/users/profile_banner.json", {
        "screen_name": screenName}.newStringTable)


proc usersProfileBanner*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `users/profile_banner.json` endpoint
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "1.1/users/profile_banner.json", additionalParams)
  else:
    return get(twitter, "1.1/users/profile_banner.json", {
        "user_id": $userId}.newStringTable)


proc usersShow*(twitter: TwitterAPI, screenName: string,
           additionalParams: StringTableRef = nil): Response =
  ## `users/show.json` endpoint for screen names (@username)
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "1.1/users/show.json", additionalParams)
  else:
    return get(twitter, "1.1/users/show.json", {
        "screen_name": screenName}.newStringTable)


proc usersShow*(twitter: TwitterAPI, userId: int,
           additionalParams: StringTableRef = nil): Response =
  ## `users/show.json` endpoint for user id (e.g. `783214 => @twitter`)
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "1.1/users/show.json", additionalParams)
  else:
    return get(twitter, "1.1/users/show.json", {"user_id": $userId}.newStringTable)


proc usersReportSpam*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `users/report_spam.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["user_id"] = $screenName
    return get(twitter, "1.1/users/report_spam.json", additionalParams)
  else:
    return get(twitter, "1.1/users/report_spam.json", {
        "screen_name": $screenName}.newStringTable)


proc usersReportSpam*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `users/report_spam.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "1.1/users/report_spam.json", additionalParams)
  else:
    return get(twitter, "1.1/users/report_spam.json", {
        "user_id": $userId}.newStringTable)
