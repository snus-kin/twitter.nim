import strtabs, httpclient, json
import ../utility/[requests, types]

# ------------------------
#         Users
# ------------------------
#     Blocks
# TODO DELETE /2/users/:source_user_id/blocking/:target_user_id
# TODO GET /2/users/:id/blocking
# TODO POST /2/users/:id/blocking
# ------------------------
#        Follows
# ------------------------
# TODO DELETE /2/users/:source_user_id/following/:target_user_id
# TODO GET /2/users/:id/followers
# TODO GET /2/users/:id/following
# TODO POST /2/users/:id/following
# ------------------------
#          Mutes
# ------------------------
# TODO DELETE /2/users/:source_user_id/muting/:target_user_id
# TODO GET /2/users/:id/muting
# TODO POST /2/users/:id/muting

# ------------------------
#     Users lookup
# ------------------------
# TODO  GET /2/users
# TODO  GET /2/users/:id
# TODO  GET /2/users/by
# TODO  GET /2/users/by/username/:username
# TODO  GET /2/users/me

proc users*(twitter: TwitterAPI, ids: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users` endpoint
    if additionalParams != nil:
        additionalParams["ids"] = ids
        return get(twitter, "2/users", additionalParams)
    else:
        return get(twitter, "2/users", {"ids": ids}.newStringTable)