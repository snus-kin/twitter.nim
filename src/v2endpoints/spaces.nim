import strtabs, httpclient, json
import ../utility/[requests, types]

# ------------------------
#     Search Spaces
# ------------------------
proc spacesSearch*(twitter: TwitterAPI, query: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/spaces/search` endpoint
    if additionalParams != nil:
        additionalParams["query"] = query
        return get(twitter, "2/spaces/search", additionalParams)
    else:
        return get(twitter, "2/spaces/search", {
            "query": query}.newStringTable)

# ------------------------
#     Spaces lookup
# ------------------------
proc spaces*(twitter: TwitterAPI, ids: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/spaces` endpoint
    if additionalParams != nil:
        additionalParams["ids"] = ids
        return get(twitter, "2/spaces", additionalParams)
    else:
        return get(twitter, "2/spaces", {
            "ids": ids}.newStringTable)

proc spacesId*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/spaces/:id` endpoint
    return get(twitter, "2/spaces/" & id, additionalParams)

proc spacesIdBuyers*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/spaces/:id/buyers` endpoint
    return get(twitter, "2/spaces/" & id & "/buyers", additionalParams)

proc spacesIdTweets*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/spaces/:id/tweets` endpoint
    return get(twitter, "2/spaces/" & id & "/tweets", additionalParams)

proc spacesByCreatorIds*(twitter: TwitterAPI, ids: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/spaces/by/creator_ids` endpoint
    if additionalParams != nil:
        additionalParams["ids"] = ids
        return get(twitter, "2/spaces/by/creator_ids", additionalParams)
    else:
        return get(twitter, "2/spaces/by/creator_ids", {
            "ids": ids}.newStringTable)