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
    res.reply "help - prints this help\n\n
For more detailed help, try 'help <command>'.\n\n
env - show what settings have been set.\n
set address - specifies the management IP addres you are going to be owkring with.\n
get token - Retrieve an auth token from iWokflow so we don't need to stor your password\n
list tenants - Returns a list of Tenant assigments associate with the authenticated user.\n
set tenant - Specify which of the users associated tenants you with to work with. A user can have multiple Tenant assignments.\n
\n\nNOTE: The following commands require 'set address' and 'get token' before executing:\n\n
list tenants - Show the tenants for which the iWorkflow user has been assigned.\n
list services"

  robot.respond /help set address/i, (res) ->
    res.reply "Set the F5 iWorkflow management ip address that you wish to communicate with.\n
Usage:\n set address <x.x.x.x>"

######## END Help ########
