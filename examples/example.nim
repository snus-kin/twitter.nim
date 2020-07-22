import twitter, json, strtabs, httpclient, streams, os

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

  # ditto, but selected by screen name.
  resp = twitterAPI.user("sn_fk_n")
  echo resp.status

  # Using proc corresponding twitter REST APIs.
  resp = twitterAPI.userTimeline()
  echo pretty parseJson(resp.body)

  # Using `callAPI` template.
  var testStatus = {"status": "test"}.newStringTable
  resp = twitterAPI.callAPI(statusesUpdate, testStatus)
  echo pretty parseJson(resp.body)

  # Upload files in a stream
  const buffersize = 200000
  let mediaStream = newFileStream("test.jpg", fmRead)
  let mediaSize = "test.jpg".getFileSize

  # INIT
  resp = twitterAPI.mediaUploadInit("image/jpg", $ mediaSize)
  let initResp = parseJson(resp.body)
  let mediaId = initResp["media_id_string"].getStr

  # APPEND
  var buffer = ""
  var segment = 0
  var total = 0
  if not isNil(mediaStream):
    while not mediaStream.atEnd(): 
      buffer = mediaStream.readStr(buffersize)
      echo "Uploading segment: ", segment
      resp = twitterAPI.mediaUploadAppend(mediaId, $ segment, buffer)
      # Response should be 204
      if resp.status != "204 No Content":
        echo resp.status
        echo pretty parseJson(resp.body)
        stderr.writeLine "Error when uploading"
        break
      segment += 1
      total += len(buffer)

  # STATUS
  resp = twitterAPI.mediaUploadStatus(mediaId)
  # hopefully we don't have to poll it since we didn't upload async
  echo pretty parseJson(resp.body)

  # FINALIZE
  resp = twitterAPI.mediaUploadFinalize(mediaId)
  let final_media_id = parseJson(resp.body)["media_id_string"].getStr
  echo final_media_id
  
  # Send a tweet with that media
  var mediaStatus = {"status": "This is an image upload test", "media_ids": final_media_id}.newStringTable
  resp = twitterAPI.statusesUpdate(mediaStatus)
