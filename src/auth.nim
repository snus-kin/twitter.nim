import strtabs, httpclient
import utility/[requests, types]
# --------------
# authentication
# --------------


proc oauthAuthenticate*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `oauth/authenticate` endpoint
  return get(twitter, "oauth/authenticate", additionalParams)


proc oauthAuthorize*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `oauth/authorize` endpoint
  return get(twitter, "oauth/authorize", additionalParams)


proc oauthAccessToken*(twitter: TwitterAPI, oauthToken: string,
    oauthVerifier: string, additionalParams: StringTableRef = nil): Response =
  ## `oauth/access_token` endpoint
  if additionalParams != nil:
    additionalParams["oauth_token"] = oauthToken
    additionalParams["oauth_verifier"] = oauthVerifier
    return post(twitter, "oauth/access_token", additionalParams)
  else:
    return post(twitter, "oauth/access_token", {"oauth_token": oauthToken,
        "oauth_verifier": oauthVerifier}.newStringTable)


proc oauthInvalidateToken*(twitter: TwitterAPI,
    additionalParams: StringTableRef = nil): Response =
  ## `oauth/invalidate_token` endpoint
  return post(twitter, "oauth/invalidate_token", additionalParams)


proc oauthRequestToken*(twitter: TwitterAPI, oauthCallback: string,
    additionalParams: StringTableRef = nil): Response =
  ## `oauth/request_token` endpoint
  if additionalParams != nil:
    additionalParams["oauth_callback"] = oauthCallback
    return post(twitter, "oauth/request_token", additionalParams)
  else:
    return post(twitter, "oauth/request_token", {
        "oauth_callback": oauthCallback}.newStringTable)


proc oauth2InvalidateToken*(twitter: TwitterAPI, accessToken: string,
    additionalParams: StringTableRef = nil): Response =
  ## `oauth2/invalidate_token` endpoint
  if additionalParams != nil:
    additionalParams["access_token"] = accessToken
    return post(twitter, "oauth2/invalidate_token", additionalParams)
  else:
    return post(twitter, "oauth2/invalidate_token", {
        "access_token": accessToken}.newStringTable)


proc oauth2Token*(twitter: TwitterAPI, grantType: string,
    additionalParams: StringTableRef = nil): Response =
  ## `oauth2/token` endpoint
  if additionalParams != nil:
    additionalParams["grant_type"] = grantType
    return post(twitter, "oauth2/token", additionalParams)
  else:
    return post(twitter, "oauth2/token", {
        "grant_type": grantType}.newStringTable)

proc v2oauth2Token*(twitter: TwitterAPI, grantType: string,
    additionalParams: StringTableRef = nil): Response =
  ## `oauth2/token` endpoint, I'm not sure how this is different to the previous endpoint, as of now I have no clarification.
  if additionalParams != nil:
    additionalParams["grant_type"] = grantType
    return post(twitter, "v2/oauth2/token", additionalParams)
  else:
    return post(twitter, "v2/oauth2/token", {
        "grant_type": grantType}.newStringTable)
