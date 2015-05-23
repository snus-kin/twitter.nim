import twitter

when isMainModule:
  var consumerToken = newConsumerToken("Your Consumer Key", "Your Consumer Secret")
  var twitterAPI = newTwitterAPI(consumerToken,
                                 "Your Access Token",
                                 "Your Access Token Secret")

  var resp = twitterAPI.get("account/verify_credentials.json")
  echo resp.status
