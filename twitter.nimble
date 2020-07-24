# Package
version = "1.0.0"
author = "snus-kin"
description = "A twitter API wrapper for Nim."
license = "MIT"

# Deps
requires: "nim >= 1.2.0"
requires: "uuids >= 0.1.10, hmac >= 0.1.9"

task test, "Runs tests":
  exec "nim c -r twitter.nim"
