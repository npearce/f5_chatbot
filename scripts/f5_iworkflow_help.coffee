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

  robot.respond /help\b/i, (res) ->
    #Respond with all the variables (bot not the password)
    res.reply "help - prints this help\n\n
For more detailed help, try 'help <command>'.\n\n

Common Commands:
  (show|list) config - show what settings have been set.\n
  set address - specifies the management IP addres you are going to be owkring with.\n
  set token - Retrieve an auth token from iWokflow so we don't need to stor your password\n


Administrative Commands:
  (show|list) available iapps
  (show|list) installed iapps
  install iapps <username> <password> - installs AppVcs_Integration iApp and Service Templates onto iWorkflow

Tenant Commands:
  (show|list) tenants - Returns a list of Tenant assigments associate with the authenticated user.\n
  set tenant - Specify which of the users associated tenants you with to work with. A user can have multiple Tenant assignments.\n
  \n\nNOTE: The following commands require 'set address' and 'get token' before executing:\n\n
  (show|list) services"

  robot.respond /help show config/i, (res) ->
    res.reply "The defauls for the running config are 'null'. Setting these
    environment variables (username/password/token, Managmenet IP Address, etc)
    enables communication with the iWorkflow platform. Minimum requirements for
    both Administrative and Tenant commands are:
      set addresss <ip_address>
      get token <username> <password>"


  robot.respond /help set address/i, (res) ->

  robot.respond /help set address/i, (res) ->



  robot.respond /help set address/i, (res) ->
    res.reply "Set the F5 iWorkflow management ip address that you wish to communicate with.\n
Usage:\n set address <x.x.x.x>"

  robot.respond /help install iapp/i, (res) ->
    res.reply "Set the F5 iWorkflow management ip address that you wish to communicate with.\n
Usage:\n set address <x.x.x.x>"



######## END Help ########
