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


######## BEGIN (list|show) Discovered Devices ########

  robot.respond /(list|show) devices/i, (res) ->

    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE isnt "Administrator"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Administrator' roles."
      return

    res.reply "Reading devices on: #{IWF_ADDR}"

    robot.http("https://#{IWF_ADDR}/mgmt/shared/resolver/device-groups/cm-cloud-managed-devices/devices/", OPTIONS)
      .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
      .get() (err, resp, body) ->

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

        try
          if DEBUG then console.log "body: #{body}"
          data = JSON.parse body

          # Iterate through the devices.
          for i of data.items
            DEVICE_HOSTNAME = data.items[i].hostname
            DEVICE_UUID = data.items[i].uuid
            DEVICE_VERSION = data.items[i].version
            res.reply "Device #{i}: #{DEVICE_HOSTNAME} - #{DEVICE_VERSION} - #{DEVICE_UUID}"

        catch error
         res.send "Ran into an error parsing JSON :("
         return


######## END (list|show) Discovered Devices ########


######## BEGIN Discover/Add Device ########

  robot.respond /add device (.*) (.*) (.*) (.*)/i, (res) ->

    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE isnt "Administrator"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Administrator' roles."
      return

    res.reply "Adding device \'#{res.match[1]}\' to iWorkflow: #{IWF_ADDR}"

    post_data = JSON.stringify({
      address: res.match[1],
      userName: res.match[2],
      password: res.match[3],
      automaticallyUpdateFramework: res.match[4]
    })

    if DEBUG then console.log "post_data: #{post_data}"

    # Perform the POST to authn/login
    robot.http("https://#{IWF_ADDR}/mgmt/shared/resolver/device-groups/cm-cloud-managed-devices/devices/", OPTIONS)
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

######## END Discover/Add Device ########


######## BEGIN Delete/Remove Device ########

  robot.respond /delete device (.*)/i, (res) ->

    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')
    DEVICE_UUID = res.match[1]

    if IWF_ROLE isnt "Administrator"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Administrator' roles."
      return

    robot.http("https://#{IWF_ADDR}/mgmt/shared/resolver/device-groups/cm-cloud-managed-devices/devices/#{DEVICE_UUID}", OPTIONS)
      .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
      .delete() (err, resp, body) ->

        # Handle error
        if err
          res.reply "Encountered an error :( #{err}"
          return

        if resp.statusCode isnt 200
          if DEBUG
            console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
            console.log "body.code: #{body.code} body.message: #{body.message} "
            console.log "body: #{body}"
          try
            jp_body = JSON.parse body
            res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
            return
          catch error
            res.send "Ran into an error parsing JSON :("
            return
        else
          res.reply "Status: #{resp.statusCode} - #{resp.statusMessage}"
          if DEBUG then console.log "body: #{body}"

######## END Delete/Remove Device ########


######## BEGIN (list|show) Available iApps & Service Templates ########

  robot.respond /(list|show) available iapps/i, (res) ->

    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE isnt "Administrator"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Administrator' roles."
      return

    else
      # list the iApps available to install.
      res.reply "iApp: #{iapps.iApp_file}"


  robot.respond /(list|show) available service templates/i, (res) ->

    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE isnt "Administrator"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Administrator' roles."
      return

    else
      # list the Service Templates available to install.
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
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE isnt "Administrator"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Administrator' roles."
      return

    else
      res.reply "Reading iApps on: #{IWF_ADDR}"

      robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/templates/iapp", OPTIONS)
        .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
        .get() (err, resp, body) ->

          # Handle Error
          if err
            res.reply "Encountered an error :( #{err}"
            return

          if resp.statusCode isnt 200
            if DEBUG
              console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
              console.log "body.code: #{body.code} body.message: #{body.message} "
            jp_body = JSON.parse body
            res.reply "Something went wrong :( #{jpbody.code} - #{jpbody.message}"
            return
          else

            if DEBUG then console.log "body: #{body}"

            try
              jp_body = JSON.parse body
              if jp_body.items.length < 1
                res.reply "#{jp_body.items.length} iApps installed."
                return
              else

                for i of jp_body.items
                  name = jp_body.items[i].name
                  res.reply "Installed iApp #{i}: #{name}"

            catch error
              res.send "Ran into an error parsing JSON :("
              return


  # List/Show the Services Templates installed on iWorkflow
  robot.respond /(list|show) installed service templates/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE isnt "Administrator"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Administrator' roles."
      return

    else
      robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/provider/templates/iapp", OPTIONS)
        .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
        .get() (err, resp, body) ->

          # Handle Error
          if err
            res.reply "Encountered an error :( #{err}"
            return

          if resp.statusCode isnt 200
            if DEBUG
              console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
              console.log "body.code: #{body.code} body.message: #{body.message} "
            try
              jp_body = JSON.parse body
              res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
              return

            catch error
              res.send "Ran into an error parsing JSON :("
              return

          else
            try
              jp_body = JSON.parse body
              if jp_body.items.length < 1
                res.reply "#{jp_body.items.length} service templates installed."
                return
              else
                for i of jp_body.items
                  name = jp_body.items[i].templateName
                  res.reply "\tService Templates: #{name}"

            catch error
             res.send "Ran into an error parsing JSON :("
             return


######## END (list|show) Installed iApps & Service Templates ########


######## BEGIN Install iApps and Service Templates ########

# Install the available iApps onto iWorkflow
  robot.respond /install iapps/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
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


# Install the available Service Templates onto iWorkflow
  robot.respond /install service templates/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
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

            if resp.statusCode isnt 200
              res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
              if DEBUG then console.log "Something went wrong :( BODY: #{body}"
              return
            else
              try
                jp_body = JSON.parse body
                res.reply "Service Template #{jp_body.templateName} - Installed - #{resp.statusCode} - #{resp.statusMessage}"

              catch error
               res.send "Ran into an error parsing response JSON :("
               return


######## BEGIN Install iApps and Service Templates ########

######## BEGIN iApp delete ########

  robot.respond /delete iapps/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
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


  robot.respond /delete service templates/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
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
                res.reply "Service Template #{iapps.iApp_service_templates[i]} deleted!"


######## END iApp delete ########
