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
  robot.respond /help users/i, (res) ->
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE is "Administrator"

      res.reply "help users - prints this help\n\n
          \t(show|list) users - show ALL the users available.\n
          \tcreate user <user_name> <password> - create a new iWorkflow Tenant user.\n
          \tadd <user> to tenant <tenant_name> - associate a user account to an\n
          \tiWorkflow Tenant\n
          \tdelete user <user_name> - delete an iWorkflow Tenant user account.\n
          \n"
