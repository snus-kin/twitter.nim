import json, strtabs, httpclient, streams, os
import ../../src/twitter

when isMainModule:
  let parsed = parseFile("credential.json")
  var twitterAPI = newTwitterAPI(parsed["BearerToken"].str)

  # Bearer token get info about an account
  let resp = twitter.v2.usersId(twitterAPI, "1140672492220162052")
  echo pretty parseJson(resp.body)