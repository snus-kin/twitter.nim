import strtabs, httpclient, json
import ../utility/[requests, types]

# ------------------------
#    Bookmarks
# ------------------------
proc usersIdBookmarksTweetId*(twitter: TwitterAPI, id: string, tweetId: string, additionalParams: StringTableRef = nil): Response =
    ## `DELETE /2/users/:id/bookmarks/:tweet_id` endpoint
    return delete(twitter, "2/users/" & id & "/bookmarks/" & tweetId, additionalParams)

proc usersIdBookmarks*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/:id/bookmarks` endpoint
    return get(twitter, "2/users/" & id & "/bookmarks", additionalParams)

proc usersIdBookmarks*(twitter: TwitterAPI, id: string, jsonBody: JsonNode): Response =
    ## `POST /2/users/:id/bookmarks` endpoint
    return post(twitter, "2/users/" & id & "/bookmarks", jsonBody)

# ------------------------
#    COVID-19 stream
# ------------------------
# do I do these? they are uber niche
# NB these are labs endpoints but included in the V2 docs ? weird 
proc tweetsStreamCompliance*(twitter: TwitterAPI, partition: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /labs/1/tweets/stream/compliance` endpoint
    if additionalParams != nil:
        additionalParams["partition"] = partition
        return get(twitter, "labs/1/tweets/stream/compliance", additionalParams)
    else:
        return get(twitter, "labs/1/tweets/stream/compliance", {
            "partition": partition}.newStringTable)

proc tweetsStreamCovid19*(twitter: TwitterAPI, partition: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /labs/1/tweets/stream/covid19` endpoint
    if additionalParams != nil:
        additionalParams["partition"] = partition
        return get(twitter, "labs/1/tweets/stream/covid19", additionalParams)
    else:
        return get(twitter, "labs/1/tweets/stream/covid19", {
            "partition": partition}.newStringTable)

# ------------------------
#    Filtered stream
# ------------------------
proc tweetsSearchStream*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/tweets/search/stream` endpoint
    return get(twitter, "2/tweets/search/stream", additionalParams)

proc tweetsSearchStreamRules*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/tweets/search/stream/rules` endpoint
    return get(twitter, "2/tweets/search/stream/rules", additionalParams)

proc tweetsSearchStreamRules*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
    ## `POST /2/tweets/search/stream/rules` endpoint
    return post(twitter, "2/users/search/stream/rules", jsonBody)

# ------------------------
#    Hide replies
# ------------------------
proc tweetsIdHidden*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/:id/hidden` endpoint
    return get(twitter, "2/tweets/" & id & "/hidden", additionalParams)

# ------------------------
#    Likes
# ------------------------
proc usersIdLikesTweetId*(twitter: TwitterAPI, id: string, tweetId: string, additionalParams: StringTableRef = nil): Response =
    ## `DELETE /2/users/:id/likes/:tweet_id` endpoint
    return delete(twitter, "2/users/" & id & "/likes/" & tweetId, additionalParams)

proc tweetsIdLikingUsers*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/tweets/:id/liking_users` endpoint
    return get(twitter, "2/tweets/" & id & "/liking_users", additionalParams)

proc tweetsIdLikedTweets*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/:id/liked_tweets` endpoint
    return get(twitter, "2/tweets/" & id & "/liked_tweets", additionalParams)

proc usersIdLikes*(twitter: TwitterAPI, id: string, jsonBody: JsonNode): Response =
    ## `POST /2/users/:id/likes` endpoint
    return post(twitter, "2/users/" & id & "/likes", jsonBody)

# ------------------------
#    Manage Tweets
# ------------------------
proc tweetsDelete*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `DELETE /2/tweets/:id` endpoint
    return delete(twitter, "2/tweets/" & id, additionalParams)

proc tweets*(twitter: TwitterAPI, jsonBody: JsonNode): Response =
    ## `POST /2/tweets` endpoint
    return post(twitter, "2/tweets", jsonBody)

# ------------------------
#    Quote Tweets
# ------------------------
proc tweetsIdQuoteTweets*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `get /2/tweets/:id/quote_tweets` endpoint
    return get(twitter, "2/tweets/" & id & "/quote_tweets", additionalParams)

# ------------------------
#    Retweets
# ------------------------
proc usersIdRetweetsSourceTweetId*(twitter: TwitterAPI, id: string, sourceTweetId: string, additionalParams: StringTableRef = nil): Response =
    ## `DELETE /2/users/:id/retweets/:source_tweet_id` endpoint
    return delete(twitter, "2/users/" & id & "/retweets/" & sourceTweetId, additionalParams)

proc tweetsIdRetweetedBy*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/tweets/:id/retweeted_by` endpoint
    return get(twitter, "2/tweets/" & id & "/retweeted_by", additionalParams)

proc usersIdRetweets*(twitter: TwitterAPI, id: string, jsonBody: JsonNode): Response =
    ## `POST /2/users/:id/retweets` endpoint
    return post(twitter, "2/users/" & id & "/retweets", jsonBody)

# ------------------------
#    Search Tweets
# ------------------------
proc tweetsSearchAll*(twitter: TwitterAPI, query: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/tweets/search/all` endpoint
    if additionalParams != nil:
        additionalParams["query"] = query
        return get(twitter, "2/tweets/search/all", additionalParams)
    else:
        return get(twitter, "2/tweets/search/all", {
            "query": query}.newStringTable)

proc tweetsSearchRecent*(twitter: TwitterAPI, query: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/tweets/search/recent` endpoint
    if additionalParams != nil:
        additionalParams["query"] = query
        return get(twitter, "2/tweets/search/recent", additionalParams)
    else:
        return get(twitter, "2/tweets/search/recent", {
            "query": query}.newStringTable)

# ------------------------
#    Timelines
# ------------------------
proc usersIdMentions*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/:id/mentions` endpoint
    return get(twitter, "2/users/" & id & "/mentions", additionalParams)

proc usersIdTimelinesReverseChronological*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/:id/timelines/reverse_chronological` endpoint
    return get(twitter, "2/users/" & id & "/timelines/reverse_chronological", additionalParams)

proc usersIdTweets*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/users/:id/tweets` endpoint
    return get(twitter, "2/users/" & id & "/tweets", additionalParams)

# ------------------------
#    Tweet counts
# ------------------------
proc tweetsCountsAll*(twitter: TwitterAPI, query: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/tweets/counts/all` endpoint
    if additionalParams != nil:
        additionalParams["query"] = query
        return get(twitter, "2/tweets/counts/all", additionalParams)
    else:
        return get(twitter, "2/tweets/counts/all", {
            "query": query}.newStringTable)

proc tweetsCountsRecent*(twitter: TwitterAPI, query: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/tweets/counts/recent` endpoint
    if additionalParams != nil:
        additionalParams["query"] = query
        return get(twitter, "2/tweets/counts/recent", additionalParams)
    else:
        return get(twitter, "2/tweets/counts/recent", {
            "query": query}.newStringTable)

# ------------------------
#    Tweets lookup
# ------------------------
proc tweets*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/tweets` endpoint
    if additionalParams != nil:
        additionalParams["id"] = id
        return get(twitter, "2/tweets", additionalParams)
    else:
        return get(twitter, "2/tweets", {
            "id": id}.newStringTable)

proc tweetsId*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/tweets/:id` endpoint
    return get(twitter, "2/tweets/" & id, additionalParams)

# ------------------------
#    Volume streams
# ------------------------
proc tweetsSampleStream*(twitter: TwitterAPI, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/tweets/sample/stream` endpoint
    return get(twitter, "2/tweets/sample/stream", additionalParams)