import strtabs, httpclient
import ../utility/[requests, types]
# --------
# statuses
# --------


proc statusesFilter*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `statuses/filter.json` endpoint
  return post(twitter, "1.1/statuses/filter.json", additionalParams)


proc statusesUserTimeline*(twitter: TwitterAPI,
                   additionalParams: StringTableRef = nil): Response =
  ## `statuses/user_timeline.json` endpoint
  return get(twitter, "1.1/statuses/user_timeline.json", additionalParams)


proc statusesHomeTimeline*(twitter: TwitterAPI,
                   additionalParams: StringTableRef = nil): Response =
  ## `statuses/home_timeline.json` endpoint
  return get(twitter, "1.1/statuses/home_timeline.json", additionalParams)


proc statusesMentionsTimeline*(twitter: TwitterAPI,
                       additionalParams: StringTableRef = nil): Response =
  ## `statuses/mentions_timeline.json` endpoint
  return get(twitter, "1.1/statuses/mentions_timeline.json", additionalParams)


proc statusesLookup*(twitter: TwitterAPI, ids: string,
    additionalParams: StringTableRef = nil): Response =
  ## `statuses/lookup.json` endpoint
  ##
  ## ids is a string of comma seperated tweet ids
  if additionalParams != nil:
    additionalParams["id"] = ids
    return get(twitter, "1.1/statuses/lookup.json", additionalParams)
  else:
    return get(twitter, "1.1/statuses/lookup.json", {"id": ids}.newStringTable)


proc statusesOembed*(twitter: TwitterAPI, url: string,
    additionalParams: StringTableRef = nil): Response =
  ## `oembed` endpoint
  ##
  ##  Used for generating embeds from tweets, uses publish.twitter.com as a url
  if additionalParams != nil:
    additionalParams["url"] = url
    return get(twitter, "1.1/statuses/retweeters/ids.json", additionalParams,
        publish = true)
  else:
    return get(twitter, "1.1/statuses/retweeters/ids.json", {
        "url": url}.newStringTable, publish = true)


proc statusesRetweetersIds*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `statuses/retweeters/ids.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return get(twitter, "1.1/statuses/retweeters/ids.json", additionalParams)
  else:
    return get(twitter, "1.1/statuses/retweeters/ids.json", {
        "id": $id}.newStringTable)


proc statusesRetweets*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `statuses/retweets/:id.json` endpoint
  return get(twitter, "1.1/statuses/retweets/" & $id & ".json", additionalParams)


proc statusesRetweetsOfMe*(twitter: TwitterAPI,
                   additionalParams: StringTableRef = nil): Response =
  ## `statuses/retweets_of_me.json` endpoint
  return get(twitter, "1.1/statuses/retweets_of_me.json", additionalParams)


proc statusesShow*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `statuses/show.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return get(twitter, "1.1/statuses/show.json", additionalParams)
  else:
    return get(twitter, "1.1/statuses/show.json", {"id": $id}.newStringTable)


proc statusesDestroy*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `statuses/destroy/:id.json` endpoint
  return post(twitter, "1.1/statuses/destroy/" & $id & ".json", additionalParams)


proc statusesRetweet*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `statuses/retweet/:id` endpoint
  return post(twitter, "1.1/statuses/retweet/" & $id & ".json", additionalParams)


proc statusesUnretweet*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `statuses/unretweet/:id.json` endpoint
  return post(twitter, "1.1/statuses/unretweet/" & $id & ".json", additionalParams)


proc statusesUpdate*(twitter: TwitterAPI, status: string,
                    additionalParams: StringTableRef = nil): Response =
  ## `statuses/update.json` endpoint
  if additionalParams != nil:
    additionalParams["status"] = status
    return post(twitter, "1.1/statuses/update.json", additionalParams)
  else:
    return post(twitter, "1.1/statuses/update.json", {
        "status": status}.newStringTable)


proc statusesUpdate*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `statuses/update.json` endpoint
  return post(twitter, "1.1/statuses/update.json", additionalParams)


proc statusesSample*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `statuses/sample.json` endpoint
  return get(twitter, "1.1/statuses/sample.json", additionalParams)


