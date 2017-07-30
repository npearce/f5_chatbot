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
  robot.respond /help pave/i, (res) ->
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE is "Administrator"

      res.reply "help pave - prints this help\n\n
          \tpave <JSON_Inputs> - Builds out a working iWorkflow provider config.\n
          \thelp pave example - Returns a template for 'paving'a config\n
          \tnuke <prefix> -  deletes the 'paved' config.\n"
