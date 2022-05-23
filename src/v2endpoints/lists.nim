# ------------------------
#     List Tweets lookup
# ------------------------
proc listsIdTweets*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/lists/:id/tweets` endpoint
    return get(twitter, "2/lists/" & id & "/tweets", additionalParams)

# ------------------------
#     List follows
# ------------------------
proc usersSourceFollowedListsTarget*(twitter: TwitterAPI, sourceUserId: string, targetUserId: string, additionalParams: StringTableRef = nil): Response =
    ## `DELETE /2/users/:id/followed_lists/:list_id` endpoint
    return delete(twitter, "2/users/" & sourceUserId & "/followed_lists/" & targetUserId, additionalParams)

proc listsIdFollowers*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/lists/:id/followers` endpoint
    return get(twitter, "2/lists/" & id & "/followers", additionalParams)

proc usersIdFollowedLists*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/:id/followed_lists` endpoint
    return get(twitter, "2/users/" & id & "/followedLists", additionalParams)

proc usersIdMembers*(twitter: TwitterAPI, id: string, jsonBody: JsonNode): Response =
    ## `POST /2/users/:id/followed_lists` endpoint
    return post(twitter, "2/users/" & id & "/followed_lists", jsonBody)

# ------------------------
#     List lookup
# ------------------------
proc listsId*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/lists/:id` endpoint
    return get(twitter, "2/lists/" & id, additionalParams)

proc usersIdFollowedLists*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/:id/owned_lists` endpoint
    return get(twitter, "2/users/" & id & "/owned_lists", additionalParams)

# ------------------------
#     List members
# ------------------------
proc listsIdMembersListsUserId*(twitter: TwitterAPI, id: string, userId: string, additionalParams: StringTableRef = nil): Response =
    ## `DELETE /2/lists/:id/members/:user_id` endpoint
    return delete(twitter, "2/lists/" & id & "/members/" & userId, additionalParams)

proc listsIdFollowedLists*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/lists/:id/members` endpoint
    return get(twitter, "2/lists/" & id & "/members", additionalParams)

proc usersIdFollowedLists*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/:id/list_memberships` endpoint
    return get(twitter, "2/users/" & id & "/list_memberships", additionalParams)

proc listsIdMembers*(twitter: TwitterAPI, id: string, jsonBody: JsonNode): Response =
    ## `POST /2/lists/:id/members` endpoint
    return post(twitter, "2/lists/" & id & "/members", jsonBody)

# ------------------------
#     Manage Lists
# ------------------------
proc listsIdDelete(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `DELETE /2/lists/:id` endpoint
    ## Sorry about this breaking the naming convention, this overlaps with the GET method so I couldn't override it
    ## The same to be said about the PUT endpoint too
    return delete(twitter, "2/lists/" & id, additionalParams)

proc listsIdPut(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `PUT /2/lists/:id` endpoint
    ## Sorry about this breaking the naming convention
    return put(twitter, "2/lists/" & id, additionalParams)

proc lists*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
    ## `POST /2/lists` endpoint
    
    # This is a weirdly simple one lol
    return post(twitter, "2/lists", jsonBody)

# ------------------------
#     Pinned Lists
# ------------------------
proc usersIdPinnedListsListId*(twitter: TwitterAPI, id: string, userId: string, additionalParams: StringTableRef = nil): Response =
    # `DELETE /2/users/:id/pinned_lists/:list_id` endpoint
    return delete(twitter, "2/users/" & id & "/pinned_lists/" & userIds, additionalParams)

proc usersIdFollowedLists(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/:id/pinned_lists` endpoint
    return get(twitter, "2/users/" & id & "/pinned_lists", additionalParams)

proc usersIdPinnedLists*(twitter: TwitterAPI, id: string, jsonBody: JsonNode): Response =
    ## `POST /2/users/:id/pinned_lists` endpoint
    return post(twitter, "2/users/" & id & "/pinned_lists", jsonBody)