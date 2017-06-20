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

# Store the iWorkflow User Tenant to perform actions agains
  robot.respond /set tenant (.*)/i, (res) ->
    #Take the hostname/ipAddress from slack and 'set.brain.iwfHost
    IWF_TENANT = res.match[1]
    robot.brain.set 'IWF_TENANT', IWF_TENANT
    res.reply "Tenant set: #{IWF_TENANT}"
