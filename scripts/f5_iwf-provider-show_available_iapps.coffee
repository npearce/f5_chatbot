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

  robot.respond /(list|show) available iapps/i, (res) ->

    IWF_ROLE = robot.brain.get('IWF_ROLE')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')

    if IWF_ROLE is "Administrator"

      # list the iApps available to install.
      res.reply "iApp: #{iapps.iApp_file}"
