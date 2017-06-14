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


######## BEGIN Show Services and VIP/Pools ########

# Get Services
  robot.respond /(list|show) services/i, (res) ->
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_TENANT = robot.brain.get('IWF_TENANT')
    if !IWF_TENANT?
      res.reply "You must set a tenant to work with. Refer to \'help list tenants\' and \'help set tenant\'"
      return

# Get a list of the Deployed services for the specified iWorkflow Tenant
    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenants/#{IWF_TENANT}/services/iapp", OPTIONS)
      .headers('X-F5-Auth-Token': IWF_TOKEN, Accept: 'application/json')
      .get() (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        data = JSON.parse body

# Check we actually have some services
        if data.items == undefined
          res.reply "Something went wrong. Has your token expired"

        else if data.items.length < "1"
          res.reply "#{IWF_TENANT} has no services"

# Grab the name and template for each service.
        for i of data.items
          service = data.items[i].name
          template = data.items[i].tenantTemplateReference.link  #TODO Just grab the end of the selflink (end of URI)
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

              data = JSON.parse body
              pool_members = []

              for i of data.vars
                if data.vars[i].name is "pool__addr"
                  vip = data.vars[i].value
                else if data.vars[i].name is "pool__port"
                  port = data.vars[i].value

# Get the pool members for the services
              for i of data.tables
                if data.tables[i].name is "pool__Members"
                  for j of data.tables[i].rows
                    long_name = JSON.stringify data.tables[i].rows[j]
                    short_name = long_name.split("\"")
                    pool_members.push short_name[1]

              res.reply " - Listener: #{vip}:#{port}\n - Servers: #{pool_members}"

######## END Show Services and VIP/Pools ########


######## BEGIN Show Service Templates ########

  # List/Show the Services Templates installed on iWorkflow
  robot.respond /(list|show) service templates/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')

#    res.reply "Reading Service Templates on: #{IWF_ADDR}"

    OPTIONS = rejectUnauthorized: false #ignore self-signed certs

    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenant/templates/iapp/", OPTIONS)
      .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
      .get() (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        data = JSON.parse body
        for i of data.items
          name = data.items[i].name
          res.reply "\tService Templates: #{name}"

######## END Show Service Templates ########


######## BEGIN Show Cloud Connector UUID ########

# Required to deploy a new L4 - L7 Service

  # List/Show 'this' tenants Clouds and their UUIDs
  robot.respond /(list|show) clouds/i, (res) ->

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_TENANT = robot.brain.get('IWF_TENANT')

    if !IWF_TENANT?
      res.reply "You must use 'set tenant <tenant_name>' before executing this command."
      return

    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenants/#{IWF_TENANT}/connectors/", options)
      .headers('X-F5-Auth-Token': IWF_TOKEN, 'Accept': "application/json")
      .get() (err, resp, body) ->
        if err
          res.reply "Encountered an error :( #{err}"
          return

        data = JSON.parse body
        for i of data.items
          name = data.items[i].name
          uuid = data.items[i].connectorId
          res.reply "Cloud: #{name}, UUID: #{uuid}"

######## END Show Cloud Connector UUID ########


######## BEGIN Show Service Template Example ########

# Requires user specify a template.

  # List/Show the Service Template Example for a specific template
  robot.respond /(list|show) service template example (.*)/i, (res) ->

    # first we construct the 'sample' name
#    console.log "res.match[2]: #{res.match[2]}"
    example_file = res.match[2]
#    console.log "example_file: #{example_file}"
    example_path = "#{iapps.iApp_loc}tenant-service-samples/#{example_file}-service_#{iapps.iApp_ver}.json"
#    console.log "example_path: #{example_path}"

    # It fetches the data from the path
    example_data = require "#{example_path}"
    example_data_stringified = JSON.stringify(example_data, ' ', '\t')

    res.reply "#{example_file} example:\n#{example_data_stringified}"

######## END Show Service Template Example ########

######## BEGIN Deploy Service ########

# Requires user specify a template.

  # Deploy a Service Template. Requires URLencoded JSON data (for hubot)
  robot.respond /deploy service ((.*|\s*)+)/i, (res) ->

    console.log "res.match[0]: #{res.match[0]}"
    console.log "res.match[1]: #{res.match[1]}"
    console.log "res.match[2]: #{res.match[2]}"
    console.log "res.match[3]: #{res.match[3]}"
    console.log "res.match[4]: #{res.match[4]}"

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_TENANT = robot.brain.get('IWF_TENANT')

    if !IWF_TENANT?
      res.reply "You must use 'set tenant <tenant_name>' before executing this command."
      return

    service_input = res.match[1]
#    decoded_input = decodeURIComponent(service_input)
    decoded_input = decodeURIComponent service_input.replace(/\+/g, '%20')
    console.log "decoded_input: #{decoded_input}"
#    post_data_stringify = JSON.stringify decoded_input
#    console.log "post_data_stringify: #{post_data_stringify}"
#    decoded

    robot.http("https://#{IWF_ADDR}/mgmt/cm/cloud/tenants/#{IWF_TENANT}/services/iapp", OPTIONS)
      .headers("Content-Type": "application/json", 'X-F5-Auth-Token': IWF_TOKEN)
      .post(decoded_input) (err, resp, body) ->

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
#          jp_body = JSON.parse body
          res.reply "body: #{body}"
#          res.reply "iApp #{jp_body.name} - Installed - #{resp.statusCode} - #{resp.statusMessage}"
        catch error
         res.send "Ran into an error parsing JSON :("
         return


######## END Deploy Service ########


######## BEGIN Delete Service ########

# Requires user specify a service, obtained using '[botname] list services'.

  # List/Show the Service Template Example for a specific template
  robot.respond /delete service (.*)/i, (res) ->

    console.log "res.match[0]: #{res.match[0]}"
    console.log "res.match[1]: #{res.match[1]}"
    console.log "res.match[2]: #{res.match[2]}"

    # Use the config
    IWF_ADDR = robot.brain.get('IWF_ADDR')
    IWF_TOKEN = robot.brain.get('IWF_TOKEN')
    IWF_TENANT = robot.brain.get('IWF_TENANT')

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
          console.log "Something went wrong :( BODY: #{body}"
          return

        try
          res.reply resp.statusCode + " - " + resp.statusMessage
        catch error
         res.send "Ran into an error parsing JSON :("
         return

######## END Delete Service ########

######## BEGIN Encode JSON ########

  # Instructions for converting your JSON data into a single encoded string, to play nice with hubot.
  robot.respond /encode json/i, (res) ->
    res.reply "Go here:\n https://www.freeformatter.com/url-encoder.html \nPaste your JSON into the text box, click 'encode'. Use this encoded string with the 'deploy service <encoded_JSON_Input>' command."

######## END Encode JSON ########
