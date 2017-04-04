# Description:
#   Gag script for live demos
#
# Notes:
#   Tested against iWorkflow v2.2.0
#


module.exports = (robot) ->

  robot.hear /pete/i, (res) ->
    ## implement delay of 2 minutes here...
    res.send "I've got his cell password... Thanks for distracting him!! Beers are on Pete tonight!!!"
