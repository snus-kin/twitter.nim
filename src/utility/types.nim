type
  ConsumerToken* = object
    consumerKey*: string
    consumerSecret*: string

  TwitterAPI* = object
    consumerToken*: ConsumerToken
    bearerToken*: string
    accessToken*: string
    accessTokenSecret*: string
    username*: string
    password*: string

proc newConsumerToken*(consumerKey, consumerSecret: string): ConsumerToken =
  return ConsumerToken(consumerKey: consumerKey,
                       consumerSecret: consumerSecret)


proc newTwitterAPI*(consumerToken: ConsumerToken, accessToken,
    accessTokenSecret: string): TwitterAPI =
  return TwitterAPI(consumerToken: consumerToken,
                    bearerToken: "",
                    accessToken: accessToken,
                    accessTokenSecret: accessTokenSecret)


proc newTwitterAPI*(bearerToken: string): TwitterAPI =
  return TwitterAPI(bearerToken: bearerToken)


proc newTwitterAPI*(consumerKey, consumerSecret,
                    accessToken, accessTokenSecret: string): TwitterAPI =
  let consumerToken: ConsumerToken = ConsumerToken(consumerKey: consumerKey,
                                                   consumerSecret: consumerSecret)
  return TwitterAPI(consumerToken: consumerToken,
                    bearerToken: "",
                    accessToken: accessToken,
                    accessTokenSecret: accessTokenSecret)
