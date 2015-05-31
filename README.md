# twitter.nim

Low-level twitter API wrapper library for nim.

## Installation

from github:

```
$ git clone git://github.com/kubo39/twitter.nim
$ cd twitter.nim && nimble install
```

## Example

```nimrod
import twitter, tables, json

when isMainModule:
  var consumerToken = newConsumerToken("Your Consumer Key", "Your Consumer Secret")
  var twitterAPI = newTwitterAPI(consumerToken,
                                 "Your Access Token",
                                 "Your Access Token Secret")

  # Simply get.
  var resp = twitterAPI.get("account/verify_credentials.json")
  echo resp.status

  # Using proc corresponding twitter REST APIs.
  resp = twitterAPI.userTimeline()
  echo parseJson(resp.body)

  # Using `callAPI` template.
  var testStatus: Table[string, string] = initTable[string, string]()
  testStatus["status"] = "test"
  resp = twitterAPI.callAPI(statusesUpdate, testStatus)
  echo parseJson(resp.body)
```


Many thanks to https://github.com/alphaKAI/twitter4d !
