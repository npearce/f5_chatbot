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

  robot.respond /add device (.*) to cloud (.*)/i, (res) ->

    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')
    DEVICE_UUID = res.match[1]
    CLOUD_UUID = res.match[2]

    if IWF_ROLE is "Administrator"

      res.reply "Adding device \'#{res.match[1]}\' to Cloud: #{res.match[2]}"

# TODO edit a device list.
      # Add device to local (BIG-IP) cloud connector
      patch_cloud = JSON.stringify({
      	"deviceReferences": [
      	  {
      	    "link": "https://localhost/mgmt/shared/resolver/device-groups/cm-cloud-managed-devices/devices/#{DEVICE_UUID}"
      	  }
      	]
      })

      if DEBUG then console.log "patch_cloud: =#{patch_cloud}"

      robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/connectors/local/#{CLOUD_UUID}", OPTIONS)
        .headers('X-F5-Auth-Token': IWF_TOKEN, Accept: 'application/json')
        .patch(patch_cloud) (err, resp, body) ->

          # Handle error
          if err
            res.reply "Encountered an error :( #{err}"
            return
          if resp.statusCode isnt 200
            res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
            return

          else
            if DEBUG then console.log "patch worked: #{resp.statusCode} - #{body}"
            try
              jp_body = JSON.parse body
              res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"

            catch error
             res.send "Ran into an error parsing JSON :("
             return
