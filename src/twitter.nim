import httpclient, strtabs, json

import utility/[types, requests]
include auth
include v1endpoints/[lists, followers, collections, users, statuses, directmessages, media, misc]
include v2endpoints/[complicance, lists, spaces, tweets, users]

export types, requests


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
  return post(twitter, "1.1/media/upload.json", ubody, true, data)


template callAPI*(twitter: TwitterAPI, api: untyped,
                  additionalParams: StringTableRef = nil): untyped =
  ## Template to callAPI
  ##
  ## Example:
  ## ```nim
  ## var testStatus = {"status": "test"}.newStringTable
  ## var resp = twitterAPI.callAPI(statusesUpdate, testStatus)```
  api(twitter, additionalParams)
