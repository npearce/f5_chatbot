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

######## BEGIN (list|show) Available iApps & Service Templates ########

  robot.respond /(list|show) available iapps/i, (res) ->

    # Use the config
    iwf_addr = robot.brain.get('iwf_addr')
    iwf_token = robot.brain.get('iwf_token')

    res.reply "iApp: #{iapps.iApp_file}"

  robot.respond /(list|show) available service templates/i, (res) ->

    # Use the config
    iwf_addr = robot.brain.get('iwf_addr')
    iwf_token = robot.brain.get('iwf_token')

    res.reply "iApp: #{iapps.iApp_file}"
    for i of iapps.iApp_service_templates
      res.reply "Service Templates: #{iapps.iApp_service_templates[i]}"

######## END (list|show) Available iApps & Service Templates ########


######## BEGIN (list|show) Installed iApps & Service Templates ########

  # List/Show the iApps installed on iWorkflow
  robot.respond /(list|show) installed iapps/i, (res) ->

    # Use the config
    iwf_addr = robot.brain.get('iwf_addr')
    iwf_token = robot.brain.get('iwf_token')

    res.reply "Reading iApps on: #{iwf_addr}"

    options = rejectUnauthorized: false #ignore self-signed certs

    robot.http("https://#{iwf_addr}/mgmt/cm/cloud/templates/iapp", options)
      .headers('X-F5-Auth-Token': iwf_token, 'Accept': "application/json")
      .get() (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        data = JSON.parse body

##TODO Handle 'undefined/null/none'
        for i of data.items
          iapp_name = data.items[i].name
          res.reply "Installed iApps: #{iapp_name}"



  # List/Show the Services Templates installed on iWorkflow
  robot.respond /(list|show) installed service templates/i, (res) ->

    # Use the config
    iwf_addr = robot.brain.get('iwf_addr')
    iwf_token = robot.brain.get('iwf_token')

    res.reply "Reading Service Templates on: #{iwf_addr}"

    options = rejectUnauthorized: false #ignore self-signed certs

    robot.http("https://#{iwf_addr}/mgmt/cm/cloud/provider/templates/iapp", options)
      .headers('X-F5-Auth-Token': iwf_token, 'Accept': "application/json")
      .get() (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        data = JSON.parse body
        for i of data.items
          name = data.items[i].templateName
          res.reply "\tService Templates: #{name}"


######## END (list|show) Installed iApps & Service Templates ########


######## BEGIN Install iApps and Service Templates ########

# Install the available iApps onto iWorkflow
  robot.respond /install iapps/i, (res) ->

    # Use the config
    iwf_addr = robot.brain.get('iwf_addr')
    iwf_token = robot.brain.get('iwf_token')

    res.reply "Installing iApps on: #{iwf_addr}"

    # the iApp we are going to install
    iapp_file_path = "#{iapps.iApp_loc}import-json/#{iapps.iApp_file}"
#    console.log iapp_file_path

    # Contruct JSON for the POST to authn/login
    post_data = require "#{iapp_file_path}"
    post_data_stringify = JSON.stringify post_data

    # Get iWorkflow address
    iwf_addr = robot.brain.get('iwf_addr')

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


# Install the available Service Templates onto iWorkflow
  robot.respond /install service templates/i, (res) ->

    # Use the config
    iwf_addr = robot.brain.get('iwf_addr')
    iwf_token = robot.brain.get('iwf_token')

    res.reply "Installing Services Tempaltes on: #{iwf_addr}"

    for i of iapps.iApp_service_templates
      # the Service_Templates we are going to install
      service_file_path = "#{iapps.iApp_loc}service-templates/#{iapps.iApp_service_templates[i]}"

      # Contruct JSON for the POST to authn/login
      post_data = require "#{service_file_path}"
      post_data_stringify = JSON.stringify post_data

      # Perform the deletion (DELETE to /iapps)
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
            res.reply "Service Template #{jp_body.templateName} - Installed - #{resp.statusCode} - #{resp.statusMessage}"
          catch error
           res.send "Ran into an error parsing JSON :("
           return


######## BEGIN Install iApps and Service Templates ########

######## BEGIN iApp delete ########

  robot.respond /delete iapps/i, (res) ->

    # Use the config
    iwf_addr = robot.brain.get('iwf_addr')
    iwf_token = robot.brain.get('iwf_token')


    options = rejectUnauthorized: false #ignore self-signed certs

    # Perform the deletion (DELETE to /iapps)
    robot.http("https://#{iwf_addr}/mgmt/cm/cloud/templates/iapp/#{iapps.iApp_name}", options)
      .headers("Content-Type": "application/json", 'X-F5-Auth-Token': iwf_token)
      .delete() (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        if resp.statusCode is 200
          res.reply "iApp #{iapps.iApp_name} deleted!"
        else if resp.statusCode is 400
          jp_body = JSON.parse body
          res.reply "Cannot delete: Code: #{resp.statusCode}, Message: #{jp_body.message}. Try \'delete service templates\' first."
          return
        else
          res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
          console.log "Something went wrong :( BODY: #{body}"
          return


  robot.respond /delete service templates/i, (res) ->

    # Use the config
    iwf_addr = robot.brain.get('iwf_addr')
    iwf_token = robot.brain.get('iwf_token')

## You must delete provider templates before iApps.
    for i of iapps.iApp_service_templates
        long_name = iapps.iApp_service_templates[i]
        short_name = long_name.split "_v2.0.004.json"  # drop the extension

        res.reply "Deleting: #{short_name[0]}"

        # Perform the deletion (DELETE to /iapps)
        options = rejectUnauthorized: false #ignore self-signed certs
        robot.http("https://#{iwf_addr}/mgmt/cm/cloud/provider/templates/iapp/#{short_name[0]}", options)
          .headers("Content-Type": "application/json", 'X-F5-Auth-Token': iwf_token)
          .delete() (err, resp, body) ->

            if err
              res.reply "Encountered an error :( #{err}"
              return

            if resp.statusCode isnt 200
              res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
              console.log "Something went wrong :( BODY: #{body}"
#              return

            res.reply "Service Template #{iapps.iApp_service_templates[i]} deleted! i is: #{i}"


######## END iApp delete ########
