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


######## BEGIN Show Services and VIP/Pools ########

  robot.respond /(list|show) services/i, (res) ->

    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_TENANT = robot.brain.get('IWF_TENANT')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if DEBUG
      console.log "IWF_ADDR: #{IWF_ADDR}, IWF_USERNAME: #{IWF_USERNAME}, IWF_TOKEN: #{IWF_TOKEN}, IWF_TENANT: #{IWF_TENANT}, IWF_ROLE: #{IWF_ROLE}"

    if IWF_ROLE isnt "Tenant"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Tenant' roles."
      return

    if !IWF_TENANT?
      res.reply "You must set a tenant to work with. Refer to \'help list tenants\' and \'help set tenant\'"
      return

# Get a list of the Deployed services for the specified iWorkflow Tenant
    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenants/#{IWF_TENANT}/services/iapp", OPTIONS)
      .headers('X-F5-Auth-Token': IWF_TOKEN, Accept: 'application/json')
      .get() (err, resp, body) ->

        if DEBUG then console.log "Making request..."

        if err
          res.reply "Encountered an error :( #{err}"
          return

        if resp.statusCode isnt 200
          if DEBUG
            console.log "resp.statusCode: #{resp.statusCode} - #{resp.statusMessage}"
            console.log "body.code: #{body.code} body.message: #{body.message}"
          try
            jp_body = JSON.parse body
            res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
            return
          catch error
            res.send "Ran into an error parsing JSON :("
            return
        else
          try
            if DEBUG then console.log "200 response. Parsing JSON..."
            jp_body = JSON.parse body

            # Check we actually have some services
            if jp_body.items == undefined
              res.reply "Something went wrong. Has your token expired"

            else if jp_body.items.length < "1"
              res.reply "#{IWF_TENANT} has no services"

            # Grab the name and template for each service.
            for i of jp_body.items
              service = jp_body.items[i].name
              template = jp_body.items[i].tenantTemplateReference.link  #TODO Just grab the end of the selflink (end of URI)
              res.reply "Service: #{service}\nTemplate: #{template}"

# Get the VIP details for each service
              robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenants/#{IWF_TENANT}/services/iapp/#{service}", OPTIONS)
                .headers('X-F5-Auth-Token': IWF_TOKEN, Accept: 'application/json')
                .get() (err, resp, body) ->
                  if err
                    res.reply "Encountered an error :( #{err}"
                    return
                  if resp.statusCode isnt 200
                    res.reply "Something went wrong :( #{resp}"
                    return

                  jp_body = JSON.parse body
                  pool_members = []

                  for i of jp_body.vars
                    if jp_body.vars[i].name is "pool__addr"
                      vip = jp_body.vars[i].value
                    else if jp_body.vars[i].name is "pool__port"
                      port = jp_body.vars[i].value

    # Get the pool members for the services
                  for i of jp_body.tables
                    if jp_body.tables[i].name is "pool__Members"
                      for j of jp_body.tables[i].rows
                        long_name = JSON.stringify jp_body.tables[i].rows[j]
                        short_name = long_name.split("\"")
                        pool_members.push short_name[1]

                  res.reply " - Listener: #{vip}:#{port}\n - Servers: #{pool_members}"

######## END Show Services and VIP/Pools ########


######## BEGIN Show Service Templates ########

  # List/Show the Services Templates installed on iWorkflow
  robot.respond /(list|show) service templates/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if DEBUG
      console.log "IWF_ADDR: #{IWF_ADDR}, IWF_USERNAME: #{IWF_USERNAME}, IWF_TOKEN: #{IWF_TOKEN}, IWF_TENANT: #{IWF_TENANT}, IWF_ROLE: #{IWF_ROLE}"

    if IWF_ROLE isnt "Tenant"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Tenant' roles."
      return

    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenant/templates/iapp/", OPTIONS)
      .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
      .get() (err, resp, body) ->

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
          try
            jp_body = JSON.parse body

            if jp_body.items.length < 1
              res.reply "#{jp_body.items.length} services found."
              return
            else
              for i of jp_body.items
                name = jp_body.items[i].name
                res.reply "\tService Templates: #{name}"

          catch error
            res.send "Ran into an error parsing JSON :("
            return


######## END Show Service Templates ########


######## BEGIN Show Cloud Connector UUID ########

