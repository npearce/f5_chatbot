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

  robot.respond /delete device (.*)/i, (res) ->

    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')
    DEVICE_UUID = res.match[1]

    if IWF_ROLE isnt "Administrator"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Administrator' roles."
      return

    robot.http("https://#{IWF_ADDR}/mgmt/shared/resolver/device-groups/cm-cloud-managed-devices/devices/#{DEVICE_UUID}", OPTIONS)
      .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
      .delete() (err, resp, body) ->

        # Handle error
        if err
          res.reply "Encountered an error :( #{err}"
          return

        if resp.statusCode isnt 200
          if DEBUG
            console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
            console.log "body.code: #{body.code} body.message: #{body.message} "
            console.log "body: #{body}"
          try
            jp_body = JSON.parse body
            res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
            return
          catch error
            res.send "Ran into an error parsing JSON :("
            return
        else
          res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"
          if DEBUG then console.log "body: #{body}"
