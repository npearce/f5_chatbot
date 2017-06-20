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

# Install the available iApps onto iWorkflow
  robot.respond /install iapps/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE isnt "Administrator"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Administrator' roles."
      return

    else
      # the iApp we are going to install
      iapp_file_path = "#{iapps.iApp_loc}import-json/#{iapps.iApp_file}"

      # Contruct JSON for the POST to authn/login
      post_data = require "#{iapp_file_path}"

      try
        js_post_data = JSON.stringify post_data
      catch error
        res.send "Ran into an error parsing iApp JSON :("
        return

      # Get iWorkflow address
      IWF_ADDR = robot.brain.get('IWF_ADDR')

      # Perform the installation (POST to /iapps)
      robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/templates/iapp", OPTIONS)
        .headers("Content-Type": "application/json", 'X-F5-Auth-Token': IWF_TOKEN)
        .post(js_post_data) (err, resp, body) ->

          # Handle error
          if err
            res.reply "Encountered an error :( #{err}"
            return

          if resp.statusCode isnt 200
            res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
            if DEBUG then console.log "Something went wrong :( BODY: #{body}"
            return
          else
            try
              res.reply resp.statusCode + " - " + resp.statusMessage
              jp_body = JSON.parse body
              res.reply "iApp #{jp_body.name} - Installed - #{resp.statusCode} - #{resp.statusMessage}"

            catch error
             res.send "Ran into an error parsing response JSON :("
             return
