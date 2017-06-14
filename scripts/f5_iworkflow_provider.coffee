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

  iapps = require "../iApps/iApps.json"
  DEBUG = false
  OPTIONS = rejectUnauthorized: false #ignore self-signed certs


######## BEGIN (list|show) Discovered Devices ########

  robot.respond /(list|show) devices/i, (res) ->

    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')

    res.reply "Reading devices on: #{IWF_ADDR}"
# /mgmt/shared/resolver/device-groups/cm-cloud-managed-devices/devices/
# /mgmt/cm/shared/config/current/cm/device/
    robot.http("https://#{IWF_ADDR}/mgmt/shared/resolver/device-groups/cm-cloud-managed-devices/devices/", OPTIONS)
      .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
      .get() (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

##TODO use 'try' to catch errors
        data = JSON.parse body

##TODO Handle 'undefined/null/none'
        for i of data.items
          DEVICE_HOSTNAME = data.items[i].hostname
          DEVICE_UUID = data.items[i].uuid
          DEVICE_VERSION = data.items[i].version
          res.reply "Device #{i}: #{DEVICE_HOSTNAME} - #{DEVICE_VERSION} - #{DEVICE_UUID}"


######## END (list|show) Discovered Devices ########


######## BEGIN Discover/Add Device ########

  robot.respond /add device (.*) (.*) (.*) (.*)/i, (res) ->

    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')

    res.reply "Adding #{res.match[1]} devices on: #{IWF_ADDR}"

    console.log "res.match[0]: #{res.match[0]}"
    console.log "res.match[1]: #{res.match[1]}"
    console.log "res.match[2]: #{res.match[2]}"
    console.log "res.match[3]: #{res.match[3]}"
    console.log "res.match[4]: #{res.match[4]}"

    post_data = JSON.stringify({
      address: res.match[1],
      userName: res.match[2],
      password: res.match[3],
      automaticallyUpdateFramework: res.match[4]
    })

    console.log "post_data: #{post_data}"

    # Perform the POST to authn/login
    robot.http("https://#{IWF_ADDR}/mgmt/shared/resolver/device-groups/cm-cloud-managed-devices/devices/", OPTIONS)
      .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
      .post(post_data) (err, resp, body) ->


        # Handle error
        if err
          res.reply "Encountered an error :( #{err}"
          return
        if resp.statusCode isnt 200
          console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
          console.log "body: #{body}"
          jpresp = JSON.parse resp
          res.reply "Something went wrong :( #{jpresp}"
          return

        try
#          resp_body = JSON.parse body
          console.log "body: #{body}"
        catch error
         res.send "Ran into an error parsing JSON :("
         return


#  /mgmt/cm/shared/config/current/cm/device/

######## END Discover/Add Device ########



######## BEGIN (list|show) Available iApps & Service Templates ########

  robot.respond /(list|show) available iapps/i, (res) ->

    res.reply "iApp: #{iapps.iApp_file}"


  robot.respond /(list|show) available service templates/i, (res) ->

    res.reply "iApp: #{iapps.iApp_file}"
    for i of iapps.iApp_service_templates
      res.reply "Service Templates: #{iapps.iApp_service_templates[i]}"

######## END (list|show) Available iApps & Service Templates ########


######## BEGIN (list|show) Installed iApps & Service Templates ########

  # List/Show the iApps installed on iWorkflow
  robot.respond /(list|show) installed iapps/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')

    res.reply "Reading iApps on: #{IWF_ADDR}"

    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/templates/iapp", OPTIONS)
      .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
      .get() (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        data = JSON.parse body

##TODO Handle 'undefined/null/none'
        for i of data.items
          IAPP_NAME = data.items[i].name
          res.reply "Installed iApps: #{IAPP_NAME}"



  # List/Show the Services Templates installed on iWorkflow
  robot.respond /(list|show) installed service templates/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')

    res.reply "Reading Service Templates on: #{IWF_ADDR}"

    options = rejectUnauthorized: false #ignore self-signed certs

    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/provider/templates/iapp", options)
      .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
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
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')

    res.reply "Installing iApps on: #{IWF_ADDR}"

    # the iApp we are going to install
    iapp_file_path = "#{iapps.iApp_loc}import-json/#{iapps.iApp_file}"
#    console.log iapp_file_path

    # Contruct JSON for the POST to authn/login
    post_data = require "#{iapp_file_path}"
    post_data_stringify = JSON.stringify post_data

    # Get iWorkflow address
    IWF_ADDR = robot.brain.get('IWF_ADDR')

    # Perform the installation (POST to /iapps)
    options = rejectUnauthorized: false #ignore self-signed certs
    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/templates/iapp", options)
      .headers("Content-Type": "application/json", 'X-F5-Auth-Token': IWF_TOKEN)
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
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')

    res.reply "Installing Services Tempaltes on: #{IWF_ADDR}"

    for i of iapps.iApp_service_templates
      # the Service_Templates we are going to install
      service_file_path = "#{iapps.iApp_loc}service-templates/#{iapps.iApp_service_templates[i]}"

      # Contruct JSON for the POST to authn/login
      post_data = require "#{service_file_path}"
      post_data_stringify = JSON.stringify post_data

      # Perform the deletion (DELETE to /iapps)
      options = rejectUnauthorized: false #ignore self-signed certs
      robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/provider/templates/iapp", options)
        .headers("Content-Type": "application/json", 'X-F5-Auth-Token': IWF_TOKEN)
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
            jp_body = JSON.parse body
            res.reply "Service Template #{jp_body.templateName} - Installed - #{resp.statusCode} - #{resp.statusMessage}"
          catch error
           res.send "Ran into an error parsing JSON :("
           return


######## BEGIN Install iApps and Service Templates ########

######## BEGIN iApp delete ########

  robot.respond /delete iapps/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')


    options = rejectUnauthorized: false #ignore self-signed certs

    # Perform the deletion (DELETE to /iapps)
    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/templates/iapp/#{iapps.IAPP_NAME}", options)
      .headers("Content-Type": "application/json", 'X-F5-Auth-Token': IWF_TOKEN)
      .delete() (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        if resp.statusCode is 200
          res.reply "iApp #{iapps.IAPP_NAME} deleted!"
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
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')

## You must delete provider templates before iApps.
    for i of iapps.iApp_service_templates
        long_name = iapps.iApp_service_templates[i]
        short_name = long_name.split "_v2.0.004.json"  # drop the extension

#        res.reply "Deleting: #{short_name[0]}"

        # Perform the deletion (DELETE to /iapps)
        options = rejectUnauthorized: false #ignore self-signed certs
        robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/provider/templates/iapp/#{short_name[0]}", options)
          .headers("Content-Type": "application/json", 'X-F5-Auth-Token': IWF_TOKEN)
          .delete() (err, resp, body) ->

            if err
              res.reply "Encountered an error :( #{err}"
              return

            if resp.statusCode is 200
              res.reply "Service Template #{iapps.iApp_service_templates[i]} deleted!"
            else
              res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
              console.log "Something went wrong :( BODY: #{body}"
              return


######## END iApp delete ########
