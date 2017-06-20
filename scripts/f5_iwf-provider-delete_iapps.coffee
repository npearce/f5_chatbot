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

  robot.respond /delete iapps/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE isnt "Administrator"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Administrator' roles."
      return

    else
      # Perform the deletion (DELETE to /iapps)
      robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/templates/iapp/#{iapps.iApp_name}", OPTIONS)
        .headers("Content-Type": "application/json", 'X-F5-Auth-Token': IWF_TOKEN)
        .delete() (err, resp, body) ->

          if err
            res.reply "Encountered an error :( #{err}"
            return

          if resp.statusCode is 200
            res.reply "iApp #{iapps.iApp_name} deleted!"
          else if resp.statusCode is 400
            try
              jp_body = JSON.parse body
              res.reply "Cannot delete:\nCode: #{resp.statusCode},\nMessage: #{jp_body.message}.\nTry \'delete service templates\' first."
              return

            catch error
             res.send "Ran into an error parsing JSON :("
             return

          else
            res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
            if DEBUG then console.log "Something went wrong :( BODY: #{body}"
            return
