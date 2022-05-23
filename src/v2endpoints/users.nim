import strtabs, httpclient, json
import ../utility/[requests, types]

# ------------------------
#        Blocks
# ------------------------
proc usersSourceBlockingTarget*(twitter: TwitterAPI, sourceUserId: string, targetUserId: string, additionalParams: StringTableRef = nil): Response =
    ## `DELETE /2/users/:source_user_id/blocking/:target_user_id` endpoint
    return delete(twitter, "2/users/" & sourceUserId & "/blocking/" & targetUserId, additionalParams)

proc usersIdBlocking*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/:id/blocking` endpoint
    return get(twitter, "2/users/" & id & "/blocking", additionalParams)

proc usersIdBlocking*(twitter: TwitterAPI, id: string, jsonBody: JsonNode): Response =
    ## `POST /2/users/:id/blocking` endpoint
    return post(twitter, "2/users/" & id & "/blocking", jsonBody)

# ------------------------
#         Follows
# ------------------------
proc usersSourceFollowingTarget*(twitter: TwitterAPI, sourceUserId: string, targetUserId: string, additionalParams: StringTableRef = nil): Response =
    ## `DELETE /2/users/:source_user_id/following/:target_user_id` endpoint
    ## Allows a user ID to unfollow another user.
    return delete(twitter, "2/users/" & sourceUserId & "/following/" & targetUserId, additionalParams)

proc usersIdFollowers*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/:id/followers` endpoint
    return get(twitter, "2/users/" & id & "/followers", additionalParams)

proc usersIdFollowing*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/:id/following` endpoint
    return get(twitter, "2/users/" & id & "/following", additionalParams)

proc usersIdFollowing*(twitter: TwitterAPI, id: string, jsonBody: JsonNode): Response =
    ## `POST /2/users/:id/following` endpoint
    return post(twitter, "2/users/" & id & "/following", jsonBody)

# ------------------------
#          Mutes
# ------------------------
proc usersSourceMutingTarget*(twitter: TwitterAPI, sourceUserId: string, targetUserId: string, additionalParams: StringTableRef = nil): Response =
    ## `DELETE /2/users/:source_user_id/muting/:target_user_id` endpoint
    ## Allows an authenticated user ID to unmute the target user.
    return delete(twitter, "2/users/" & sourceUserId & "muting/" & targetUserId, additionalParams)

proc usersIdMuting*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/:id/muting` endpoint
    ## Returns a list of users who are muted by the specified user ID.
    return get(twitter, "2/users/" & id & "/muting", additionalParams)

proc usersIdMuting*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
    ## `POST /2/users/:id/muting` endpoint
    ## Allows an authenticated user ID to mute the target user.
    return post(twitter, "2/users/" & id & "/muting", jsonBody)

# ------------------------
#     Users lookup
# ------------------------
proc users*(twitter: TwitterAPI, ids: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users` endpoint
    if additionalParams != nil:
        additionalParams["ids"] = ids
        return get(twitter, "2/users", additionalParams)
    else:
        return get(twitter, "2/users", {"ids": ids}.newStringTable)

proc usersId*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/:id` endpoint
    return get(twitter, "2/users/" & id, additionalParams)

proc usersBy*(twitter: TwitterAPI, usernames: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/by` endpoint
    if additionalParams != nil:
        additionalParams["usernames"] = usernames
        return get(twitter, "2/users/by", additionalParams)
    else:
        return get(twitter, "2/users/by", {"usernames": usernames}.newStringTable)

proc usersByUsernameUsername*(twitter: TwitterAPI, username: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/by/username/:username` endpoint
    return get(twitter, "2/users/by/username" & username, additionalParams)

proc usersMe*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/me` endpoint
    return get(twitter, "2/users/me", additionalParams)