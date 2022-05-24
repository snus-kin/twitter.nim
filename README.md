# twitter ![.github/workflows/tests.yml](https://github.com/snus-kin/twitter.nim/workflows/.github/workflows/tests.yml/badge.svg?branch=master) ![](https://img.shields.io/endpoint?url=https%3A%2F%2Ftwbadges.glitch.me%2Fbadges%2Fstandard) ![](https://img.shields.io/endpoint?url=https%3A%2F%2Ftwbadges.glitch.me%2Fbadges%2Fv2)

Low-level Twitter API wrapper library for Nim.

[Documentation](https://snus-kin.github.io/twitter.nim/twitter.html)

## Installation

From Nimble:

```console
$ nimble install twitter
```

From GitHub:

```console
$ git clone git://github.com/snus-kin/twitter.nim
$ cd twitter.nim && nimble install
```

## Usage

To use the library, `import twitter` and compile with `-d:ssl`

Note: only the free endpoints are wrapped. All mentioned in the
[API Reference Index](https://developer.twitter.com/en/docs/api-reference-index)
have been implemented, please open an issue if you find one that isn't in this
reference or if anything new's been added I haven't seen yet.

## Example

```nim
import twitter, json, strtabs

when isMainModule:
  var parsed = parseFile("credential.json")

  var consumerToken = newConsumerToken(parsed["ConsumerKey"].str,
                                       parsed["ConsumerSecret"].str)
  var twitterAPI = newTwitterAPI(consumerToken,
                                 parsed["AccessToken"].str,
                                 parsed["AccessTokenSecret"].str)

  # Simply get.
  var resp = twitterAPI.get("1.1/account/verify_credentials.json")
  echo resp.status

  # ditto, but selected by screen name.
  resp = twitter.v1.usersLookup(twitterAPI, "sn_fk_n")
  echo pretty parseJson(resp.body)

  # Using proc corresponding twitter REST APIs.
  resp = twitter.v1.statusesUserTimeline(twitterAPI)
  echo pretty parseJson(resp.body)

  # Using `callAPI` template.
  let status = {"status": "hello world"}.newStringTable
  resp = twitterAPI.callAPI(twitter.v1.statusesUpdate, status)
  echo pretty parseJson(resp.body)
```

See also: `examples/` for more extensive examples on the library's use.
