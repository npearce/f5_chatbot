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

    if !IWF_ROLE?
    #Respond with all the variables (bot not the password)
      res.reply "help - prints this help\n\n
        Use 'get token <username> <password>' so we know which role we're helping, kthxbye!"

######## END Help ########
