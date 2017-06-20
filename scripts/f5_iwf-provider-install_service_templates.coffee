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

# Install the available Service Templates onto iWorkflow
  robot.respond /install service templates/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE isnt "Administrator"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Administrator' roles."
      return

    else
      res.reply "Installing Services Tempaltes on: #{IWF_ADDR}"

      for i of iapps.iApp_service_templates
        # the Service_Templates we are going to install
        service_file_path = "#{iapps.iApp_loc}service-templates/#{iapps.iApp_service_templates[i]}"

        # Contruct JSON for the POST to authn/login
        post_data = require "#{service_file_path}"
        try
          js_post_data = JSON.stringify post_data
        catch error
          res.send "Ran into an error parsing Service Template JSON :("
          return

        # Perform the deletion (DELETE to /iapps)
        robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/provider/templates/iapp", OPTIONS)
          .headers("Content-Type": "application/json", 'X-F5-Auth-Token': IWF_TOKEN)
          .post(js_post_data) (err, resp, body) ->

            # Handle error
            if err
              res.reply "Encountered an error :( #{err}"
              return

            jp_body = JSON.parse body

            if resp.statusCode isnt 200
              res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage} - #{jp_body.message}"
              if DEBUG then console.log "Something went wrong :( BODY: #{body}"
              return
            else
              try
                res.reply "Service Template #{jp_body.templateName} - Installed - #{resp.statusCode} - #{resp.statusMessage}"

              catch error
               res.send "Ran into an error parsing response JSON :("
               return
