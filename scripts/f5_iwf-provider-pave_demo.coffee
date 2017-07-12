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

Promise = require('promise')

module.exports = (robot) ->

  iapps = require "../iApps/iApps.json" # iApps and Service Templates available to install.
  DEBUG = false # [true|false] enable per '*.coffee' file.
  OPTIONS = rejectUnauthorized: false # ignore HTTPS reqiuest self-signed certs notices/errors

  robot.respond /pave demo (.*)/i, (res) ->

    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')
    DEMO_PREFIX = res.match[1]

    if IWF_ROLE is "Administrator"


# Install App Svcs iApp

      try
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

      catch error
        res.send "iApp install failed"


# Install Service Templates

      try
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

      catch error
        res.send "Service Template installs failed"

# Create User

      try
        IWF_NEW_USERNAME = "#{DEMO_PREFIX}_user"
        IWF_NEW_USER_PASS = "password"

        post_data = JSON.stringify({
          name: IWF_NEW_USERNAME,
          displayName: IWF_NEW_USERNAME,
          password: IWF_NEW_USER_PASS
        })

        if DEBUG then console.log "post_data: #{post_data}"

  # /mgmt/shared/authz/users

        # Perform the POST to authn/login
        robot.http("https://#{IWF_ADDR}/mgmt/shared/authz/users/", OPTIONS)
          .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
          .post(post_data) (err, resp, body) ->

            # Handle error
            if err
              res.reply "Encountered an error :( #{err}"
              return

            if resp.statusCode isnt 200
              if DEBUG
                console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
                console.log "body.code: #{body.code} body.message: #{body.message} "
              jp_body = JSON.parse body
              res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
              return
            else
              res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"
              if DEBUG then console.log "body: #{body}"
      catch error
        res.reply "Create user failed."


# Create Cloud

# Add Device to Cloud

# Create Tenant

# Add Cloud to Tenant
