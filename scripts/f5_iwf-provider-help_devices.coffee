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
  robot.respond /help devices/i, (res) ->
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE is "Administrator"

      res.reply "help devices - prints this help\n\n
          \t(list|show) devices - show the devices (BIG-IP and iWorkflow) in the iWorkflow\n
          \tinventory.\n
          \tdiscover device <ip_address> <big-ip_user> <big-ip_password> <(true|false)> - Instructs\n
          \tiWorkflow to discover a new BIG-IP device.\n
          \tRequires:\n
          \t\t1) Mgmt IP Address of the BIG-IP\n
          \t\t2) a BIG-IP Administrator role username\n
          \t\t3) Password for the BIG-IP Administrator role\n
          \t\t4) auto-update iControl REST Framework <true|false>\n
          \tdelete device <device_uuid> - delete the discovered device from the iWorkflow\n
          \tinventory. NOTE: device cannot be in use by tenants.\n
          \n"
