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
  robot.respond /help clouds/i, (res) ->
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE is "Administrator"

      res.reply "help clouds - prints this help\n\n
          \t(show|list) clouds - show ALL the clouds available.\n
          \tcreate cloud <name> <description> - create a new 'local'(BIG-IP) cloud.\n
          \tadd device <device_uuid> to cloud <cloud_uuid> - add a 'known'(discovered) BIG-IP to\n
          \tthe specified 'local' Cloud Connector\n
          \tadd cloud <cloud_uuid> to tenant <tenant_name> - add the BIG-IP cloud to a tenant.\n
          \tdelete cloud <cloud_uuid> - delete a 'local'(BIG-IP) Cloud Connector\n
          \n"
