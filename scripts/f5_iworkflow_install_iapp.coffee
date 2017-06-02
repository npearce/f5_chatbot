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

iapps = require "../iApps/iApps.json"

module.exports = (robot) ->

######## BEGIN iApp install ########

# Get a token, so we don't have to store user credentials
  robot.respond /install iapp\b (.*) (.*)/i, (res) ->

    # the iApp we are going to install
    iapp_file_path = "#{iapps.iApp_loc}import-json/#{iapps.iApp_file}"
#    console.log iapp_file_path

    # Contruct JSON for the POST to authn/login
    post_data = require "#{iapp_file_path}"
    post_data_stringify = JSON.stringify post_data

    # Get iWorkflow address
    iwf_addr = robot.brain.get('iwf_addr')

    # join creds and base64 for header insertion
    auth_creds = res.match[1] + ":" + res.match[2]
    auth_basic = new Buffer(auth_creds).toString('base64')

    # Perform the installation (POST to /iapps)
    options = rejectUnauthorized: false #ignore self-signed certs
    robot.http("https://#{iwf_addr}/mgmt/cm/cloud/templates/iapp", options)
      .headers("Content-Type": "application/json", "Authorization": "Basic #{auth_basic}")
      .post(post_data_stringify) (err, resp, body) ->

        # Handle error
        if err
          res.reply "Encountered an error :( #{err}"
          return
        if resp.statusCode isnt 200
          res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
          console.log "Something went wrong :( BODY: #{body}"
          return

        try
          res.reply resp.statusCode + " - " + resp.statusMessage
          jp_body = JSON.parse body
          res.reply "Installed: #{jp_body.name}"
        catch error
         res.send "Ran into an error parsing JSON :("
         return

        for i in iApp_services
          # the Service_Templates we are going to install
          cosole.log "Service #{i}: #{iapps.iApp_services[i]}"
          iapp_file_path = "#{iapps.iApp_loc}service-templates/#{iapps.iApp_services[i]}"
          console.log iapp_file_path

          # Contruct JSON for the POST to authn/login
          post_data = require "#{iapp_file_path}"
          post_data_stringify = JSON.stringify post_data

          # Perform the installation (POST to /iapps)
          options = rejectUnauthorized: false #ignore self-signed certs
          robot.http("https://#{iwf_addr}/mgmt/cm/cloud/templates/iapp", options)
            .headers("Content-Type": "application/json", "Authorization": "Basic #{auth_basic}")
            .post(post_data_stringify) (err, resp, body) ->

              # Handle error
              if err
                res.reply "Encountered an error :( #{err}"
                return
              if resp.statusCode isnt 200
                res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
                console.log "Something went wrong :( BODY: #{body}"
                return

              try
                res.reply resp.statusCode + " - " + resp.statusMessage
                jp_body = JSON.parse body
                res.reply "Installed: #{jp_body.name}"
              catch error
               res.send "Ran into an error parsing JSON :("
               return





######## END iApp install ########
