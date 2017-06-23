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

  # Example function with inputs
  robot.respond /(list|show) config/i, (res) ->

    # Respond with all the variables (bot not the password)
    IWF_ADDR = robot.brain.get 'IWF_ADDR'
    IWF_USERNAME = robot.brain.get 'IWF_USERNAME'
    IWF_TOKEN = robot.brain.get 'IWF_TOKEN'
    IWF_TENANT = robot.brain.get 'IWF_TENANT'
    IWF_ROLE = robot.brain.get 'IWF_ROLE'
    BOT_ADAPTER = robot.brain.get 'BOT_ADAPTER'

    res.reply "iWorkflow Address: #{IWF_ADDR}\niWorkflow Username: #{IWF_USERNAME}\n
    iWorkflow Role (Admin/Tenant): #{IWF_ROLE}\nAuth Token: #{IWF_TOKEN}\n
    iWorkflow Tenant: #{IWF_TENANT}\nhubot adapter: #{BOT_ADAPTER}\n"