# Required to deploy a new L4 - L7 Service

  # List/Show 'this' tenants Clouds and their UUIDs
  robot.respond /(list|show) clouds/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_TENANT = robot.brain.get('IWF_TENANT')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if DEBUG
      console.log "IWF_ADDR: #{IWF_ADDR}, IWF_USERNAME: #{IWF_USERNAME}, IWF_TOKEN: #{IWF_TOKEN}, IWF_TENANT: #{IWF_TENANT}, IWF_ROLE: #{IWF_ROLE}"

    if IWF_ROLE isnt "Tenant"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Tenant' roles."
      return

    if !IWF_TENANT?
      res.reply "You must use 'set tenant <tenant_name>' before executing this command."
      return

    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenants/#{IWF_TENANT}/connectors/", OPTIONS)
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
          res.reply "Something went wrong :( #{jp_body.code} - #{jp_body.message}"
          return
        else
          try
            data = JSON.parse body
            for i of data.items
              name = data.items[i].name
              uuid = data.items[i].connectorId
              res.reply "Cloud: #{name}, UUID: #{uuid}"
          catch error
            res.send "Ran into an error parsing JSON :("
            return

######## END Show Cloud Connector UUID ########


######## BEGIN Show Service Template Example ########

# Requires user specify a template.

  # List/Show the Service Template Example for a specific template
  robot.respond /(list|show) service template example (.*)/i, (res) ->

    # first we construct the 'sample' name
    example_file = res.match[2]
    example_path = "#{iapps.iApp_loc}tenant-service-samples/#{example_file}-service_#{iapps.iApp_ver}.json"
    if DEBUG then console.log "DEBUG: example_path: #{example_path}"

    # It fetches the data from the path
    example_data = require "#{example_path}"
    # It pretty prints the JSON, or it get the hose again...
    js_example_data = JSON.stringify(example_data, ' ', '\t')

    res.reply "#{example_file} example:\n#{js_example_data}"

######## END Show Service Template Example ########

######## BEGIN Deploy Service ########

# Requires user specify a template.

  # Deploy a Service Template. Requires URLencoded JSON data (for hubot)
  robot.respond /deploy service (.*)/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_TENANT = robot.brain.get('IWF_TENANT')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE isnt "Tenant"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Tenant' roles."
      return

    if !IWF_TENANT?
      res.reply "You must use 'set tenant <tenant_name>' before executing this command."
      return

    service_input = res.match[1]
    decoded_input = decodeURIComponent service_input.replace(/\+/g, '%20')

    if DEBUG then console.log "decoded_input: #{decoded_input}"

    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenants/#{IWF_TENANT}/services/iapp", OPTIONS)
      .headers("Content-Type": "application/json", 'X-F5-Auth-Token': IWF_TOKEN)
      .post(decoded_input) (err, resp, body) ->

        # Handle error
        if err
          res.reply "Encountered an error :( #{err}"
          return

        if resp.statusCode isnt 200
          res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
          if DEBUG then console.log "Something went wrong :( BODY: #{body}"
          return

        try
          res.reply resp.statusCode + " - " + resp.statusMessage
          jp_body = JSON.parse body
#          res.reply "Deployed: #{jp_body.name}"
          res.reply "iApp #{jp_body.name} - Installed - #{resp.statusCode} - #{resp.statusMessage}"
        catch error
         res.send "Ran into an error parsing JSON :("
         return

######## END Deploy Service ########


######## BEGIN Delete Service ########

# Requires user specify a service, obtained using '[botname] list services'.

  # List/Show the Service Template Example for a specific template
  robot.respond /delete service (.*)/i, (res) ->

    console.log "res.match[1]: #{res.match[1]}"
    if res.match[1] is 'templates'
      return

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_USERNAME = robot.brain.get('IWF_USERNAME')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_TENANT = robot.brain.get('IWF_TENANT')
    IWF_ROLE = robot.brain.get('IWF_ROLE')

    if IWF_ROLE isnt "Tenant"
      res.reply "The user '#{IWF_USERNAME}' is a '#{IWF_ROLE}' role. However, this command is for 'Tenant' roles."
      return

    if !IWF_TENANT?
      res.reply "You must use 'set tenant <tenant_name>' before executing this command."
      return

    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenants/#{IWF_TENANT}/services/iapp/#{res.match[1]}", OPTIONS)
      .headers("Content-Type": "application/json", 'X-F5-Auth-Token': IWF_TOKEN)
      .delete() (err, resp, body) ->

        # Handle error
        if err
          res.reply "Encountered an error :( #{err}"
          return

        if resp.statusCode isnt 200
          res.reply "Something went wrong :( RESP: #{resp.statusCode} #{resp.statusMessage}"
          if DEBUG then console.log "Something went wrong :( BODY: #{body}"
          return
        else
          res.reply resp.statusCode + " - " + resp.statusMessage

######## END Delete Service ########

######## BEGIN Encode JSON ########

  # Instructions for converting your JSON data into a single encoded string, to play nice with hubot.
  robot.respond /encode json/i, (res) ->
    res.reply "Go here:\n https://www.freeformatter.com/url-encoder.html \nPaste your JSON into the text box, click 'encode'. Use this encoded string with the 'deploy service <encoded_JSON_Input>' command."

######## END Encode JSON ########
