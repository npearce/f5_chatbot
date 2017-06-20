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
  robot.respond /help iapps/i, (res) ->
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE is "Administrator"

      res.reply "help iapps - prints this help\n\n
          \t(show|list) available iapps - show the iApps available to install on iWorkflow.\n
          \t(show|list) installed iapps - show the iApps already installed on iWorkflow.\n
          \t(show|list) available service templates - show the service templates available\n
          \tto install on iWorkflow.\n
          \t(show|list) installed service templates - show the service templates already\n
          \tinstalled on iWorkflow.\n
          \tinstall iapps - Installs the AppSvcs_Integration iApp shipping/tested with\n
          \tf5_chatbot\n
          \tinstall service templates - Installs the service templates tested and shipping\n
          \twith the AppSvcs_Integration iApp.\n
          \tdelete iapps - deletes the iApps installed by @f5bot onto iWorkflow. NOTE: you\n
          \tmust delete the service templates referencing the iApps first.\n
          \tdelete service templates - deletes the service templates installed by @f5bot\n
          \tonto iWorkflow. NOTE: you must delete the service templates before deleting\n
          \tthe iApps.\n
          \n"
