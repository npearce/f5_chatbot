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

  robot.respond /delete service templates/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE isnt "Administrator"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Administrator' roles."
      return

    else
      for i of iapps.iApp_service_templates
          long_name = iapps.iApp_service_templates[i]
          short_name = long_name.split "_v2.0.004.json"  # drop the extension

          # Perform the deletion (DELETE to /iapps)
          robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/provider/templates/iapp/#{short_name[0]}", OPTIONS)
            .headers("Content-Type": "application/json", 'X-F5-Auth-Token': IWF_TOKEN)
            .delete() (err, resp, body) ->

              if err
                res.reply "Encountered an error :( #{err}"
                return

              if resp.statusCode isnt 200
                res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
                if DEBUG then console.log "Something went wrong :( BODY: #{body}"
                return

              else
                try
                  jp_body = JSON.parse body
                  res.reply "Service Template #{jp_body.templateName} deleted!"

                catch error
                 res.send "Ran into an error parsing response JSON :("
                 return
