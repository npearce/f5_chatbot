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
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE is "Administrator"

    #Respond with all the variables (bot not the password)
      res.reply "help - prints this help\n\n
        Welecome to f5_chatbot help.\n
          Common Commands (require for all operations):\n
          \n
          \t(show|list) config - show what operating settings have been defined.\n
          \tset address <ip_address> - specifies the iWorkflow management IP address you\n
          \twish to work with (only 1 at a time).\n
          \tget token <username> <password> - Retrieve an Auth Token from iWokflow, so we\n
          \tdon't need to store your password.\n
          \tset tenant <tenant_name> - specifies which iWorkflow tenant the following\n
          \tcommands will apply to. Required for users associated with multiple tennats.\n
          \n
          For iWorkflow Provider commands:\n
          \thelp devices\n
          \thelp iapps\n
          \thelp clouds\n
          \thelp users\n"
