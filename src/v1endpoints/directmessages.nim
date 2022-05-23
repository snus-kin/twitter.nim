import strtabs, httpclient, json
import ../utility/[requests, types]
# ---------------
# direct_messages
# ---------------


proc directMessagesEventsDestroy*(twitter: TwitterAPI, id: int,
                                           additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/events/destroy.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return delete(twitter, "1.1/direct_messages/events/destroy.json", additionalParams)
  else:
    return delete(twitter, "1.1/direct_messages/events/destroy.json", {
        "id": $id}.newStringTable)


proc directMessagsEventsList*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/events/list.json` endpoint
  return get(twitter, "1.1/direct_messages/events/list.json", additionalParams)


proc directMessagesEventsShow*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/events/show.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return get(twitter, "1.1/direct_messages/events/show.json", additionalParams)
  else:
    return get(twitter, "1.1/direct_messages/events/show.json", {
        "id": $id}.newStringTable)


proc directMessagesEventsNew*(twitter: TwitterAPI,
    jsonBody: JsonNode): Response =
  ## `direct_messages/events/new.json` endpoint (message_create)
  return post(twitter, "1.1/direct_messages/events/new.json", jsonBody)


proc directMessagesIndicateTyping*(twitter: TwitterAPI,
    jsonBody: JsonNode): Response =
  ## `direct_messages/indicate_typing.json` endpoint
  return post(twitter, "1.1/direct_messages/indicate_typing.json", jsonBody)


proc directMessagesMarkRead*(twitter: TwitterAPI, lastReadEventId: int,
    recipientId: int, additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/mark_read.json` endpoint
  if additionalParams != nil:
    additionalParams["last_read_event_id"] = $lastReadEventId
    additionalParams["recipient_id"] = $recipientId
    return post(twitter, "1.1/direct_messages/mark_read.json", additionalParams)
  else:
    return post(twitter, "1.1/direct_messages/mark_read.json", {
        "last_read_event_id": $lastReadEventId,
        "recipient_id": $recipientId}.newStringTable)


proc directMessagesWelcomeMessagesDestroy*(twitter: TwitterAPI, id: int,
                                           additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/welcome_messages/destroy.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return delete(twitter, "1.1/direct_messages/welcome_messages/destroy.json", additionalParams)
  else:
    return delete(twitter, "1.1/direct_messages/welcome_messages/destroy.json", {
        "id": $id}.newStringTable)


proc directMessagesWelcomeMessagesRulesDestroy*(twitter: TwitterAPI, id: int,
                                           additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/welcome_messages/rules/destroy.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return delete(twitter, "1.1/direct_messages/rules/welcome_messages/destroy.json", additionalParams)
  else:
    return delete(twitter, "1.1/direct_messages/rules/welcome_messages/destroy.json",
        {"id": $id}.newStringTable)


proc directMessagesWelcomeMessagesUpdate*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/welcome_messages/update.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $id
    return put(twitter, "1.1/direct_messages/welcome_messages/update.json", additionalParams)
  else:
    return put(twitter, "1.1/direct_messages/welcome_messages/update.json", {
        "id": $id}.newStringTable)


proc directMessagesWelcomeMessagesList*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/welcome_messages/list.json` endpoint
  return get(twitter, "1.1/direct_messages/welcome_messages/list.json", additionalParams)


proc directMessagesWelcomeMessagesRulesList*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/welcome_messages/rules/list.json` endpoint
  return get(twitter, "1.1/direct_messages/welcome_messages/rules/list.json", additionalParams)


proc directMessagesWelcomeMessagesRulesShow*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/welcome_messages/rules/show.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $ id
    return get(twitter, "1.1/direct_messages/welcome_messages/rules/show.json", additionalParams)
  else:
    return get(twitter, "1.1/direct_messages/welcome_messages/rules/show.json", {
        "id": $id}.newStringTable)


proc directMessagesWelcomeMessagesShow*(twitter: TwitterAPI, id: int,
    additionalParams: StringTableRef = nil): Response =
  ## `direct_messages/welcome_messages/show.json` endpoint
  if additionalParams != nil:
    additionalParams["id"] = $ id
    return get(twitter, "1.1/direct_messages/welcome_messages/show.json", additionalParams)
  else:
    return get(twitter, "1.1/direct_messages/welcome_messages/show.json", {
        "id": $id}.newStringTable)


proc directMessagesWelcomeMessagesNew*(twitter: TwitterAPI,
    jsonBody: JsonNode): Response =
  ## `direct_messages/welcome_messages/new.json` endpoint
  return post(twitter, "1.1/direct_messages/welcome_messages/new.json", jsonBody)


proc directMessagesWelcomeMessagesRulesNew*(twitter: TwitterAPI,
    jsonBody: JsonNode): Response =
  ## `direct_messages/welcome_messages/rules/new.json` endpoint
  return post(twitter, "1.1/direct_messages/welcome_messages/rules/new.json", jsonBody)


