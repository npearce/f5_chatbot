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

  iapps = require "../iApps/iApps.json" # iApps and Service Templates available to install.
  DEBUG = false # [true|false] enable per '*.coffee' file.
  OPTIONS = rejectUnauthorized: false # ignore HTTPS reqiuest self-signed certs notices/errors

  robot.respond /(list|show) clouds/i, (res) ->

    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE is "Administrator"

      robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/connectors/local/", OPTIONS)
        .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
        .get() (err, resp, body) ->

          # Handle error
          if err
            res.reply "Encountered an error :( #{err}"
            return
          if resp.statusCode isnt 200
            if DEBUG
              console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
              console.log "body.code: #{body.code} body.message: #{body.message} "
            jp_body = JSON.parse body # so we can grab some JSON values
            res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
            return

          else
            try
              if DEBUG then console.log "DEBUG: body: #{body}"
              jp_body = JSON.parse body # so we can grab some JSON values

              if jp_body.items < 1
                res.reply "Sorry, no clouds... Wear sunscreen!"
                return

              else
                for i of jp_body.items
                  # Iterate through the devices.
                  CLOUD_NAME = jp_body.items[i].name
                  CLOUD_UUID = jp_body.items[i].connectorId
                  res.reply "Cloud #{i}: #{CLOUD_NAME} - #{CLOUD_UUID}"

            catch error
              res.send "Ran into an error parsing JSON :("
              return
