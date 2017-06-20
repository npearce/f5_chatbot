# Description:
#   Simple robot to provide communication with F5 iControl declarative interfaces via the F5 iWorkflow platform
#   Maintainer:
#   @npearce
#   http://github/com/npearce
#
# Notes:
#   Tested against iWorkflow v2.2.0 on AWS
#   Running on Docker container/alpine linux
#

module.exports = (robot) ->

  iapps = require "../iApps/iApps.json" # iApps and Service Templates available to install.
  DEBUG = false # [true|false] enable per '*.coffee' file.
  OPTIONS = rejectUnauthorized: false # ignore HTTPS reqiuest self-signed certs notices/errors


######## BEGIN Show Services and VIP/Pools ########
######## END Show Services and VIP/Pools ########

######## BEGIN Show Service Templates ########
######## END Show Service Templates ########

######## BEGIN Show Cloud Connector UUID ########
######## END Show Cloud Connector UUID ########

######## BEGIN Show Service Template Example ########
######## END Show Service Template Example ########

######## BEGIN Deploy Service ########
######## END Deploy Service ########

######## BEGIN Delete Service ########
######## END Delete Service ########

######## BEGIN Encode JSON ########
######## END Encode JSON ########
