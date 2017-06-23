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
  robot.respond /format json/i, (res) ->

    if BOT_ADAPTER is "shell"
      res.reply "The 'shell' adapter requires eiher 'single-line JSON' or\n
      'URL encoded' format.\n
      \n
      To re-format the 'example' input to 'single-line JSON (no carriage returns)',\n
      go here:\n
      \thttps://www.freeformatter.com/json-formatter.html\n
      Paste the input JSON into the text box, change the 'indentation level:' to\n
      'Compact (1-line)', and click 'Format JSON'\n
      \n
      Or,\n
      \n
      To re-format the 'example' input to URLencoded, go here:\n
      \thttps://www.freeformatter.com/url-encoder.html \n
      \tPaste JSON into the text box, and click 'encode'. Use the encoded string\n
      with 'deploy service <JSON_Input>' command."

    if BOT_ADAPTER is "slack"
      res.reply "You are using the 'slack adapter' which requires no encoding/formatting\n
      at all.\n
      \n
      The 'shell' adapter requires eiher 'single-line JSON' or 'URL encoded' format.\n"
