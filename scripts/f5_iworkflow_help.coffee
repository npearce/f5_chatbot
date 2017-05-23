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

  robot.respond /help/i, (res) ->
    #Respond with all the variables (bot not the password)
    res.reply "help - prints this help\n \
    help set address - \n \
    help get token - Retrieve an auth token from iWokflow so we don't need to stor your password\n \
    help list tenants - Returns a list of Tenant assigments associate with the authenticated user.\n \
    help set tenant - Specify which of the users associated tenants you with to work with. A user can have multiple Tenant assignments.\n \
    \n\nYou MUST set an address and get an iWorkflow Auth-token before executing the following commands:\n \
    help list tenants - Show the tenants for which the iWorkflow user has been assigned.\n \
    help (list|show) services"

  robot.respond /help set address/i, (res) ->
    res.reply "Set the F5 iWorkflow management ip address that you wish to communicate with.\n \
    Usage:\n set address <x.x.x.x>"

######## END Help ########
