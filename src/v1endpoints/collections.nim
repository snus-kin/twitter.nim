import strtabs, httpclient, json
import ../utility/[requests, types]
# -----------
# collections
# -----------


proc collectionsEntries*(twitter: TwitterAPI, id: string,
    additionalParams: StringTableRef = nil): Response =
  ## `collections/entries.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = id
    return get(twitter, "1.1/collections/entries.json", additionalParams)
  else:
    return get(twitter, "1.1/collections/entries.json", {"id": id}.newStringTable)


proc collectionsList*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `collections/list.json` endpoint for twitter user id
  if additionalParams != nil:
    additionalParams["id"] = $id
    return get(twitter, "1.1/collections/list.json", additionalParams)
  else:
    return get(twitter, "1.1/collections/list.json", {"id": $id}.newStringTable)


proc collectionsList*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `collections/list.json` for twitter user screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "1.1/collections/list.json", additionalParams)
  else:
    return get(twitter, "1.1/collections/list.json", {
        "screen_name": screenName}.newStringTable)


proc collectionsShow*(twitter: TwitterAPI, id: string,
    additionalParams: StringTableRef = nil): Response =
  ## `collections/show.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = id
    return get(twitter, "1.1/collections/show.json", additionalParams)
  else:
    return get(twitter, "1.1/collections/show.json", {"id": id}.newStringTable)


proc collectionsCreate*(twitter: TwitterAPI, name: string,
    additionalParams: StringTableRef = nil): Response =
  ## `collections/create.json` endpoint
  if additionalParams != nil:
    additionalParams["name"] = name
    return post(twitter, "1.1/collections/create.json", additionalParams)
  else:
    return post(twitter, "1.1/collections/create.json", {
        "name": name}.newStringTable)


proc collectionsDestroy*(twitter: TwitterAPI, id: string,
    additionalParams: StringTableRef = nil): Response =
  if additionalParams != nil:
    additionalParams["id"] = id
    return post(twitter, "1.1/collections/destroy.json", additionalParams)
  else:
    return post(twitter, "1.1/collections/destroy.json", {"id": id}.newStringTable)


proc collectionsEntriesAdd*(twitter: TwitterAPI, id: string, tweet_id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `collections/entries/add.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = id
    additionalParams["tweet_id"] = $tweet_id
    return post(twitter, "1.1/collections/entries/add.json", additionalParams)
  else:
    return post(twitter, "1.1/collections/entries/add.json", {"id": id,
        "tweet_id": $tweet_id}.newStringTable)


proc collectionsEntriesCurate*(twitter: TwitterAPI,
    jsonBody: JsonNode): Response =
  ## `collections/entries/curate.json` endpoint
  # This is honestly one of the worst parts of the API docs. I can't work out what it does.
  return post(twitter, "1.1/collections/entries/curate.json", jsonBody)


proc collectionsEntriesMove*(twitter: TwitterAPI, id: string, tweet_id: int,
    relative_to: int, additionalParams: StringTableRef = nil): Response =
  ## `collections/entries/move.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = id
    additionalParams["tweet_id"] = $tweet_id
    additionalParams["relative_to"] = $relative_to
    return post(twitter, "1.1/collections/entries/move.json", additionalParams)
  else:
    return post(twitter, "1.1/collections/entries/move.json", {"id": id,
        "tweet_id": $tweet_id, "relative_to": $relative_to}.newStringTable)


proc collectionsEntriesRemove*(twitter: TwitterAPI, id: string, tweet_id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `collections/entries/remove.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = id
    additionalParams["tweet_id"] = $tweet_id
    return post(twitter, "1.1/collections/entries/remove.json", additionalParams)
  else:
    return post(twitter, "1.1/collections/entries/remove.json", {"id": id,
        "tweet_id": $tweet_id}.newStringTable)


proc collectionsUpdate*(twitter: TwitterAPI, id: string,
    additionalParams: StringTableRef = nil): Response =
  ## `collections/update.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = id
    return post(twitter, "1.1/collections/update.json", additionalParams)
  else:
    return post(twitter, "1.1/collections/update.json", {"id": id}.newStringTable)
