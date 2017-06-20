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
  robot.respond /set address (.*)/i, (res) ->

    #Take the hostname/ipAddress from slack and 'set.brain.iwfHost
    IWF_ADDR = res.match[1]
    OPTIONS = rejectUnauthorized: false # ignore HTTPS reqiuest self-signed certs notices/errors

    robot.brain.set 'IWF_ADDR', IWF_ADDR

    # Testing connectivity
    robot.http("https://#{IWF_ADDR}/mgmt/toc", OPTIONS)
      .headers(Accept: 'application/json')
      .get() (err, resp, body) ->

        if err
          res.reply "Encountered an error :( #{err}"
          return

        if resp.statusCode isnt 200
          res.reply "Something went wrong :(  #{resp.statusCode} - #{resp.statusMessage}"
          return

        else
          # Respond with the status
          res.reply "Response from #{IWF_ADDR}:  #{resp.statusCode} - #{resp.statusMessage}"
