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

# A quick 'hear'ing test
  robot.hear /life/i, (res) ->
    res.send "42"

  robot.respond /(ping|hodor)/i, (res) ->
    res.send "hodor"
