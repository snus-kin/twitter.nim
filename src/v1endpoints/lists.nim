import strtabs, httpclient
import ../utility/[requests, types]
# -----
# lists
# -----
proc listsList*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/list.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "1.1/lists/list.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/list.json", {
        "screen_name": screenName}.newStringTable)


proc listsList*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/list.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "1.1/lists/list.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/list.json", {"user_id": $userId}.newStringTable)


proc listsMembers*(twitter: TwitterAPI, slug: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/members.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return get(twitter, "1.1/lists/members.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/members.json", {"slug": slug}.newStringTable)


proc listsMembers*(twitter: TwitterAPI, listId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/members.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return get(twitter, "1.1/lists/members.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/members.json", {
        "list_id": $listId}.newStringTable)


proc listsMembersShow*(twitter: TwitterAPI, slug: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/members/show.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return get(twitter, "1.1/lists/members/show.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/members/show.json", {
        "slug": slug}.newStringTable)


proc listsMembersShow*(twitter: TwitterAPI, listId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/members/show.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return get(twitter, "1.1/lists/members/show.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/members/show.json", {
        "list_id": $listId}.newStringTable)


proc listsMemberships*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/memberships.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "1.1/lists/memberships.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/memberships.json", {
        "screen_name": screenName}.newStringTable)


proc listsMemberships*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/memberships.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "1.1/lists/memberships.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/memberships.json", {
        "user_id": $userId}.newStringTable)


proc listsOwnerships*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/ownerships.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "1.1/lists/ownerships.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/ownerships.json", {
        "screen_name": screenName}.newStringTable)


proc listsOwnerships*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/ownerships.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "1.1/lists/ownerships.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/ownerships.json", {
        "user_id": $userId}.newStringTable)


