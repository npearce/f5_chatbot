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

  # Instructions for converting your JSON data into a single encoded string, to play nice with hubot.
  robot.respond /encode json/i, (res) ->
    res.reply "Go here:\n https://www.freeformatter.com/url-encoder.html \nPaste your JSON into the text box, click 'encode'. Use this encoded string with the 'deploy service <encoded_JSON_Input>' command."
