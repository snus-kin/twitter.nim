import strtabs, httpclient, json
import ../utility/[requests, types]

# TODO Compliance -- Test

proc complianceJobs*(twitter: TwitterAPI, `type`: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/compliance/jobs` endpoint
    
    # TODO POST and GET in one method what's the difference here?
    # POST sends a new compliance job to the server, GET requests a list of recent ones... why are these the same endpoint
    if additionalParams != nil:
        additionalParams["type"] = `type`
        return get(twitter, "2/compliance/jobs", additionalParams)
    else:
        return get(twitter, "2/compliance/jobs", {"type": `type`}.newStringTable)

proc complianceJobs*(twitter: TwitterAPI, `type`: string, jsonBody: JsonNode) : Response =
    ## `POST /2/compliance/jobs` endpoint
    return post(twitter, "2/compliance/jobs", jsonBody)

proc complianceJobsId*(twitter: TwitterAPI, id: string, additionalParams: StringTableRef = nil): Response =
    ## `GET /2/compliance/jobs/:id` endpoint
    # inline ID type stuff needs to work better I think? 
    return get(twitter, "2/compliance/jobs/" & id, additionalParams)