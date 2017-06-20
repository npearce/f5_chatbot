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


  robot.respond /(list|show) device (.*)/i, (res) ->

    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')
    DEVICE_UUID = res.match[2]

    if IWF_ROLE is "Administrator"

      res.reply "Reading device #{DEVICE_UUID} details on: #{IWF_ADDR}\n...\n"

      robot.http("https://#{IWF_ADDR}/mgmt/shared/resolver/device-groups/cm-cloud-managed-devices/devices/#{DEVICE_UUID}", OPTIONS)
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
              if DEBUG then console.log "body: #{body}"
              jp_body = JSON.parse body # so we can grab some JSON values
              js_body = JSON.stringify(jp_body, ' ', '\t') # so we can pretty print the JSON

              # Iterate through the devices.
              DEVICE_HOSTNAME = jp_body.hostname
              DEVICE_UUID = jp_body.uuid
              DEVICE_VERSION = jp_body.version
              res.reply "Device #{DEVICE_HOSTNAME} - #{DEVICE_VERSION} - #{DEVICE_UUID}:\n\n#{js_body}"
            catch error
              res.send "Ran into an error parsing JSON :("
              return
