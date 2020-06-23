# twitter [![Circle CI](https://circleci.com/gh/dchem/twitter.nim.svg?style=svg)](https://circleci.com/gh/dchem/twitter.nim)

Low-level twitter API wrapper library for Nim.

Special thanks to kubo39 for creating the package.
Originally from https://github.com/kubo39/twitter

## Installation

from github:

```console
$ git clone git://github.com/dchem/twitter.nim
$ cd twitter.nim && nimble install
```

## Example

```nimrod
import twitter, json, strtabs

when isMainModule:
  var parsed = parseFile("credential.json")

  var consumerToken = newConsumerToken(parsed["ConsumerKey"].str,
                                       parsed["ConsumerSecret"].str)
  var twitterAPI = newTwitterAPI(consumerToken,
                                 parsed["AccessToken"].str,
                                 parsed["AccessTokenSecret"].str)

  # Simply get.
  var resp = twitterAPI.get("account/verify_credentials.json")
  echo resp.status

  # Using proc corresponding twitter REST APIs.
  resp = twitterAPI.userTimeline()
  echo parseJson(resp.body)

  # Using `callAPI` template.
  var testStatus = {"status": "test"}.newStringTable
  resp = twitterAPI.callAPI(statusesUpdate, testStatus)
  echo parseJson(resp.body)

  # Upload media
  var ubody = {"media_type": "twitter_image"}.newStringTable
  var image = readFile("example.png")
  resp = twitterAPI.post("media/upload.json", ubody, media=true, data=image)
  echo parseJson(resp.body)
```
