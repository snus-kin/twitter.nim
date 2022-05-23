import strtabs, httpclient, json
import ../utility/[requests, types]
# -----
# media
# -----

proc mediaUploadInit*(twitter: TwitterAPI,
                      mediaType: string, totalBytes: string,
                      additionalParams: StringTableRef = nil): Response =
  ## `INIT` command for `media/upload.json` endpoint
  ##
  ## Docs: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-upload-init
  ##
  ## `mediaType` should be the MIME type for the data you are sending.
  ##
  ## The response returned from this will contain a media_id field that you
  ## need to provide to the other `mediaUpload` procs
  if additionalParams != nil:
    additionalParams["command"] = "INIT"
    additionalParams["media_type"] = mediaType
    additionalParams["total_bytes"] = totalBytes
    return post(twitter, "1.1/media/upload.json", additionalParams, true)
  else:
    return post(twitter, "1.1/media/upload.json", {"command": "INIT",
        "media_type": mediaType, "total_bytes": totalBytes}.newStringTable, true)


proc mediaUploadAppend*(twitter: TwitterAPI, mediaId: string, segmentId: string,
                        data: string, additionalParams: StringTableRef = nil): Response =
  ## `APPEND` command for `media/upload.json` endpoint
  ##
  ## Docs: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-upload-append
  ##
  ## Appends a chunk of data to a media upload, can accept base64 or binary
  if additionalParams != nil:
    additionalParams["command"] = "APPEND"
    additionalParams["media_id"] = mediaId
    additionalParams["segment_index"] = segmentId
    return post(twitter, "1.1/media/upload.json", additionalParams, true, data)
  else:
    return post(twitter, "1.1/media/upload.json", {"command": "APPEND",
        "media_id": mediaId, "segment_index": segmentId}.newStringTable, true, data)


proc mediaUploadStatus*(twitter: TwitterAPI, mediaId: string,
           additionalParams: StringTableRef = nil): Response =
  ## `STATUS` command for `media/upload.json` endpoint
  ##
  ## Docs: https://developer.twitter.com/en/docs/media/upload-media/api-reference/get-media-upload-status
  ##
  ## Used to check the processing status of an upload. This should only be run
  ## when mediaUploadFinalize_ returns a `processing_info` field otherwise a
  ## 404 will be generated
  if additionalParams != nil:
    additionalParams["command"] = "STATUS"
    additionalParams["media_id"] = mediaId
    return get(twitter, "1.1/media/upload.json", additionalParams, true)
  else:
    return get(twitter, "1.1/media/upload.json", {"command": "STATUS",
        "media_id": mediaId}.newStringTable, true)


proc mediaUploadFinalize*(twitter: TwitterAPI, mediaId: string,
           additionalParams: StringTableRef = nil): Response =
  ## `FINALIZE` command for `media/upload.json` endpoint
  ##
  ## Docs: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-upload-finalize
  ##
  ## Used to tell twitter your upload is finished. Will return a response
  ## with a `processing_info` field if further processing needs to be done use
  ## mediaUploadStatus_ to poll until completion.
  if additionalParams != nil:
    additionalParams["command"] = "FINALIZE"
    additionalParams["media_id"] = mediaId
    return post(twitter, "1.1/media/upload.json", additionalParams, true)
  else:
    return post(twitter, "1.1/media/upload.json", {"command": "FINALIZE",
        "media_id": mediaId}.newStringTable, true)


proc mediaMetadataCreate*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
  ## `media/metadata/create.json` endpoint
  ##
  ## Docs: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-metadata-create
  return post(twitter, "1.1/media/metadata/create.json", jsonBody, media = true)


proc mediaSubtitlesCreate*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
  ## `media/subtitles/create.json` endpoint
  ##
  ## Docs: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-subtitles-create
  return post(twitter, "1.1/media/subtitles/create.json", jsonBody, media = true)


proc mediaSubtitlesDelete*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
  ## `media/subtitles/delete.json` endpoint
  ##
  ## Docs: https://developer.twitter.com/en/docs/media/upload-media/api-reference/post-media-subtitles-create
  return post(twitter, "1.1/media/subtitles/delete.json", jsonBody, media = true)
