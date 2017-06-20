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

######## BEGIN (list|show) Discovered Devices ########
######## END (list|show) Discovered Devices ########

######## BEGIN (list|show) device <uuid> ########
######## END (list|show) device <uuid> ########

######## BEGIN Discover/Add Device ########
######## END Discover/Add Device ########

######## BEGIN Delete/Remove Device ########
######## END Delete/Remove Device ########

######## BEGIN Show Clouds ########
######## END Show Clouds ########

######## BEGIN Show Cloud <uuid> ########
######## END Show Cloud <uuid> ########

######## BEGIN Add Cloud ########
######## END Add Cloud ########

######## BEGIN Add Device to Cloud ########
######## END Add Device to Cloud ########

######## BEGIN Delete Cloud ########
######## END Delete Cloud ########

######## BEGIN (list|show) Available iApps & Service Templates ########
######## END (list|show) Available iApps & Service Templates ########

######## BEGIN (list|show) Installed iApps & Service Templates ########
######## END (list|show) Installed iApps & Service Templates ########

######## BEGIN Install iApps and Service Templates ########
######## BEGIN Install iApps and Service Templates ########

######## BEGIN iApp delete ########
######## END iApp delete ########
