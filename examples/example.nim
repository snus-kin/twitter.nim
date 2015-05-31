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
