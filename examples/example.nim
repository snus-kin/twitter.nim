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
  resp = twitterAPI.usersLookup("sn_fk_n")
  echo pretty parseJson(resp.body)

  # Using proc corresponding twitter REST APIs.
  resp = twitterAPI.statusesUserTimeline()
  echo pretty parseJson(resp.body)

  # Using `callAPI` template.
  let status = {"status": "hello world"}.newStringTable
  resp = twitterAPI.callAPI(statusesUpdate, status)
  echo pretty parseJson(resp.body)

  # Upload files in a stream
  const buffersize = 500000
  let mediaStream = newFileStream("test.jpg", fmRead)
  let mediaSize = "test.jpg".getFileSize

  # INIT
  resp = twitterAPI.mediaUploadInit("image/jpg", $ mediaSize)
  let initResp = parseJson(resp.body)
  echo pretty initResp
  let mediaId = initResp["media_id_string"].getStr

  # APPEND
  if not isNil(mediaStream):
    var buffer = ""
    var segment = 0
    while not mediaStream.atEnd(): 
      buffer = mediaStream.readStr(buffersize)
      echo "Uploading segment: ", segment
      resp = twitterAPI.mediaUploadAppend(mediaId, $ segment, buffer)
      # Response should be 204
      if resp.status != "204 No Content":
        stderr.writeLine "Error when uploading, server returned: " & resp.status
        quit(1)
      segment += 1

  # FINALIZE
  resp = twitterAPI.mediaUploadFinalize(mediaId)
  echo pretty parseJson(resp.body)
  let finalResp = parseJson(resp.body)
  let finalMediaId = finalResp["media_id_string"].getStr

  # These should be the same
  assert mediaId == finalMediaId

  # STATUS
  # If the API tells use it has to process the media
  if finalResp.hasKey("processing_info"):
    resp = twitterAPI.mediaUploadStatus(finalMediaId)
    var respBody = parseJson(resp.body)
    # Loop until it reaches the end state of 'failed' or 'succeeded'
    while respBody["processing_info"]["state"].getStr notin ["failed", "succeeded"]:
      echo pretty parseJson(resp.body)
      resp = twitterAPI.mediaUploadStatus(finalMediaId)
      respBody = parseJson(resp.body)
      # Sleep for the amount of seconds it tells you to
      sleep(respBody["processing_info"]["check_after_secs"].getInt * 100)

    if respBody["processing_info"]["state"].getStr == "failed":
      stderr.writeLine("Processing failed, perhaps your video was in the wrong format")

  # Attach metadata
  let mediaMetadata = %* {"media_id": mediaId, "alt_text":{"text":"This is an example of alt text"}}
  resp = twitterAPI.mediaMetadataCreate(mediaMetadata)
  # This should be 2xx
  echo resp.status
  
  # Send a tweet with that media
  let mediaStatus = {"media_ids": finalMediaId}.newStringTable
  resp = twitterAPI.statusesUpdate("This is a media upload test", mediaStatus)
