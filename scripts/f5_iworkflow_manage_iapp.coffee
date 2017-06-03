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

######## BEGIN (list|show) iApps ########

  robot.respond /(list|show) available iapps/i, (res) ->
    res.reply "iApp: #{iapps.iApp_file}"
    for i of iapps.iApp_services
      res.reply "Service Templates: #{iapps.iApp_services[i]}"


  # List/Show the authenticated users Tenant assignements
  robot.respond /(list|show) installed iapps/i, (res) ->

    res.reply "Reading iApps/Service templates on: #{iwf_addr}"

    #Respond with all the variables (bot not the password)
    iwf_addr = robot.brain.get('iwf_addr')
    iwf_token = robot.brain.get('iwf_token')
    options = rejectUnauthorized: false #ignore self-signed certs

    robot.http("https://#{iwf_addr}/mgmt/cm/cloud/templates/iapp", options)
      .headers('X-F5-Auth-Token': iwf_token, 'Accept': "application/json")
      .get() (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        data1 = JSON.parse body
        for i of data1.items
          iapp_name = data1.items[i].name
          res.reply "Installed iApps: #{iapp_name}"

    robot.http("https://#{iwf_addr}/mgmt/cm/cloud/provider/templates/iapp", options)
      .headers('X-F5-Auth-Token': iwf_token, 'Accept': "application/json")
      .get() (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        data2 = JSON.parse body
        for i of data2.items
          name = data2.items[i].templateName
          res.reply "\tService Templates: #{name}"

######## END (list|show) iApps ########


######## BEGIN iApp install ########

# Get a token, so we don't have to store user credentials
  robot.respond /install iapps\b (.*) (.*)/i, (res) ->

    res.reply "Installing iApps/Service templates on: #{iwf_addr}"

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
      .headers("Content-Type": "application/json", 'X-F5-Auth-Token': iwf_token)
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
          res.reply "iApp #{jp_body.name} - Installed - #{resp.statusCode} - #{resp.statusMessage}"
        catch error
         res.send "Ran into an error parsing JSON :("
         return

        for i of iapps.iApp_services
          # the Service_Templates we are going to install
          iapp_file_path = "#{iapps.iApp_loc}service-templates/#{iapps.iApp_services[i]}"

          # Contruct JSON for the POST to authn/login
          post_data = require "#{iapp_file_path}"
          post_data_stringify = JSON.stringify post_data

          # Perform the installation (POST to /iapps)
          options = rejectUnauthorized: false #ignore self-signed certs
          robot.http("https://#{iwf_addr}/mgmt/cm/cloud/provider/templates/iapp", options)
            .headers("Content-Type": "application/json", 'X-F5-Auth-Token': iwf_token)
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
                res.reply "Service Template #{jp_body.templateName}\n\t - Installed - #{resp.statusCode} - #{resp.statusMessage}"
              catch error
               res.send "Ran into an error parsing JSON :("
               return

######## END iApp install ########

######## BEGIN iApp delete ########

#  robot.respond /delete iapps\b (.*) (.*)/i, (res) ->
  robot.respond /delete iapps/i, (res) ->   # For Dev/Test

## You must delete provider templates before iApps.
    for i of iapps.iApp_services
        long_name = iapps.iApp_services[i]
        short_name = long_name.split "_v2.0.004.json"
#        console.log "short_name[0]: #{short_name[0]}"
        res.reply "Deleting: #{short_name[0]}"

        # Perform the deletion (DELETE to /iapps)
        options = rejectUnauthorized: false #ignore self-signed certs
        robot.http("https://#{iwf_addr}/mgmt/cm/cloud/provider/templates/iapp/#{short_name[0]}", options)    # <- Service Template file name "split(".")"  remove .json
          .headers("Content-Type": "application/json", 'X-F5-Auth-Token': iwf_token)
          .delete() (err, resp, body) ->
            if err
              res.reply "Encountered an error :( #{err}"
              return

            if resp.statusCode isnt 200
              res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
              console.log "Something went wrong :( BODY: #{body}"
#              return
            else
              res.reply "Service Template #{iapps.iApp_services[i]} deleted!"

    console.log "iapps.iApp_name: #{iapps.iApp_name}"
    res.reply "Deleting: #{iapps.iApp_name}"

    robot.http("https://#{iwf_addr}/mgmt/cm/cloud/templates/iapp/#{iapps.iApp_name}", options)     # <- iApp file name "split(".")"  remove .json
      .headers("Content-Type": "application/json", 'X-F5-Auth-Token': iwf_token)
      .delete() (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        if resp.statusCode isnt 200
          res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
          console.log "Something went wrong :( BODY: #{body}"
          return
        else
          res.reply "Service Template #{iapps.iApp_name} deleted!"


######## END iApp delete ########