proc listsShow*(twitter: TwitterAPI, slug: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/show.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return get(twitter, "1.1/lists/show.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/show.json", {"slug": slug}.newStringTable)


proc listsShow*(twitter: TwitterAPI, listId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/show.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return get(twitter, "1.1/lists/show.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/show.json", {"list_id": $listId}.newStringTable)


proc listsStatuses*(twitter: TwitterAPI, slug: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/statuses.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return get(twitter, "1.1/lists/statuses.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/statuses.json", {"slug": slug}.newStringTable)


proc listsStatuses*(twitter: TwitterAPI, listId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/statuses.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return get(twitter, "1.1/lists/statuses.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/statuses.json", {
        "list_id": $listId}.newStringTable)


proc listsSubscribers*(twitter: TwitterAPI, slug: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/subscribers.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return get(twitter, "1.1/lists/subscribers.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/subscribers.json", {"slug": slug}.newStringTable)


proc listsSubscribers*(twitter: TwitterAPI, listId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/subscribers.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return get(twitter, "1.1/lists/subscribers.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/subscribers.json", {
        "list_id": $listId}.newStringTable)


proc listsSubscribersShow*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/subscribers/show.json` endpoint
  # NB: this could be, I think 4, overloading procs but I have decided not to for simplicity
  return get(twitter, "1.1/lists/subscribers/show.json", additionalParams)


proc listsSubscriptions*(twitter: TwitterAPI, screenName: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/subscriptions.json` endpoint for screen name
  if additionalParams != nil:
    additionalParams["screen_name"] = screenName
    return get(twitter, "1.1/lists/subscriptions.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/subscriptions.json", {
        "screen_name": screenName}.newStringTable)


proc listsSubscriptions*(twitter: TwitterAPI, userId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/subscriptions.json` endpoint for user id
  if additionalParams != nil:
    additionalParams["user_id"] = $userId
    return get(twitter, "1.1/lists/subscriptions.json", additionalParams)
  else:
    return get(twitter, "1.1/lists/subscriptions.json", {
        "user_id": $userId}.newStringTable)


proc listsCreate*(twitter: TwitterAPI, slug: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/create.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return post(twitter, "1.1/lists/create.json", additionalParams)
  else:
    return post(twitter, "1.1/lists/create.json", {"slug": slug}.newStringTable)


proc listsCreate*(twitter: TwitterAPI, listId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/create.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return post(twitter, "1.1/lists/create.json", additionalParams)
  else:
    return post(twitter, "1.1/lists/create.json", {
        "list_id": $listId}.newStringTable)


proc listsDestroy*(twitter: TwitterAPI, slug: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/destroy.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return post(twitter, "1.1/lists/destroy.json", additionalParams)
  else:
    return post(twitter, "1.1/lists/destroy.json", {"slug": slug}.newStringTable)


proc listsDestroy*(twitter: TwitterAPI, listId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/destroy.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return post(twitter, "1.1/lists/destroy.json", additionalParams)
  else:
    return post(twitter, "1.1/lists/destroy.json", {
        "list_id": $listId}.newStringTable)


proc listsMembersCreate*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/members/create.json` endpoint
  # NB: this could be, I think 4, overloading procs but I have decided not to for simplicity
  return post(twitter, "1.1/lists/members/create.json", additionalParams)


proc listsMembersCreateAll*(twitter: TwitterAPI, listId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/members/create_all.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return post(twitter, "1.1/lists/members/create_all.json", additionalParams)
  else:
    return post(twitter, "1.1/lists/members/create_all.json", {
        "list_id": $listId}.newStringTable)


proc listsMembersCreateAll*(twitter: TwitterAPI, slug: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/members/create_all.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return post(twitter, "1.1/lists/members/create_all.json", additionalParams)
  else:
    return post(twitter, "1.1/lists/members/create_all.json", {
        "slug": slug}.newStringTable)


proc listsMembersDestroy*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/members/destroy.json` endpoint
  # NB: this could be, I think 4, overloading procs but I have decided not to for simplicity
  return post(twitter, "1.1/lists/members/destroy.json", additionalParams)


proc listsMembersDestroyAll*(twitter: TwitterAPI, listId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/members/destroy_all.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return post(twitter, "1.1/lists/members/destroy_all.json", additionalParams)
  else:
    return post(twitter, "1.1/lists/members/destroy_all.json", {
        "list_id": $listId}.newStringTable)


proc listsMembersDestroyAll*(twitter: TwitterAPI, slug: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/members/destroy_all.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return post(twitter, "1.1/lists/members/destroy_all.json", additionalParams)
  else:
    return post(twitter, "1.1/lists/members/destroy_all.json", {
        "slug": slug}.newStringTable)


proc listsSubscribersCreate*(twitter: TwitterAPI, slug: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/subscribers/create.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return post(twitter, "1.1/lists/subscribers/create.json", additionalParams)
  else:
    return post(twitter, "1.1/lists/subscribers/create.json", {
        "slug": slug}.newStringTable)


proc listsSubscribersCreate*(twitter: TwitterAPI, listId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/subscribers/create.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return post(twitter, "1.1/lists/subscribers/create.json", additionalParams)
  else:
    return post(twitter, "1.1/lists/subscribers/create.json", {
        "list_id": $listId}.newStringTable)


proc listsSubscribersDestroy*(twitter: TwitterAPI, slug: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/subscribers/destroy.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return post(twitter, "1.1/lists/subscribers/destroy.json", additionalParams)
  else:
    return post(twitter, "1.1/lists/subscribers/destroy.json", {
        "slug": slug}.newStringTable)


proc listsSubscribersDestroy*(twitter: TwitterAPI, listId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/subscribers/destroy.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return post(twitter, "1.1/lists/subscribers/destroy.json", additionalParams)
  else:
    return post(twitter, "1.1/lists/subscribers/destroy.json", {
        "list_id": $listId}.newStringTable)


proc listsUpdate*(twitter: TwitterAPI, slug: string,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/update.json` endpoint for slug
  if additionalParams != nil:
    additionalParams["slug"] = slug
    return post(twitter, "1.1/lists/update.json", additionalParams)
  else:
    return post(twitter, "1.1/lists/update.json", {"slug": slug}.newStringTable)


proc listsUpdate*(twitter: TwitterAPI, listId: int,
    additionalParams: StringTableRef = nil): Response =
  ## `lists/update.json` endpoint for list id
  if additionalParams != nil:
    additionalParams["list_id"] = $listId
    return post(twitter, "1.1/lists/update.json", additionalParams)
  else:
    return post(twitter, "1.1/lists/update.json", {
        "list_id": $listId}.newStringTable)
