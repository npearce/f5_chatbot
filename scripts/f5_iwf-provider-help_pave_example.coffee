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

######## BEGIN Help ########
  robot.respond /help pave example/i, (res) ->

    # It fetches the data from the path
    example_data = require "../iApps/provider_pave_example.json"
    # It pretty prints the JSON, or it get the hose again...
    js_example_data = JSON.stringify(example_data, ' ', '\t')

    res.reply "pave example:\n#{js_example_data}"
