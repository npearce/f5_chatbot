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

Common Commands (require for all operations):
  (show|list) config - show what settings have been set.\n
  set address <ip_address> - specifies the management IP addres you are going to be working with.\n
  get token <username> <password> - Retrieve an auth token from iWokflow so we don't need to store your password\n\n\n
  set tenant <tenant_name> - specifies which tenant the following commands will work against. Required for users associated with multiple tennats.\n\n

Administrative Commands:
  (show|list) available iapps - show the iApps available to install on iWorkflow.
  (show|list) installed iapps - show the iApps already installed on iWorkflow.
  (show|list) available service templates - show the service templates available to install on iWorkflow.
  (show|list) installed service templates - show the service templates already installed on iWorkflow.\n\n

  WARNING: The following commands requires 'admin' credentials.
  install iapps - Installs the AppSvcs_Integration iApp shipping/tested with f5_chatbot
  install service templates - Installs the service templates tested and shipping with the AppSvcs_Integration iApp.\n\n

Tenant Commands:
  \n\nNOTE: The following commands require 'set tenant' before executing:\n\n
  (show|list) tenants - Returns a list of Tenant assigments associate with the authenticated user.\n
  set tenant <tenant_name> - Specify which of the users associated tenants you with to work with. A user can have multiple Tenant assignments.\n
  (show|list) deployed services
  (show|list) services templates
  (show|list) service template example <service_template_name> - get an example of a
  deploy service <JSON_Input> - deploys a service to a BIG-IP device. Requires Service Template input."


## More detailed help

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
