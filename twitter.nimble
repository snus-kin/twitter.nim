# Package
version = "2.0.0"
author = "snus-kin"
description = "A twitter API wrapper for Nim."
srcDir = "src"
license = "MIT"

# Deps
requires: "nim >= 1.2.0"
requires: "uuids >= 0.1.10, hmac >= 0.1.9"

task docs, "Generate documentation":
  exec "nim doc --git.url:https://github.com/snus-kin/twitter.nim --git.commit:main --project --outdir:docs src/twitter.nim"
