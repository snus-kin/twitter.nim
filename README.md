# twitter ![.github/workflows/tests.yml](https://github.com/snus-kin/twitter.nim/workflows/.github/workflows/tests.yml/badge.svg?branch=master)

Low-level twitter API wrapper library for Nim. 

[Documentation](https://snus-kin.github.io/twitter.nim/twitter.html)

## Installation
From Nimble:
```console
$ nimble install twitter
```

From Github:

```console
$ git clone git://github.com/snus-kin/twitter.nim
$ cd twitter.nim && nimble install
```

## Usage
To use the library, `import twitter` and compile with `-d:ssl` 

## Example

```nim
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
